provider "aws" {
  region = var.region
}

# S3 Backend for Terraform State
terraform {
  backend "s3" {
    bucket  = "my-terraform-state-bucket-flameflashy"
    key     = "ecs-cluster/terraform.tfstate"
    region  = "eu-central-1"
    encrypt = true
  }
}