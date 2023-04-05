locals {
  owner                       = "khoamd"
  suffixed                    = "terraform"
  most_recent                 = true
  owners                      = ["099720109477"]
  filter_name                 = ["name", ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]]
  filter_root_device_type     = ["root-device-type", ["ebs"]]
  filter_virtualization_type  = ["virtualization-type", ["hvm"]]
  instance_type               = "t2.medium"
  region                      = "us-east-1"
  availability_zone_server    = "a"
  associate_public_ip_address = true
  delete_on_termination       = true
  encrypted                   = true
  volume_size                 = "10"
  volume_type                 = "gp2"
  private_key_directory       = "~/.ssh"
  project_directory           = "~/.lab/demo-1st-pipeline"
  server_config_file          = "server_config.sh"
  template_file_directory     = "~/.lab/demo-1st-pipeline/modules/ec2_server"
  template_file_windows       = "windows-triggers.tpl"
  prometheus_file             = "prometheus.yml"
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

resource "aws_instance" "khoamd_ec2_server" {
  ami                         = data.aws_ami.khoamd_ami.id
  instance_type               = local.instance_type
  availability_zone           = "${local.region}${local.availability_zone_server}"
  vpc_security_group_ids      = var.vpc_security_group_ids
  subnet_id                   = var.subnet_id_server
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
    "Name"  = "${local.owner}-jenkins-server-${local.suffixed}-tags"
  }

  provisioner "file" {
    source      = pathexpand("${local.project_directory}/${local.server_config_file}")
    destination = pathexpand("${local.destination}/${local.server_config_file}")
    connection {
      type        = local.protocol
      user        = local.host_os
      private_key = file("${local.private_key_directory}/${local.owner}-${local.suffixed}.pem")
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = pathexpand("${local.project_directory}/${local.prometheus_file}")
    destination = pathexpand("${local.destination}/${local.prometheus_file}")
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
      "sudo chmod u+x server_config.sh",
      "sudo sh server_config.sh",
      "sudo usermod -aG docker jenkins",
      "sudo service jenkins restart"
    ]
    connection {
      type        = local.protocol
      user        = local.host_os
      private_key = file("${local.private_key_directory}/${local.owner}-${local.suffixed}.pem")
      host        = self.public_ip
    }
  }
}

resource "null_resource" "null_resource_server" {
  triggers = {
    id = timestamp()
  }

  provisioner "local-exec" {
    command = templatefile(pathexpand("${local.template_file_directory}/${local.template_file_windows}"), {
      hostnameServer       = aws_instance.khoamd_ec2_server.public_ip,
      userServer           = local.host_os,
      identityfileServer   = pathexpand("${local.private_key_directory}/${local.owner}-${local.suffixed}.pem"),
      keygenFileNameServer = "${local.owner}-${local.suffixed}.pem"
    })
    interpreter = ["Powershell", "-Command"]
    # interpreter = ["bash", "-c"]
  }

  depends_on = [
    aws_instance.khoamd_ec2_server
  ]
}

resource "null_resource" "null_resource_server_transfer" {
  triggers = {
    id = timestamp()
  }

  provisioner "file" {
    source      = pathexpand("${local.project_directory}/${local.prometheus_file}")
    destination = pathexpand("${local.destination}/${local.prometheus_file}")
    connection {
      type        = local.protocol
      user        = local.host_os
      private_key = file("${local.private_key_directory}/${local.owner}-${local.suffixed}.pem")
      host        = aws_instance.khoamd_ec2_server.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt-get update",
      "sudo chmod u+x prometheus.yml",
      "sudo docker stop prometheus_container",
      "sudo docker rm -f prometheus_container",
      "sudo docker run --name prometheus_container -itd -p 9090:9090 -v /home/ubuntu/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus"
    ]
    connection {
      type        = local.protocol
      user        = local.host_os
      private_key = file("${local.private_key_directory}/${local.owner}-${local.suffixed}.pem")
      host        = aws_instance.khoamd_ec2_server.public_ip
    }
  }

  depends_on = [
    aws_instance.khoamd_ec2_server
    , null_resource.null_resource_server
  ]
}

output "server_public_ip" {
  description = "Server public IP"
  value       = try(aws_instance.khoamd_ec2_server.public_ip, "")
}

output "server_host_os" {
  description = "Server host os"
  value       = try(local.host_os, "")
}

output "server_private_key_directory" {
  description = "Server private key directory"
  value       = try(local.private_key_directory, "")
}

output "server_owner" {
  description = "Server owner"
  value       = try(local.owner, "")
}

output "server_suffixed" {
  description = "Server suffixed"
  value       = try(local.suffixed, "")
}

output "server_key_pair_pem_file" {
  description = "Server key pair pem file"
  value       = try(pathexpand("${local.private_key_directory}/${local.owner}-${local.suffixed}.pem"), "")
}
