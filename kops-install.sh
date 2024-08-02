#!/bin/bash

export KOPS_STATE_STORE=s3://kops-indojeans-state-store

# Fetch VPC ID and Subnet IDs using Terraform
VPC_ID=$(terraform output -json vpc_id | jq -r .)
#PUBLIC_SUBNET_IDS=$(terraform output -json public_subnet_ids | jq -r '.[]' | paste -sd, -)
PRIVATE_SUBNET_IDS=$(terraform output -json private_subnet_ids | jq -r '.[]' | paste -sd, -)

# Specify the path to your SSH public key
SSH_PUBLIC_KEY_PATH=~/.ssh/my-key.pub

# Create the Kops cluster
kops create cluster \
  --cloud=aws \
  --name=kops.indojeans.in \
  --state=${KOPS_STATE_STORE} \
  --master-zones=ap-south-1a,ap-south-1b,ap-south-1c \
  --zones=ap-south-1a,ap-south-1b,ap-south-1c \
  --node-count=3 \
  --topology private \
  --networking kopeio-vxlan \
  --node-size=t3.medium \
  --control-plane-size=t3.medium \
  --network-id=${VPC_ID} \
  --subnets=${PRIVATE_SUBNET_IDS} \
  --dns-zone=indojeans.in
  --ssh-public-key=${SSH_PUBLIC_KEY_PATH}
