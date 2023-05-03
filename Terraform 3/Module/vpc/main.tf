
# configuring our network for Tenacity IT

# Create a VPC

resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
enable_dns_hostnames = true
enable_dns_support = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# use data source to get all availabilty zones in region
data "aws_availability_zones" "availability_zones" {}

# create public subnet az1
resource "aws_subnet" "pub_sub_cidr1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.pub_sub_cidr1
availability_zone = data.aws_availability_zones.availability_zones.names[0]
map_public_ip_on_launch = true

  tags = {
    Name = "pub_sub_cidr1"
  }
}

resource "aws_subnet" "pub_sub_cidr2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.pub_sub_cidr2
availability_zone = data.aws_availability_zones.availability_zones.names[1]
map_public_ip_on_launch = true

  tags = {
    Name = "pub_sub_cidr2"
  }
}


# create private subnet
resource "aws_subnet" "priv_app_sub_cidr1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.priv_app_sub_cidr1
availability_zone = data.aws_availability_zones.availability_zones.names[2]
map_public_ip_on_launch = false

  tags = {
    Name = "priv_app_sub_cidr1"
  }
}

resource "aws_subnet" "priv_app_sub_cidr2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.priv_app_sub_cidr2
availability_zone = data.aws_availability_zones.availability_zones.names[0]
map_public_ip_on_launch = false

  tags = {
    Name = "priv_app_sub_cidr2"
  }
}


# create public route table
resource "aws_route_table" "pub-route-table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "pub-route-table"
  }
}

# associate the public subnet to the route table
resource "aws_route_table_association" "Public-sub-assoc" {
  subnet_id      = aws_subnet.pub_sub_cidr1.id
  route_table_id = aws_route_table.pub-route-table.id
}


resource "aws_route_table_association" "Public-sub-associ" {
  subnet_id      = aws_subnet.pub_sub_cidr2.id
  route_table_id = aws_route_table.pub-route-table.id
}



# create private route table
resource "aws_route_table" "priv-route-table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "priv-route-table"
  }
}

# associate the private subnet to the route table 
resource "aws_route_table_association" "Private-sub-assoc" {
  subnet_id      = aws_subnet.priv_app_sub_cidr1.id
  route_table_id = aws_route_table.priv-route-table.id
}

resource "aws_route_table_association" "Private-sub-associ" {
  subnet_id      = aws_subnet.priv_app_sub_cidr2.id
  route_table_id = aws_route_table.priv-route-table.id
}


# create internet gateway
resource "aws_internet_gateway" "Prod-igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "Prod-igw"
  }
}

# associate internet gateway with public route table 
resource "aws_route_table" "pub-route-tabl" {
  vpc_id = aws_vpc.vpc.id
route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Prod-igw.id
  }
}


# Creating an Elastic IP for the NAT Gateway!
resource "aws_eip" "Nat-Gateway-EIP" {
  depends_on = [
    aws_internet_gateway.Prod-igw
  ]
  vpc = true
}


# Creating a NAT Gateway!
resource "aws_nat_gateway" "Prod-Nat-gateway" {
  depends_on = [
    aws_eip.Nat-Gateway-EIP
  ]

  # Allocating the Elastic IP to the NAT Gateway!
  allocation_id = aws_eip.Nat-Gateway-EIP.id
  
  # Associating it in the Public Subnet!
  subnet_id = aws_subnet.pub_sub_cidr1.id
  tags = {
    Name = "Prod-Nat-gateway"
  }
}



# Creating a Route Table Association of the NAT Gateway 
# with the Private Subnet!
resource "aws_nat_gateway" "Nat-Gateway-Association" {
  depends_on = [
    aws_internet_gateway.Prod-igw
  ]

#  Private Subnet ID for adding this route table to the DHCP server of Private subnet!
  connectivity_type = "private"
  subnet_id         = aws_subnet.priv_app_sub_cidr2.id
}

# create ec2 for public subnet
resource "aws_instance" "web-server-1" {
    ami = "ami-0f3497daebf127026"
    count = "1"
    subnet_id = aws_subnet.pub_sub_cidr1.id
    instance_type = "t2.micro"
} 

resource "aws_instance" "web-server-2" {
    ami = "ami-0f3497daebf127026"
    count = "1"
    subnet_id = aws_subnet.pub_sub_cidr2.id
    instance_type = "t2.micro"
} 


# create ec2 for private subnet
resource "aws_instance" "Rock-server-1" {
    ami = "ami-0f3497daebf127026"
    count = "1"
    subnet_id = aws_subnet.priv_app_sub_cidr1.id
    instance_type = "t2.micro"
} 

resource "aws_instance" "Rock-server-2" {
    ami = "ami-0f3497daebf127026"
    count = "1"
    subnet_id = aws_subnet.priv_app_sub_cidr2.id
    instance_type = "t2.micro"
} 


# security group for ec2 
resource "aws_security_group" "tf_sg" {
  name        = "tf_sg"
  description = "security group terraform"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tf_sg"
  }
}

# create security group for the database
resource "aws_security_group" "database_security_group" {
  name        = "database security group"
  description = "enable mysql access on port 3306"
  vpc_id      = aws_vpc.vpc.id 

  ingress {
    description      = "mysql access"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = [aws_security_group.tf_sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "database security group"
  }
}


# create the subnet group for the rds instance
resource "aws_db_subnet_group" "database_subnet_group" {
  name         = "database subnet"
  subnet_ids   = [aws_subnet.priv_app_sub_cidr1.id, aws_subnet.priv_app_sub_cidr2.id]
  description  = "subnet for database instance"

  tags   = {
    Name = "database subnet"
  }
}


# create the rds instance
resource "aws_db_instance" "db_instance" {
  engine                  = "mysql"
  engine_version          = "5.7"
  multi_az                = false
  identifier              = "dev-rds-instance"
  username                = "admin"
  password                = "hamoa12345"
  instance_class          = "db.t3.small"
  allocated_storage       = 200
  db_subnet_group_name    = aws_db_subnet_group.database_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.database_security_group.id] 
  availability_zone       =  data.aws_availability_zones.availability_zones.names[2]
  db_name                 = "applicationdb"
  skip_final_snapshot     = true
}