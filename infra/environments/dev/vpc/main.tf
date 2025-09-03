terraform {
  backend "s3" {
    bucket         = "hutch-eks-terraform-statefiles"
    key            = "dev/vpc/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "eks-terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-2"
}

module "vpc" {
  source = "../../../modules/vpc"

  environment            = "dev"
  vpc_cidr              = "10.1.0.0/16"
  availability_zones    = ["us-east-2a", "us-east-2b"]
  public_subnet_cidrs   = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnet_cidrs  = ["10.1.3.0/24", "10.1.4.0/24"]
}

# Outputs
output "hutch_eks_vpc_id" {
  value = module.vpc.vpc_id
}

output "hutch_eks_vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "hutch_eks_public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "hutch_eks_private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "hutch_eks_internet_gateway_id" {
  value = module.vpc.internet_gateway_id
}

output "hutch_eks_nat_gateway_ids" {
  value = module.vpc.nat_gateway_ids
}