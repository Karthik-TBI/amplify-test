terraform {
  backend "s3" {
    bucket         = "tbi-test-s3-terraform-file"
    key            = "project-tbi/singapore/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "tbi-test-lock"
    encrypt        = true
  }
}