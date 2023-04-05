locals {
  owner                       = "khoamd"
  suffixed                    = "terraform"
  most_recent                 = true
  owners                      = ["099720109477"]
  filter_name                 = ["name", ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]]
  filter_root_device_type     = ["root-device-type", ["ebs"]]
  filter_virtualization_type  = ["virtualization-type", ["hvm"]]
  instance_type               = "t2.micro"
  region                      = "us-east-1"
  availability_zone_master    = "b"
  associate_public_ip_address = true
  delete_on_termination       = true
  encrypted                   = true
  volume_size                 = "8"
  volume_type                 = "gp2"
  private_key_directory       = "~/.ssh"
  project_directory           = "~/.lab/demo-1st-pipeline"
  node_config_file            = "node_config.sh"
  destination                 = "/home/ubuntu/"
  protocol                    = "ssh"
  host_os                     = "ubuntu"

  tags = {
    "Owner" = local.owner
  }
}

data "aws_ami" "khoamd_ami" {
  most_recent = local.most_recent
  owners      = local.owners

  filter {
    name   = local.filter_name[0]
    values = local.filter_name[1]
  }

  filter {
    name   = local.filter_root_device_type[0]
    values = local.filter_root_device_type[1]
  }

  filter {
    name   = local.filter_virtualization_type[0]
    values = local.filter_virtualization_type[1]
  }
}

resource "aws_instance" "khoamd_ec2_master" {
  ami                         = data.aws_ami.khoamd_ami.id
  instance_type               = local.instance_type
  availability_zone           = "${local.region}${local.availability_zone_master}"
  vpc_security_group_ids      = var.vpc_security_group_ids
  subnet_id                   = var.subnet_id_master
  key_name                    = var.key_name
  associate_public_ip_address = local.associate_public_ip_address

  root_block_device {
    delete_on_termination = local.delete_on_termination
    encrypted             = local.encrypted
    volume_size           = local.volume_size
    volume_type           = local.volume_type
  }

  tags = {
    "Owner" = local.owner
    "Name"  = "${local.owner}-master-${local.suffixed}-tags"
  }

  provisioner "file" {
    source      = pathexpand("${local.project_directory}/${local.node_config_file}")
    destination = pathexpand("${local.destination}/${local.node_config_file}")
    connection {
      type        = local.protocol
      user        = local.host_os
      private_key = file("${local.private_key_directory}/${local.owner}-${local.suffixed}.pem")
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt-get update",
      "sudo apt install software-properties-common pass -y",
      "sudo apt-get -y install build-essential git cmake nano tar zip curl unzip tree pkg-config python3-dev",
      "sudo chmod u+x node_config.sh",
      "sudo sh node_config.sh"
    ]
    connection {
      type        = local.protocol
      user        = local.host_os
      private_key = file("${local.private_key_directory}/${local.owner}-${local.suffixed}.pem")
      host        = self.public_ip
    }
  }
}

output "master_public_ip" {
  description = "master public IP"
  value       = try(aws_instance.khoamd_ec2_master.public_ip, "")
}

output "master_host_os" {
  description = "master host os"
  value       = try(local.host_os, "")
}

output "master_private_key_directory" {
  description = "master private key directory"
  value       = try(local.private_key_directory, "")
}

output "master_owner" {
  description = "master owner"
  value       = try(local.owner, "")
}

output "master_suffixed" {
  description = "master suffixed"
  value       = try(local.suffixed, "")
}

output "master_key_pair_pem_file" {
  description = "master key pair pem file"
  value       = try(pathexpand("${local.private_key_directory}/${local.owner}-${local.suffixed}.pem"), "")
}
