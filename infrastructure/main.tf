
variable "aws" {
  type = object({
    region = string
    region_az = string
    region_azs = list(string)
    aws_access_key_id = string
    aws_secret_acess_key = string
  })
}

provider "aws" {
  region = var.aws.region
}

variable "ecr_repositories" {
  type = list(string)
}

variable "gitlab_info" {
  type = object({
    gitlab_server = string
    register_token = string
  })

}

module "global" {
  source = "./global"
  environment = "global"

  vpc = {
    default_az = var.aws.region_az
    cidr_block = "172.28.0.0/16"
    azs = var.aws.region_azs
    public_cidrs = ["172.28.0.0/20", "172.28.16.0/20", "172.28.32.0/20"]
    private_cidrs = ["172.28.128.0/20", "172.28.144.0/20", "172.28.160.0/20"]
  }
}

module "support" {
  source = "./support"
  environment = "global"
  ecr_repositories = var.ecr_repositories
  eks_oidc_url = module.global.oidc_url
}



module "storage" {
  source = "./storage"
  environment = "global"
  eks_oidc_url = module.global.oidc_url
  eks_oidc_arn = module.support.eks_oidc_arn
}


//provisioning ec2 cicd server
resource "tls_private_key" "demo_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "developer-key"
  public_key =  tls_private_key.demo_key.public_key_openssh
}

resource "local_file" "local_key_pair" {
  filename = "${aws_key_pair.ssh-key.key_name}.pem"
  file_permission = "0400"
  content = tls_private_key.demo_key.private_key_pem
}

resource "aws_security_group" "allow_ssh" {
  name        = "cicd_security_grou"
  description = "Allow ssh inbound traffic"
  vpc_id      = module.global.vpc_id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_instance" "ec2_cicd_server" {
  ami = "ami-0a72af05d27b49ccb"
  instance_type = "t2.medium"
  key_name = aws_key_pair.ssh-key.key_name
  security_groups = [ aws_security_group.allow_ssh .id ]
  subnet_id = module.global.public_subnet_ids[0]
  associate_public_ip_address = true
  user_data = base64encode(templatefile("${path.module}/cicd.sh", { 
    gitlab_server = var.gitlab_info.gitlab_server,
    register_token = var.gitlab_info.register_token,
    aws_access_key_id = var.aws.aws_access_key_id ,
    aws_secret_acess_key = var.aws.aws_secret_acess_key,
    region = var.aws.region,
    cluster_name = module.global.cluster_name }))
}

