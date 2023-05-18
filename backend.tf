terraform {
  backend "s3" {
    bucket         = "terraform-test1-tux"
    key            = "terraform/test1"
    region         = "us-east-1"
    encrypt        = "true"
    dynamodb_table = "terraform-test1-tux-table"
  }
}
