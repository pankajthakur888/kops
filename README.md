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

### Create the Kops Cluster:
Create the Kops Cluster:
```bash
kops create -f cluster-az.yaml

```
### Update the Kops Cluster:
```bash
kops create -f cluster-az.yaml

```

### The ELB created by kOps will expose the Kubernetes API trough "https" (configured on our ~/.kube/config file):
```bash
grep server ~/.kube/config
```

### ADDING A BASTION HOST TO OUR CLUSTER.¶
We mentioned earlier that we can't add the "--bastion" argument to our "kops create cluster" command if we are using "gossip dns" (a fix it's on the way as we speaks). That forces us to add the bastion afterwards, once the cluster is up and running.

Let's add a bastion here by using the following command:
```bash
kops create instancegroup bastions --role Bastion --subnet utility-ap-south-1a --name=kops.indojeans.in
```

### Delete the Kops cluster and VPC

```bash
 kops delete cluster   --name=kops.indojeans.in   --state=s3://kops-indojeans-state-store --yes

 terraform destroy
```
##### Note :- https://kops.sigs.k8s.io/topology/
