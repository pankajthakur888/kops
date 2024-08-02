# Terraform Kops Cluster Setup
![image](https://github.com/user-attachments/assets/405cbcbb-f7e7-462b-92f0-d3b9a78bb530)

## Prerequisites

Before you begin, make sure you have the following installed:
- [Terraform](https://www.terraform.io/downloads.html)
- [AWS CLI](https://aws.amazon.com/cli/)
- [Kops](https://github.com/kubernetes/kops)
- [AWS_IAM](https://kops.sigs.k8s.io/getting_started/aws/)
  
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
