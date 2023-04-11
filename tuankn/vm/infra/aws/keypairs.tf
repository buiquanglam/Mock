#algorithm key
resource "tls_private_key" "bastion" {
  algorithm = "RSA"
}

#create bastion.pem save directory keys
resource "local_file" "bastion" {
  filename          = "${local.private_keyname_path}/bastion.pem"
  sensitive_content = tls_private_key.bastion.private_key_pem
  file_permission   = "0400"
}

#create private key and public key ssh to bastion
resource "aws_key_pair" "bastion" {
  public_key = tls_private_key.bastion.public_key_openssh
  key_name   = "bastion_key"
}

#algorithm key
resource "tls_private_key" "web" {
  algorithm = "RSA"
}

#create web.pem save directory keys
resource "local_file" "web" {
  filename          = "${local.private_keyname_path}/web.pem"
  sensitive_content = tls_private_key.web.private_key_pem
  file_permission   = "0400"
}

#create private key and public key ssh to web
resource "aws_key_pair" "web" {
  public_key = tls_private_key.web.public_key_openssh
  key_name   = "web_key"
}

#algorithm key
resource "tls_private_key" "app" {
  algorithm = "RSA"
}

#create app.pem save directory keys
resource "local_file" "app" {
  filename          = "${local.private_keyname_path}/app.pem"
  sensitive_content = tls_private_key.app.private_key_pem
  file_permission   = "0400"
}

#create private key and public key ssh to app
resource "aws_key_pair" "app" {
  public_key = tls_private_key.app.public_key_openssh
  key_name   = "app_key"
}
