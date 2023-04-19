variable "region" {
        description = "Where vpc is to be created"
        type = string
        default = "eu-west-2"
}

variable "vpc_cidr" {
        description = "Cidr block for the vpc"
        type = string
        default = "10.0.0.0/16"
}

variable "instance_ten" {
        description = "Instance tenancy mode"
        default = "default"
}

variable "dns_hostnames" {
        description = "To enable dns hostname"
        type = bool
        default = true
}

variable "dns_support" {
        description = "To enable dns support"
        type = bool
        default = true
}


variable "instance_name" {
        description = "Name of the instance to be created"
        default = "Rock-server-2"
}

variable "instance_type" {
        default = "t2.micro"
}


variable "ami_id" {
        description = "The AMI to use"
        default = "ami-0f3497daebf127026"
}

variable "number_of_instances" {
        description = "number of instances to be created"
        default = 1
}