provider "aws" {
  profile = "wobe-dev"
  region  = "us-east-1"
}

variable "ename" {
  description = "Environment name. From Makefile."
}

# AWS does not allow multiple pubkeys here
# Defining here and passing into modules to avoid InvalidKeypair.Duplicate
# Then moved out entirely to Makefile imports
# resource "aws_key_pair" "kp" {
#   key_name   = "alephnull"
#   public_key = "${file("./ecs.pub")}"
# }

module "blk1" {
  source = "./blk1"
  ename = "${var.ename}"
  pubkey = "alephnull-4k"
}

module "blk2" {
  source = "./blk2"
  ename = "${var.ename}"
  pubkey = "alephnull-4k"
}

output "blk1-fqdn" {
  value = "${module.blk1.fqdn}"
}

output "blk1-vpcid" {
  value = "${module.blk1.vpcid}"
}

output "blk2-fqdn" {
  value = "${module.blk2.fqdn}"
}

output "blk2-vpcid" {
  value = "${module.blk2.vpcid}"
}
