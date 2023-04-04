terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "5.18.3"
    }
  }
}

provider "github" {
  token = chomp(local.token)
}

locals {
  owner                                  = "mnikhoa"
  token                                  = file("~/.github/github-token")
  github_repository_name                 = "demo-1st-pipeline"
  github_repository_description          = "My demo 1st pipeline codebase"
  github_repository_webhook_content_type = "json"
  github_repository_webhook_insecure_ssl = false
  github_repository_webhook_active       = true
  github_repository_webhook_events       = ["push"]
  visibility_public                      = "public"
  visibility_private                     = "private"
  vulnerability_alerts                   = true

  tags = {
    "Owner" = local.owner
  }
}

resource "github_repository" "mnikhoa_demo_1st_pipeline" {
  name                 = local.github_repository_name
  description          = local.github_repository_description
  visibility           = local.visibility_public
  vulnerability_alerts = local.vulnerability_alerts
}

resource "github_repository_webhook" "mnikhoa_demo_1st_pipeline_webhook" {
  repository = github_repository.mnikhoa_demo_1st_pipeline.name

  configuration {
    url          = var.demo_1st_pipeline_webhook
    content_type = local.github_repository_webhook_content_type
    insecure_ssl = local.github_repository_webhook_insecure_ssl
  }

  active = local.github_repository_webhook_active
  events = local.github_repository_webhook_events
}

output "mnikhoa_demo_1st_pipeline_https_link" {
  description = "mnikhoa demo 1st pipeline https link"
  value       = try(github_repository.mnikhoa_demo_1st_pipeline.http_clone_url, "")
}
