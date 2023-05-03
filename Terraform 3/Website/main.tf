# configure aws provider
provider "aws" {
  region = var.region  
}

# create vpc 
module "vpc" {
  source             = "../Module/vpc"
  region             = var.region
  project_name       = var.project_name
  vpc_cidr           = var.vpc_cidr
  pub_sub_cidr1      = var.pub_sub_cidr1
  pub_sub_cidr2      = var.pub_sub_cidr2
  priv_app_sub_cidr1 = var.priv_app_sub_cidr1
  priv_app_sub_cidr2 = var.priv_app_sub_cidr2
}