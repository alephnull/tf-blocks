# Pre-requisites
- AWS CLI
- jq
- terraform

# Theory of operation
`blk1` and `blk2` are two components which comprise of a single ec2 instance. All the gateways and routing tables are to access the instances from the internet for ease of test and can be safely ignored.

Creation and destruction of components is driven by `make`. Two parameters are required for every invocation: 
- `BLOCK`, corresponding to the component you wish to instantiate
- `NAME`, corresponding to what you wish to call this particular instance of the component

Terraform state is saved in files of the form `NAME`-`BLOCK`.tfstate and are explicitly passed on the command line, via `make`.

VPC peering is controlled by `peering.zsh` which just queries terraform output variables to do its job. The AWS CLI was chosen in the hopes that the PoC could be concluded quickly but shell scripts are notoriously fickle and it was necessary to tangle with `jq` for at least a modicum of safety. The end result is functional but maintainability is another story. It would be necessary to implement this using the AWS SDK for operational use.
