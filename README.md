# Terraform Kops Cluster Setup

## Prerequisites

Before you begin, make sure you have the following installed:
- [Terraform](https://www.terraform.io/downloads.html)
- [AWS CLI](https://aws.amazon.com/cli/)
- [Kops](https://github.com/kubernetes/kops)
  
## Setup

curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
chmod +x kops-linux-amd64
sudo mv kops-linux-amd64 /usr/local/bin/kops
kops --version 


### 1. Configure AWS Provider

Define the AWS provider and set the region to `ap-south-1`:

git clone https://github.com/pankajthakur888/kops.git

export KOPS_STATE_STORE=s3://kops-indojeans-state-store
11. Create Kops Cluster
Fetch the VPC ID and Subnet IDs using Terraform and create the Kops cluster:

#!/bin/bash

export KOPS_STATE_STORE=s3://kops-indojeans-state-store

# Fetch VPC ID and Subnet IDs using Terraform
VPC_ID=$(terraform output -json vpc_id | jq -r .)
SUBNET_IDS=$(terraform output -json subnet_ids | jq -r '.[]' | paste -sd, -)

# Create the Kops cluster
kops create cluster \
  --name=kops.indojeans.in \
  --state=${KOPS_STATE_STORE} \
  --zones=ap-south-1a,ap-south-1b,ap-south-1c \
  --node-count=3 \
  --node-size=t3.medium \
  --control-plane-size=t3.medium \
  --network-id=${VPC_ID} \
  --subnets=${SUBNET_IDS} \
  --dns-zone=indojeans.in

Make the script executable and run it:

chmod +x kops_install.sh
./kops_install.sh

 kops update cluster --name=kops.indojeans.in --state=s3://kops-indojeans-state-store --yes --admin

 kops validate cluster --name=kops.indojeans.in --state=s3://kops-indojeans-state-store

 kubectl get node

# Delete the Kops cluster

 kops delete cluster   --name=kops.indojeans.in   --state=s3://kops-indojeans-state-store --yes

 terraform destroy
