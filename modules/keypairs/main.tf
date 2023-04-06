locals {
  owner                     = "khoamd"
  profile                   = "khoamd"
  region                    = "us-east-1"
  shared_credentials_files  = ["~/.aws/credentials"]
  suffixed                  = "terraform"
  private_key_directory     = "~/.ssh"
  public_key_directory      = "~/.ssh"
  algorithm                 = "RSA"
  rsa_bits                  = 4096

  tags = {
    "Owner" = local.owner
  }
}

resource "tls_private_key" "khoamd_key" {
  algorithm = local.algorithm
  rsa_bits  = local.rsa_bits
}

resource "local_sensitive_file" "khoamd_private_key" {
  filename = pathexpand("${local.private_key_directory}/${local.owner}-${local.suffixed}.pem")
  content  = tls_private_key.khoamd_key.private_key_pem
}

resource "local_sensitive_file" "khoamd_private_key_src" {
  filename = pathexpand("${local.public_key_directory}/${local.owner}-${local.suffixed}.pub")
  content  = tls_private_key.khoamd_key.public_key_openssh
}

resource "aws_key_pair" "khoamd_auth" {
  key_name   = "${local.owner}-${local.suffixed}"
  public_key = tls_private_key.khoamd_key.public_key_openssh
}

output "khoamd_aws_private_key_id" {
  description = "khoamd AWS private key ID"
  value       = try(aws_key_pair.khoamd_auth.id, "")
}

output "khoamd_aws_key_pair_name" {
  description = "The key pair name"
  value       = try(aws_key_pair.khoamd_auth.key_name, "")
}
