variable "vpc_security_group_ids" {
  description = "VPC security group id"
  type        = list(string)
  default     = null
}

variable "subnet_id_server" {
  description = "Subnet id server"
  type        = string
  default     = null
}

variable "key_name" {
  description = "Keyname"
  type        = string
  default     = null
}
