#value
account_id = "541253215789"
project    = "packer-tuankn"
env        = "tuankn"
profile    = "packer-tuankn"
region     = "us-west-2"

vpc_cidr               = "192.168.100.0/24"
number_public_subnets  = 3
number_private_subnets = 3
public_subnets_cidr = {
  "0" : "192.168.100.16/28"
  "1" : "192.168.100.32/28"
  "2" : "192.168.100.48/28"
}
private_subnets_cidr = {
  "0" : "192.168.100.64/28"
  "1" : "192.168.100.80/28"
  "2" : "192.168.100.96/28"
}

bastion_instance_type = "t3.micro"
number_web_instances  = 1
web_instance_type     = "t3.micro"
number_app_instances  = 1
app_instance_type     = "t3.micro"

ssh_allow_cidr = "0.0.0.0/0"
