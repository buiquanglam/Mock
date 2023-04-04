terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.61.0"
    }
  }
}

provider "aws" {
  profile                  = local.profile
  region                   = local.region
  shared_credentials_files = local.shared_credentials_files
}

locals {
  owner                    = "khoamd"
  template_file_directory  = "~/.lab/demo-1st-pipeline"
  template_file_windows    = "windows-triggers.tpl"
  profile                  = "khoamd"
  region                   = "us-east-1"
  shared_credentials_files = ["~/.aws/credentials"]

  tags = {
    "Owner" = local.owner
  }
}

module "keypairs" {
  source = "./modules/keypairs"
}

module "networks" {
  source = "./modules/networks"

  depends_on = [
    module.keypairs
  ]
}

module "ec2_server" {
  source                 = "./modules/ec2_server"
  subnet_id_server       = module.networks.khoamd_subnet_server_id
  vpc_security_group_ids = module.networks.khoamd_sg_id
  key_name               = module.keypairs.khoamd_aws_private_key_id

  depends_on = [
    module.networks
    , module.keypairs
  ]
}

module "ec2_master" {
  source                 = "./modules/ec2_master"
  subnet_id_master       = module.networks.khoamd_subnet_master_id
  vpc_security_group_ids = module.networks.khoamd_sg_id
  key_name               = module.keypairs.khoamd_aws_private_key_id

  depends_on = [
    module.networks
    , module.keypairs
  ]
}

module "ec2_prod" {
  source                 = "./modules/ec2_prod"
  subnet_id_prod         = module.networks.khoamd_subnet_prod_id
  vpc_security_group_ids = module.networks.khoamd_sg_id
  key_name               = module.keypairs.khoamd_aws_private_key_id

  depends_on = [
    module.networks
    , module.keypairs
  ]
}

module "ec2_dev" {
  source                 = "./modules/ec2_dev"
  subnet_id_dev          = module.networks.khoamd_subnet_dev_id
  vpc_security_group_ids = module.networks.khoamd_sg_id
  key_name               = module.keypairs.khoamd_aws_private_key_id

  depends_on = [
    module.networks
    , module.keypairs
  ]
}

resource "null_resource" "null_resource_all" {
  triggers = {
    id = timestamp()
  }

  provisioner "local-exec" {
    command = templatefile(pathexpand("${local.template_file_directory}/${local.template_file_windows}"), {
      hostnameServer       = module.ec2_server.server_public_ip,
      userServer           = module.ec2_server.server_host_os,
      identityfileServer   = pathexpand("${module.ec2_server.server_private_key_directory}/${module.ec2_server.server_owner}-${module.ec2_server.server_suffixed}.pem"),
      keygenFileNameServer = "${module.ec2_server.server_owner}-${module.ec2_server.server_suffixed}.pem",

      hostnameMaster       = module.ec2_master.master_public_ip,
      userMaster           = module.ec2_master.master_host_os,
      identityfileMaster   = pathexpand("${module.ec2_master.master_private_key_directory}/${module.ec2_master.master_owner}-${module.ec2_master.master_suffixed}.pem"),
      keygenFileNameMaster = "${module.ec2_master.master_owner}-${module.ec2_master.master_suffixed}.pem",

      hostnameProd       = module.ec2_prod.prod_public_ip,
      userProd           = module.ec2_prod.prod_host_os,
      identityfileProd   = pathexpand("${module.ec2_prod.prod_private_key_directory}/${module.ec2_prod.prod_owner}-${module.ec2_prod.prod_suffixed}.pem"),
      keygenFileNameProd = "${module.ec2_prod.prod_owner}-${module.ec2_prod.prod_suffixed}.pem",

      hostnameDev       = module.ec2_dev.dev_public_ip,
      userDev           = module.ec2_dev.dev_host_os,
      identityfileDev   = pathexpand("${module.ec2_dev.dev_private_key_directory}/${module.ec2_dev.dev_owner}-${module.ec2_dev.dev_suffixed}.pem"),
      keygenFileNameDev = "${module.ec2_dev.dev_owner}-${module.ec2_dev.dev_suffixed}.pem"
    })
    interpreter = ["Powershell", "-Command"]
    # interpreter = ["bash", "-c"]
  }

  depends_on = [
    module.networks
    , module.keypairs
    , module.ec2_server
    , module.ec2_master
    , module.ec2_prod
    , module.ec2_dev
  ]
}

output "ssh_command_to_server" {
  description = "ssh command to jenkins server"
  value       = try("ssh -i ${module.ec2_server.server_key_pair_pem_file} ${module.ec2_server.server_host_os}@${module.ec2_server.server_public_ip}", "")
}

output "ssh_command_to_workerNode_master" {
  description = "ssh command to remote worker node master"
  value       = try("ssh -i ${module.ec2_master.master_key_pair_pem_file} ${module.ec2_master.master_host_os}@${module.ec2_master.master_public_ip}", "")
}

output "ssh_command_to_workerNode_prod" {
  description = "ssh command to remote worker node prod"
  value       = try("ssh -i ${module.ec2_prod.prod_key_pair_pem_file} ${module.ec2_prod.prod_host_os}@${module.ec2_prod.prod_public_ip}", "")
}

output "ssh_command_to_workerNode_dev" {
  description = "ssh command to remote worker node dev"
  value       = try("ssh -i ${module.ec2_dev.dev_key_pair_pem_file} ${module.ec2_dev.dev_host_os}@${module.ec2_dev.dev_public_ip}", "")
}
