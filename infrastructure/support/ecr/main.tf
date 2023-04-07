variable "repositories" {
  type = list(string)
}

#
# Resources
#

resource "aws_ecr_repository" "ecr_repositories" {
  for_each = toset(var.repositories)
  name = each.value
  image_scanning_configuration {
    scan_on_push = false
  }

  tags = {
    Name = each.value
  }
}

resource "aws_ecr_lifecycle_policy" "ecr_repositories_lifecycle_policy" {
  for_each = toset(var.repositories)
  repository = each.value

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Auto removal of all un-tagged images",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 1
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF

  depends_on = [
    aws_ecr_repository.ecr_repositories
  ]
}
