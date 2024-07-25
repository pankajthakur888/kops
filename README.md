# Terraform Kops Cluster Setup

## Prerequisites

Before you begin, make sure you have the following installed:
- [Terraform](https://www.terraform.io/downloads.html)
- [AWS CLI](https://aws.amazon.com/cli/)
- [Kops](https://github.com/kubernetes/kops)

## Setup

### 1. Configure AWS Provider

Define the AWS provider and set the region to `ap-south-1`:

```hcl
provider "aws" {
  region = "ap-south-1"
}
2. Create S3 Bucket for Kops State Storage
Create an S3 bucket to store the state of your Kops cluster:

hcl
Copy code
resource "aws_s3_bucket" "state_bucket" {
  bucket = "kops-indojeans-state-store"

  tags = {
    Name = "kops-indojeans-state-store"
  }
}
3. Create DynamoDB Table for State Locking
Create a DynamoDB table to lock the state:

hcl
Copy code
resource "aws_dynamodb_table" "state_lock" {
  name           = "kops-state-lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "kops-state-lock"
  }
}
4. Create VPC
Create a VPC for your cluster:

hcl
Copy code
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "kops-vpc"
  }
}
5. Create Subnets
Create subnets in different availability zones:

hcl
Copy code
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "kops-subnet-1"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "kops-subnet-2"
  }
}

resource "aws_subnet" "subnet3" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-south-1c"
  map_public_ip_on_launch = true
  tags = {
    Name = "kops-subnet-3"
  }
}
6. Create Internet Gateway
Create an internet gateway for the VPC:

hcl
Copy code
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "kops-igw"
  }
}
7. Create Route Table and Associate with Subnets
Create a route table and associate it with the subnets:

hcl
Copy code
resource "aws_route_table" "routetable" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "kops-route-table"
  }
}

resource "aws_route_table_association" "assoc1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.routetable.id
}

resource "aws_route_table_association" "assoc2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.routetable.id
}

resource "aws_route_table_association" "assoc3" {
  subnet_id      = aws_subnet.subnet3.id
  route_table_id = aws_route_table.routetable.id
}
8. Outputs
Output important information for further steps:

hcl
Copy code
output "bucket_name" {
  description = "The name of the S3 bucket for Kops state storage."
  value       = aws_s3_bucket.state_bucket.bucket
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table for Kops state locking."
  value       = aws_dynamodb_table.state_lock.name
}

output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.main.id
}

output "subnet_ids" {
  description = "The IDs of the subnets."
  value       = [
    aws_subnet.subnet1.id,
    aws_subnet.subnet2.id,
    aws_subnet.subnet3.id
  ]
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway."
  value       = aws_internet_gateway.gw.id
}
9. Initialize and Apply Terraform Configuration
Initialize Terraform and apply the configuration:

bash
Copy code
terraform init
terraform apply
10. Set Kops State Store Environment Variable
Set the environment variable for the Kops state store:

bash
Copy code
export KOPS_STATE_STORE=s3://kops-indojeans-state-store
11. Create Kops Cluster
Fetch the VPC ID and Subnet IDs using Terraform and create the Kops cluster:

bash
Copy code
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

chmod +x create_kops_cluster.sh
./create_kops_cluster.sh
