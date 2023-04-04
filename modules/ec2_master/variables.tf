variable "vpc_security_group_ids" {
  description = "VPC security group id"
  type        = list(string)
  default     = null
}

variable "subnet_id_master" {
  description = "Subnet id master"
  type        = string
  default     = null
}

variable "key_name" {
  description = "Keyname"
  type        = string
  default     = null
}
