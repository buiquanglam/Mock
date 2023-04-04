${jsonencode({
    region_name         = var.aws_region_name
    project_name        = var.project_name
    vpc_id              = var.aws_vpc_id
    subnet_id           = var.aws_subnet_id
    private_key         = var.aws_private_key
    public_key          = var.aws_public_key
    security_group_id   = var.aws_security_group_id
    instance_type       = var.aws_instance_type
    ami_desc            = var.aws_ami_desc
    ami_owner           = var.aws_ami_owner
    volume_size         = var.aws_volume_size
    volume_type         = var.aws_volume_type
    remote_user         = var.aws_remote_user
    ansible_dir_path    = var.ansible_dir_path
})}
