# Terraform Kops Cluster Setup

![image](https://github.com/user-attachments/assets/b1352af0-cce8-46df-9673-8a2d4d1d7bc4) + ![image](https://github.com/user-attachments/assets/d410d855-0cc1-447f-af0e-6f68a546577a) + ![image](https://github.com/user-attachments/assets/25f8a3ef-a562-4d80-a0d8-d066aa0b6827)


## Prerequisites

Before you begin, make sure you have the following installed:
- [Terraform](https://www.terraform.io/downloads.html)
- [AWS CLI](https://aws.amazon.com/cli/)
- [Kops](https://github.com/kubernetes/kops)
  
## Setup
```bash
curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64

chmod +x kops-linux-amd64

sudo mv kops-linux-amd64 /usr/local/bin/kops

kops --version 
```

### Git Clone

```bash
git clone https://github.com/pankajthakur888/kops.git

cd kops
```

### Apply the Terraform Configuration

Run the following commands to apply your Terraform configuration:

```bash
terraform init
terraform validate
terraform apply
```

### Create the Kops cluster

Make the script executable and run it:
```bash
chmod +x kops_install.sh

./kops_install.sh

 kops update cluster --name=kops.indojeans.in --state=s3://kops-indojeans-state-store --yes --admin

 kops validate cluster --name=kops.indojeans.in --state=s3://kops-indojeans-state-store

 kubectl get node
```
### Delete the Kops cluster and VPC

```bash
 kops delete cluster   --name=kops.indojeans.in   --state=s3://kops-indojeans-state-store --yes

 terraform destroy
```
