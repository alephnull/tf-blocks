# This is the component name
variable "cname" {
  description = "Component name. Set in terraform.tfvars."
  default="blk1"
}

# This is the env name (for each run)
variable "ename" {
  description = "Environment name. Passed in for each run from Makefile."
}

variable "pubkey" {
  description = "Pubkey to inject into instances"
}

#
# End of config variable. Details below this are internal to the implementation

variable "cidr_block" {
  default = "10.0.0.0/24"
}

resource "aws_vpc" "vpc" {
  cidr_block = "${var.cidr_block}"
  enable_dns_hostnames = true

  tags {
    "Name" = "${var.ename}-${var.cname}-vpc0"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    "Name" = "${var.ename}-${var.cname}-igw0"
  }
}

resource "aws_route_table" "r" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    "Name" = "${var.ename}-${var.cname}-r0"
  }
}

resource "aws_security_group" "sg" {
  name        = "ssh access"
  description = "Allow inbound ssh only"
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    "Name" = "${var.ename}-${var.cname}-sg0"
  }
}

# Subnet for the whole VPC
resource "aws_subnet" "subnet" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${var.cidr_block}"

  tags {
    "Name" = "${var.ename}-${var.cname}-net0"
  }

}

resource "aws_instance" "compute" {
  ami             = "ami-0d729a60"
  instance_type   = "t2.micro"
  key_name        = "${var.pubkey}"
  subnet_id = "${aws_subnet.subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.sg.id}"]
  associate_public_ip_address = true

  tags {
    "Name" = "${var.ename}-${var.cname}-ec2_0"
  }
}

output "fqdn" {
  value = "${aws_instance.compute.public_ip}"
}

output "vpcid" {
  value = "${aws_vpc.vpc.id}"
}
