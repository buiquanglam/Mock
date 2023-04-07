variable "environment" {
}

variable "vpc" {
  type = object({
    default_az = string
    cidr_block = string
    azs = list(string)
    public_cidrs = list(string)
    private_cidrs = list(string)
  })
}

#
# Resources
#

module "vpc" {
  source = "./vpc"
  environment = var.environment
  vpc = var.vpc
}

module "alb" {
  source = "./alb"
  name = "ducdv20-alb"
  vpc_id = module.vpc.vpc_id
  environment = var.environment
  public_subnet_ids = module.vpc.vpc_subnet_public_ids
}

module "eks" {
  source = "./eks"
  environment = var.environment
  eks = {
    public_subnet_ids = module.vpc.vpc_subnet_public_ids
    private_subnet_ids = module.vpc.vpc_subnet_private_ids
    private_subnet_zones = var.vpc.azs
    sg_id = module.vpc.vpc_sg_id
    alb_id = module.alb.alb_id
  }
}


#
# Output
#

output "oidc_url" {
  value = module.eks.oidc_url
}

output "vpc_nat_public_ip" {
  value = module.vpc.vpc_nat_public_ip
}

output "public_subnet_ids" {
  value = module.vpc.vpc_subnet_public_ids
}

output "private_subnet_ids" {
  value = module.vpc.vpc_subnet_private_ids
  
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
