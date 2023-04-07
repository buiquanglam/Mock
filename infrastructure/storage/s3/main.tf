#
# Variables
#

variable "environment" {
}

variable "eks_oidc_url" {
}

variable "eks_oidc_arn" {
}

#
# Resources
#

#
# Production
#
resource "aws_s3_bucket" "fsoft_mock_dev" {
  bucket = "storage.dev.fsoft.mock.project"

  tags = {
    Name        = "s3_fosft_mock_dev"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_cors_configuration" "fsoft_mock_dev" {
  bucket = aws_s3_bucket.fsoft_mock_dev.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "GET"]
    allowed_origins = ["*"]
  }
}

data "aws_iam_policy_document" "iam_policy_document_fsoft_mock_dev" {
  statement {
    sid       = "1"
    actions   = ["s3:*"]
    resources = ["${aws_s3_bucket.fsoft_mock_dev.arn}/*", aws_s3_bucket.fsoft_mock_dev.arn]
  }

  statement {
    sid       = "2"
    actions   = ["ses:*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "iam_policy_fsoft_mock_dev" {
  name   = "eks_policy_fsoft_mock_dev"
  policy = data.aws_iam_policy_document.iam_policy_document_fsoft_mock_dev.json
}

data "aws_iam_policy_document" "iam_policy_document_assume_fsoft_mock_dev" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "${var.eks_oidc_url}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      type        = "Federated"
      identifiers = [var.eks_oidc_arn]
    }
  }
}

resource "aws_iam_role" "iam_role_fsoft_mock_dev" {
  name               = "eks_fsoft_mock_dev"
  assume_role_policy = data.aws_iam_policy_document.iam_policy_document_assume_fsoft_mock_dev.json
}

resource "aws_iam_role_policy_attachment" "iam_policy_attachment_fsoft_mock_dev" {
  role       = aws_iam_role.iam_role_fsoft_mock_dev.name
  policy_arn = aws_iam_policy.iam_policy_fsoft_mock_dev.arn
}


#
# Output
#
