#!/bin/zsh

function usage() {
    cat <<EOS
Usage:
	$0 <action> <env0> <blk0> <env1> <blk1>

	action: create, peers between the two VPCs
		delete, deletes the peering between the two VPCs
EOS
}

alias aws="aws ec2 --profile wobe-dev --output json"

function create_peering() {
    local -a run0=($1 $2)
    local -a run1=($3 $4)

    local vpcid0=$(terraform output -state="${run0[1]}-${run0[2]}.tfstate" "${run0[2]}-vpcid")
    local vpcid1=$(terraform output -state="${run1[1]}-${run1[2]}.tfstate" "${run1[2]}-vpcid")

    if [ $vpcid0 -a $vpcid1 ]; then
        echo Making request to peer from $vpcid0 to $vpcid1
        local peerid=$(aws create-vpc-peering-connection --vpc-id $vpcid0 --peer-vpc-id $vpcid1 | jq -r '.VpcPeeringConnection.VpcPeeringConnectionId')
        echo $peerid
        [ $peerid ] && aws accept-vpc-peering-connection --vpc-peering-connection-id $peerid
    fi
}

function delete_peering() {
    local -a run0=($1 $2)
    local -a run1=($3 $4)

    local vpcid0=$(terraform output -state="${run0[1]}-${run0[2]}.tfstate" "${run0[2]}-vpcid")
    local vpcid1=$(terraform output -state="${run1[1]}-${run1[2]}.tfstate" "${run1[2]}-vpcid")

    local peerid=$(aws describe-vpc-peering-connections --filters Name=requester-vpc-info.vpc-id,Values="$vpcid0" Name=accepter-vpc-info.vpc-id,Values="$vpcid1" | jq -r '.VpcPeeringConnections[] | if .Status.Code == "active" then .VpcPeeringConnectionId else empty end')
    if [ $peerid ]; then
        echo Deleting peering connection between $vpcid0 and $vpcid1
        aws delete-vpc-peering-connection --vpc-peering-connection-id $peerid
    fi
}

if [ $# -ne 5 ]; then
    usage
    exit 1
fi

local action=$1
local -a run0=($2 $3)
local -a run1=($4 $5)

echo $action $run0 $run1

case "$action" in
    create)
        create_peering $run0 $run1
        ;;
    delete)
        delete_peering $run0 $run1
        ;;
esac
