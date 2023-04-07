variable "environment" {
}

variable "eks" {
  type = object({
    public_subnet_ids    = list(string)
    private_subnet_ids   = list(string)
    private_subnet_zones = list(string)
    sg_id                = string
    alb_id = string
  })
}

variable "ami_id" {
  # https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html
  default = "ami-01bb732da5029d896"
}

#
# Resources
#

# IAM for Control Plane
resource "aws_iam_role" "iam_role_eks_cluster" {
  name = "eks_role_prod_cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "role_policy-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.iam_role_eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "role_policy-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.iam_role_eks_cluster.name
}

resource "aws_eks_cluster" "prod_eks" {
  name     = "fsoft_mock_global_eks"
  role_arn = aws_iam_role.iam_role_eks_cluster.arn

  vpc_config {
    subnet_ids = concat(var.eks.public_subnet_ids, var.eks.private_subnet_ids)
    # https://aws.amazon.com/about-aws/whats-new/2020/04/amazon-eks-managed-node-groups-allow-fully-private-cluster-networking/
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  tags = {
    Role        = "EKS Cluster"
    Environment = var.environment
  }

  depends_on = [
    aws_iam_role_policy_attachment.role_policy-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.role_policy-AmazonEKSServicePolicy,
  ]
}

# IAM for Worker Plane
resource "aws_iam_role" "iam_role_eks_node_group" {
  name = "eks_role_prod_node_group"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

data "aws_iam_policy_document" "iam_policy_document_eks_node_autoscaler" {
  # see https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md
  statement {
    sid = "1"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeLaunchTemplateVersions"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "iam_policy_eks_node_autoscaler" {
  name   = "eks_policy_autoscaler"
  policy = data.aws_iam_policy_document.iam_policy_document_eks_node_autoscaler.json
}

resource "aws_iam_role_policy_attachment" "role_policy-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.iam_role_eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "role_policy-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.iam_role_eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "role_policy-AutoScaler" {
  policy_arn = aws_iam_policy.iam_policy_eks_node_autoscaler.arn
  role       = aws_iam_role.iam_role_eks_node_group.name
}

resource "aws_iam_instance_profile" "instance_profile_eks_asg" {
  name = "instance_profile_eks_asg"
  role = aws_iam_role.iam_role_eks_node_group.name
}

module "asg" {
  source      = "./asg"
  environment = var.environment
  eks = {
    name                 = aws_eks_cluster.prod_eks.name
    iam_instance_profile = aws_iam_instance_profile.instance_profile_eks_asg.name
    private_subnet_ids   = var.eks.private_subnet_ids
    private_subnet_zones = var.eks.private_subnet_zones
    sg_ids = [
      aws_eks_cluster.prod_eks.vpc_config[0].cluster_security_group_id,
      var.eks.sg_id
    ]
    ami_id = var.ami_id
    alb_id = var.eks.alb_id
  }
}


#
# Output
#

output "oidc_url" {
  value = trimprefix(aws_eks_cluster.prod_eks.identity[0].oidc[0].issuer, "https://")
}

output "cluster_name" {
  value = aws_eks_cluster.prod_eks.name
}
