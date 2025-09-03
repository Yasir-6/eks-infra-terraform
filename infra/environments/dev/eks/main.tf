terraform {
  backend "s3" {
    bucket         = "drazex-eks-terraform-statefiles"
    key            = "dev/eks/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "drazex-eks-terraform-state-lock"
    encrypt        = true
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "drazex-eks-terraform-statefiles"
    key    = "dev/vpc/terraform.tfstate"
    region = "us-east-2"
  }
}

provider "aws" {
  region = "us-east-2"
}

module "eks" {
  source = "../../../modules/eks"

  environment            = "dev"
  vpc_id                = data.terraform_remote_state.vpc.outputs.drazex_eks_vpc_id
  vpc_cidr              = data.terraform_remote_state.vpc.outputs.drazex_eks_vpc_cidr_block
  private_subnet_ids    = data.terraform_remote_state.vpc.outputs.drazex_eks_private_subnet_ids
  kubernetes_version    = var.kubernetes_version
  endpoint_public_access = var.endpoint_public_access
  public_access_cidrs   = var.public_access_cidrs
  cluster_log_types     = var.cluster_log_types
  log_retention_days    = var.log_retention_days
  node_instance_types   = var.node_instance_types
  capacity_type         = var.capacity_type
  ami_type              = var.ami_type
  disk_size             = var.disk_size
  desired_size          = var.desired_size
  max_size              = var.max_size
  min_size              = var.min_size
  vpc_cni_version       = var.vpc_cni_version
  coredns_version       = var.coredns_version
  kube_proxy_version    = var.kube_proxy_version
  ebs_csi_version       = var.ebs_csi_version
  efs_csi_version       = var.efs_csi_version
  enable_guardduty_agent = var.enable_guardduty_agent
  enable_adot           = var.enable_adot
}

# Outputs
output "drazex_eks_cluster_id" {
  value = module.eks.cluster_id
}

output "drazex_eks_cluster_arn" {
  value = module.eks.cluster_arn
}

output "drazex_eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "drazex_eks_cluster_name" {
  value = module.eks.cluster_name
}

output "drazex_eks_cluster_version" {
  value = module.eks.cluster_version
}

output "drazex_eks_cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "drazex_eks_node_security_group_id" {
  value = module.eks.node_security_group_id
}

output "drazex_eks_node_group_arn" {
  value = module.eks.node_group_arn
}

output "drazex_eks_cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "drazex_eks_cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}