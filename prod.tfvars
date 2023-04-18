resource "aws_instance" "ec2_instance" {
    instance_type = "t3.medium"
    region = "eu-west-2"
    vpc_cidr = 10.0.0.0/18
    Prod-pub-sub1 = 10.0.11.0/24
    Prod-pub-sub2 = 10.0.13.0/24
    Prod-priv-sub1 = 10.0.15.0/24
    Prod-priv-sub2 = 10.0.17.0/24
} 