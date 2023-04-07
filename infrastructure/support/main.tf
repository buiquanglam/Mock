variable "environment" {
}

variable "ecr_repositories" {
  type = list(string)
}

variable "eks_oidc_url" {
}

module "ecr" {
  source = "./ecr"
  repositories = var.ecr_repositories
}

module "iam" {
  source = "./iam"
  environment = var.environment
  eks_oidc_url = var.eks_oidc_url
}


output "eks_oidc_arn" {
  value = module.iam.eks_oidc_arn
}
