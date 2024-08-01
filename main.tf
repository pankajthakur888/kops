provider "aws" {
  region = "ap-south-1"
}

# Variables
variable "region" {
  default = "ap-south-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]
}

variable "private_subnet_cidrs" {
  default = [
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/24"
  ]
}

# Create an S3 bucket for Kops state storage
resource "aws_s3_bucket" "state_bucket" {
  bucket = "kops-indojeans-state-store"
  tags = {
    Name = "kops-indojeans-state-store"
  }
}

# Create a DynamoDB table for state locking
resource "aws_dynamodb_table" "state_lock" {
  name           = "kops-state-lock"
  billing_mode    = "PAY_PER_REQUEST"
  hash_key        = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "kops-state-lock"
  }
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "kops-vpc"
  }
}

# Create public subnets
resource "aws_subnet" "public" {
  count                  = length(var.public_subnet_cidrs)
  vpc_id                 = aws_vpc.main.id
  cidr_block             = element(var.public_subnet_cidrs, count.index)
  availability_zone      = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "kops-public-subnet-${count.index + 1}"
  }
}

# Create private subnets
resource "aws_subnet" "private" {
  count                  = length(var.private_subnet_cidrs)
  vpc_id                 = aws_vpc.main.id
  cidr_block             = element(var.private_subnet_cidrs, count.index)
  availability_zone      = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "kops-private-subnet-${count.index + 1}"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "kops-igw"
  }
}

# Create a NAT gateway for private subnets
resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  tags = {
    Name = "kops-nat-gateway"
  }
}

# Create route tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "kops-public-route-table"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw.id
  }
  tags = {
    Name = "kops-private-route-table"
  }
}

# Associate route tables with subnets
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Create VPC endpoints for private subnets
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.s3"
  route_table_ids   = aws_route_table.private.*.id
  tags = {
    Name = "kops-s3-endpoint"
  }
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.dynamodb"
  route_table_ids   = aws_route_table.private.*.id
  tags = {
    Name = "kops-dynamodb-endpoint"
  }
}

# Outputs
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

output "public_subnet_ids" {
  description = "The IDs of the public subnets."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets."
  value       = aws_subnet.private[*].id
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway."
  value       = aws_internet_gateway.gw.id
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway."
  value       = aws_nat_gateway.gw.id
}

output "vpc_endpoint_s3_id" {
  description = "The ID of the VPC Endpoint for S3."
  value       = aws_vpc_endpoint.s3.id
}

output "vpc_endpoint_dynamodb_id" {
  description = "The ID of the VPC Endpoint for DynamoDB."
  value       = aws_vpc_endpoint.dynamodb.id
}
