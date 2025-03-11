include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git?ref=v20.34.0"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id          = "vpc-123456"
    private_subnets = ["subnet-123", "subnet-456", "subnet-789"]
    public_subnets  = ["subnet-123", "subnet-456", "subnet-789"]
  }
}

inputs = {
  cluster_name    = "dev-lovevery-challenge"
  cluster_version = "1.31"

  vpc_id                                   = dependency.vpc.outputs.vpc_id
  subnet_ids                               = concat(dependency.vpc.outputs.private_subnets, dependency.vpc.outputs.public_subnets)
  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  cluster_compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }

  tags = {
    Environment = "dev"
    Owner       = "Dev Team"
  }
}
