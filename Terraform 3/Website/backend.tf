# store the terraform state file in s3
terraform {
  backend "s3" {
    bucket    = "stuff-terraformstate"
    key       = "terraform.tfstate"
    region    = "eu-west-2"
    dynamodb_table = "terraform-baby-s3-backend"
  }
}
