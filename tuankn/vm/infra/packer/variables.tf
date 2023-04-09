variable "project" {
  default = "packer-tuankn"
}

variable "region" {
  default = "us-west-2"
}

variable "profile" {
  default = "packer-kntuan"
}

variable "vpc_name" {
  default = "packer-vpc"
}

variable "vpc_cidr" {
  default = "192.168.100.0/24"
}

variable "public_subnet_cidr" {
  default = {
    "0" : "192.168.100.16/28"
    "1" : "192.168.100.32/28"
    "2" : "192.168.100.48/28"
  }
}

variable "build_number" {
  description = "Jenkin build number"
  default     = 1
}

variable "private_keyname" {
  description = "private keyname"
  default     = "packer_id_rsa"
}

variable "ami_spec" {
  description = "AMI spec"
  default = {
    "instance_type" = "t3.micro"
    "ami_desc"      = "Canonical, Ubuntu, 20.04 LTS*"
    "ami_owner"     = "099720109477"
    "volume_type"   = "gp2"
    "volume_size"   = "20"
    "remote_user"   = "ubuntu"
  }
}

variable "ansible_dir_path" {
  description = "Ansible dir path"
  default     = "../.."
}
