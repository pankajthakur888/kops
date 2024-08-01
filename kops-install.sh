#!/bin/bash

export KOPS_STATE_STORE=s3://kops-indojeans-state-store

# Fetch VPC ID and Subnet IDs using Terraform
VPC_ID=$(terraform output -json vpc_id | jq -r .)
PUBLIC_SUBNET_IDS=$(terraform output -json public_subnet_ids | jq -r '.[]' | paste -sd, -)
PRIVATE_SUBNET_IDS=$(terraform output -json private_subnet_ids | jq -r '.[]' | paste -sd, -)

# Create the Kops cluster
kops create cluster \
  --name=kops.indojeans.in \
  --state=${KOPS_STATE_STORE} \
  --zones=ap-south-1a,ap-south-1b,ap-south-1c \
  --node-count=3 \
  --node-size=t3.medium \
  --control-plane-size=t3.medium \
  --network-id=${VPC_ID} \
  --subnets=${PUBLIC_SUBNET_IDS},${PRIVATE_SUBNET_IDS} \
  --dns-zone=indojeans.in
