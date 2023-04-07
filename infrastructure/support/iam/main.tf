variable "environment" {
}

variable "eks_oidc_url" {
}

resource "aws_iam_openid_connect_provider" "iam_oidc_provider_global" {
  url = "https://${var.eks_oidc_url}"
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
}

output "eks_oidc_arn" {
  value = aws_iam_openid_connect_provider.iam_oidc_provider_global.arn
}
