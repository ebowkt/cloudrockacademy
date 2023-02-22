
# configuring our network for Tenacity IT

# Create a VPC

resource "aws_vpc" "Tenacity-VPC" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
enable_dns_hostnames = true
enable_dns_support = true

  tags = {
    Name = "Tenacity-VPC"
  }
}



# create public subnet
resource "aws_subnet" "Prod-pub-sub1" {
  vpc_id     = aws_vpc.Tenacity-VPC.id
  cidr_block = "10.0.1.0/24"
availability_zone = "eu-west-2a"

  tags = {
    Name = "Prod-pub-sub1"
  }
}

resource "aws_subnet" "Prod-pub-sub2" {
  vpc_id     = aws_vpc.Tenacity-VPC.id
  cidr_block = "10.0.2.0/24"
availability_zone = "eu-west-2b"

  tags = {
    Name = "Prod-pub-sub2"
  }
}


# create private subnet
resource "aws_subnet" "Prod-priv-sub1" {
  vpc_id     = aws_vpc.Tenacity-VPC.id
  cidr_block = "10.0.3.0/24"
availability_zone = "eu-west-2c"

  tags = {
    Name = "Prod-priv-sub1"
  }
}

resource "aws_subnet" "Prod-priv-sub2" {
  vpc_id     = aws_vpc.Tenacity-VPC.id
  cidr_block = "10.0.4.0/24"
availability_zone = "eu-west-2b"

  tags = {
    Name = "Prod-priv-sub2"
  }
}


# create public route table
resource "aws_route_table" "Prod-pub-route-table" {
  vpc_id = aws_vpc.Tenacity-VPC.id

  tags = {
    Name = "Prod-pub-route-table"
  }
}

# associate the public subnet to the route table
resource "aws_route_table_association" "Public-sub-assoc" {
  subnet_id      = aws_subnet.Prod-pub-sub1.id
  route_table_id = aws_route_table.Prod-pub-route-table.id
}


resource "aws_route_table_association" "Public-sub-associ" {
  subnet_id      = aws_subnet.Prod-pub-sub2.id
  route_table_id = aws_route_table.Prod-pub-route-table.id
}



# create private route table
resource "aws_route_table" "Prod-priv-route-table" {
  vpc_id = aws_vpc.Tenacity-VPC.id

  tags = {
    Name = "Prod-priv-route-table"
  }
}

# associate the private subnet to the route table 
resource "aws_route_table_association" "Private-sub-assoc" {
  subnet_id      = aws_subnet.Prod-priv-sub1.id
  route_table_id = aws_route_table.Prod-priv-route-table.id
}

resource "aws_route_table_association" "Private-sub-associ" {
  subnet_id      = aws_subnet.Prod-priv-sub2.id
  route_table_id = aws_route_table.Prod-priv-route-table.id
}


# create internet gateway
resource "aws_internet_gateway" "Prod-igw" {
  vpc_id = aws_vpc.Tenacity-VPC.id

  tags = {
    Name = "Prod-igw"
  }
}

# associate internet gateway with public route table 
resource "aws_route_table" "Prod-pub-route-tabl" {
  vpc_id = aws_vpc.Tenacity-VPC.id
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
  subnet_id = aws_subnet.Prod-pub-sub1.id
  tags = {
    Name = "Prod-Nat-gateway"
  }
}



# Creating an Route Table Association of the NAT Gateway 
# with the Private Subnet!
resource "aws_nat_gateway" "Nat-Gateway-Association" {
  depends_on = [
    aws_internet_gateway.Prod-igw
  ]

#  Private Subnet ID for adding this route table to the DHCP server of Private subnet!
  connectivity_type = "private"
  subnet_id         = aws_subnet.Prod-priv-sub2.id
}



