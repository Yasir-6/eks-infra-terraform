# EKS Infrastructure with Terraform

This repository contains Terraform configurations for deploying Amazon EKS (Elastic Kubernetes Service) infrastructure.

## Structure

```
eks-infra-terraform/
├── .github/
│   └── workflows/
│       ├── terraform-deploy.yml
│       └── terraform-destroy.yml
├── infra/
│   ├── environments/
│   │   ├── backend/
│   │   │   └── main.tf
│   │   └── dev/
│   │       ├── vpc/
│   │       │   └── main.tf
│   │       └── eks/
│   │           ├── main.tf
│   │           ├── variables.tf
│   │           └── terraform.tfvars
│   └── modules/
│       ├── vpc/
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       └── eks/
│           ├── main.tf
│           ├── variables.tf
│           └── outputs.tf
├── .gitignore
└── README.md
```

## Deployment Order

1. **Backend Setup**: Deploy S3 bucket and DynamoDB table for state management
2. **VPC**: Deploy VPC with public/private subnets and NAT gateways
3. **EKS**: Deploy EKS cluster with managed node groups

## Manual Deployment

### 1. Deploy Backend
```bash
cd infra/environments/backend
terraform init
terraform plan
terraform apply
```

### 2. Deploy VPC
```bash
cd infra/environments/dev/vpc
terraform init
terraform plan
terraform apply
```

### 3. Deploy EKS
```bash
cd infra/environments/dev/eks
terraform init
terraform plan
terraform apply
```

## CI/CD Deployment

The repository includes GitHub Actions workflows for automated deployment:

- **terraform-deploy.yml**: Deploys VPC and EKS in sequence
- **terraform-destroy.yml**: Destroys EKS and VPC in reverse order

### Required Secrets

Set these secrets in your GitHub repository:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

## Configuration

### EKS Configuration

Edit `infra/environments/dev/eks/terraform.tfvars` to customize:

- Kubernetes version
- Node instance types
- Scaling configuration
- Network access settings

### VPC Configuration

The VPC module creates:
- VPC with DNS support
- Public and private subnets across 2 AZs
- Internet Gateway
- NAT Gateways for private subnet internet access
- Route tables and associations

## Accessing the Cluster

After deployment, configure kubectl:

```bash
aws eks update-kubeconfig --region us-east-2 --name task-app-eks-cluster-dev
```

## Cleanup..

To destroy the infrastructure:

1. Use GitHub Actions destroy workflow, or
2. Manual cleanup in reverse order:
   ```bash
   cd infra/environments/dev/eks && terraform destroy
   cd infra/environments/dev/vpc && terraform destroy
   ```
