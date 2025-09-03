############################################
# VPC
############################################

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "drazex-eks-vpc-${var.environment}"
    Environment = var.environment
  }
}

############################################
# Internet Gateway
############################################

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "drazex-eks-igw-${var.environment}"
    Environment = var.environment
  }
}

############################################
# Public Subnets
############################################

resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name                                                          = "drazex-eks-public-subnet-${count.index + 1}-${var.environment}"
    Environment                                                   = var.environment
    "kubernetes.io/role/elb"                                      = "1"
    "kubernetes.io/cluster/drazex-eks-cluster-${var.environment}" = "shared"
  }
}

############################################
# Private Subnets
############################################

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name                                                          = "drazex-eks-private-subnet-${count.index + 1}-${var.environment}"
    Environment                                                   = var.environment
    "kubernetes.io/role/internal-elb"                             = "1"
    "kubernetes.io/cluster/drazex-eks-cluster-${var.environment}" = "shared"
  }
}

############################################
# Elastic IPs for NAT Gateways
############################################

resource "aws_eip" "nat" {
  count  = length(var.public_subnet_cidrs)
  domain = "vpc"

  depends_on = [aws_internet_gateway.main]

  tags = {
    Name        = "drazex-eks-nat-eip-${count.index + 1}-${var.environment}"
    Environment = var.environment
  }
}

############################################
# NAT Gateways
############################################

resource "aws_nat_gateway" "main" {
  count         = length(var.public_subnet_cidrs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  depends_on = [aws_internet_gateway.main]

  tags = {
    Name        = "drazex-eks-nat-gateway-${count.index + 1}-${var.environment}"
    Environment = var.environment
  }
}

############################################
# Route Table for Public Subnets
############################################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "drazex-eks-public-rt-${var.environment}"
    Environment = var.environment
  }
}

############################################
# Route Table Associations for Public Subnets
############################################

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

############################################
# Route Tables for Private Subnets
############################################

resource "aws_route_table" "private" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    Name        = "drazex-eks-private-rt-${count.index + 1}-${var.environment}"
    Environment = var.environment
  }
}

############################################
# Route Table Associations for Private Subnets
############################################

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
