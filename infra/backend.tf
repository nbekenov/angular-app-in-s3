terraform {
  backend "s3" {
    region         = "us-east-1"
    bucket         = "quest-project-tf-state-files"
    key            = "angular-app-in-s3/terraform.tfstate"
    encrypt        = "true"
    dynamodb_table = "terraform-state"
    profile        = "dev"
  }
}