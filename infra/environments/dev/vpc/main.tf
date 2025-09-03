terraform {
  backend "s3" {
    bucket         = "drazex-eks-terraform-statefiles"
    key            = "dev/vpc/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "drazex-eks-terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-2"
}

module "vpc" {
  source = "../../../modules/vpc"

  environment           = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

# Outputs
output "drazex_eks_vpc_id" {
  value = module.vpc.vpc_id
}

output "drazex_eks_vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "drazex_eks_public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "drazex_eks_private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "drazex_eks_internet_gateway_id" {
  value = module.vpc.internet_gateway_id
}

output "drazex_eks_nat_gateway_ids" {
  value = module.vpc.nat_gateway_ids
}