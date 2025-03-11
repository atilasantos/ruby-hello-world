include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=v5.19.0"
}

inputs = {
  vpc_name            = "dev-vpc"
  vpc_cidr            = "10.0.0.0/16"
  azs                 = ["us-east-1a", "us-east-1b"]
  public_subnets      = ["10.0.1.0/24", "10.0.4.0/24"]
  private_subnets     = ["10.0.2.0/24", "10.0.3.0/24"]
  environment         = "dev"

  # Enable NAT Gateway for private subnet access to the internet
  enable_nat_gateway = true
  single_nat_gateway = true

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"  # Tag for internal load balancers (ILB)
  }

  # Additional VPC configuration
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Environment = "dev"
    Owner       = "Dev Team"
  }
}