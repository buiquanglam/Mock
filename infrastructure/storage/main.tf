variable "environment" {
}


variable "eks_oidc_url" {
}

variable "eks_oidc_arn" {
}


module "s3" {
  source       = "./s3"
  environment  = var.environment
  eks_oidc_url = var.eks_oidc_url
  eks_oidc_arn = var.eks_oidc_arn
}

