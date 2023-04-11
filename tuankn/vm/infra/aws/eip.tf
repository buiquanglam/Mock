//elastic ip for nat-gateway
resource "aws_eip" "nat-gw" {
  vpc = true
}

//elastic ip for basition
resource "aws_eip" "bastion" {
  vpc = true
}
