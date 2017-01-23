ifndef NAME
$(error You must set environment name NAME. eg. make NAME=run0 BLOCK=blk1)
endif

ifndef BLOCK
$(error You must set block name BLOCK. eg. make NAME=run0 BLOCK=blk1)
endif

action := plan

ifdef REALLY
$(info Here, hold my beer.)
action := apply
endif

all:	blk1 blk2

create:
	terraform import aws_key_pair.kp alephnull-4k -state='$(NAME)-$(BLOCK).tfstate'
	terraform $(action) -var 'ename=$(NAME)' -target 'module.$(BLOCK)' -state='$(NAME)-$(BLOCK).tfstate'

destroy:
	terraform destroy -var "ename=$(NAME)" -state='$(NAME)-$(BLOCK).tfstate'

.PHONY: create destroy
