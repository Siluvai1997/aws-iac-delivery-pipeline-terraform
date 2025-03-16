# Download any stable version in AWS provider of 2.36.0 or higher in 2.36 train
provider "aws" {
  profile = "default"
  region  = "ca-central-1"
  version = "~> 2.70.0"
  assume_role {
    role_arn     = "arn:aws:iam::495637283141:role/TfRootAssumeIamRole"
    session_name = "terraform"
  }
}

# Require TF version to be same as or greater than 0.12.26
terraform {
  required_version = "~> 0.12.26"
  backend "s3" {
    bucket          = "codebuild-root-tf-tfstate"
    key             = "terraform.tfstate"
    region          = "ca-central-1"
    dynamodb_table  = "codebuild-db-root-tf-locking"
    encrypt        = true
  }
}
