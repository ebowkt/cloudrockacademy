output "region" {
  value = var.region
}

output "project_name" {
  value = var.project_name
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "pub_sub_cidr1_id" {
  value = aws_subnet.pub_sub_cidr1.id
}

output "pub_sub_cidr2_id" {
  value = aws_subnet.pub_sub_cidr2.id
}

output "priv_app_sub_cidr1_id" {
  value = aws_subnet.priv_app_sub_cidr1.id
}

output "priv_app_sub_cidr2_id" {
  value = aws_subnet.pub_sub_cidr2.id
}

output "internet_gateway" {
  value = aws_internet_gateway.Prod-igw
}