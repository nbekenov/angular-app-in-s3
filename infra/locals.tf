locals {
  default_tags = {
    "environment" = "dev"
    "automation"  = "terraform"
    "project"     = var.application_name
  }

  subdomain = "dev.${var.application_name}.${var.domain_name}"
}