resource "aws_instance" "ec2_instance" {
    instance_type = "t2.nano"
    region = "eu-west-1"
    vpc_cidr = 10.0.0.0/17
    Prod-pub-sub1 = 10.0.10.01/24
    Prod-pub-sub2 = 10.0.12.01/24
    Prod-priv-sub1 = 10.0.14.01/24
    Prod-priv-sub2 = 10.0.16.01/24
} 