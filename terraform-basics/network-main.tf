data "aws_region" "current" {}

resource "aws_vpc" "main-vpc" {
  cidr_block  = "10.0.0.0/16"
  #enable_dns_support = "true" #gives you an internal domain name
  enable_dns_hostnames = true #gives you an internal host name
  instance_tenancy = "default" #what is this?
}
#instance_tenancy: if it is true, your ec2 will be the only instance
#in an AWS physical hardware. Sounds good but expensive.

# Create Internet Gateway and attach it to VPC
resource "aws_internet_gateway" "IGW" {
   vpc_id = aws_vpc.main-vpc.id
   }

resource "aws_subnet" "myprivatesubnet" {
   vpc_id =  aws_vpc.main-vpc.id
   cidr_block = "10.0.1.0/24"
   availability_zone = "eu-west-2a"
 }

 resource "aws_subnet" "myprivatesubnet2" {
    vpc_id =  aws_vpc.main-vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "eu-west-2b"
}

resource "aws_subnet" "mypublicsubnet" {
   vpc_id =  aws_vpc.main-vpc.id
   cidr_block = "10.0.0.0/24"
   availability_zone = "eu-west-2a"
 }

 # Create Elastic IP for the IGW
resource "aws_eip" "myEIP" {
    vpc = true
    instance = aws_instance.server.id
  }

# Create NAT Gateway resource and attach it to the VPC
/// Use this when you want to connect your private subnet to the internet
// In this project we will not use it for now
#resource "aws_nat_gateway" "NAT-GW" {
#    allocation_id = aws_eip.myEIP.id
#    subnet_id = aws_subnet.mypublicsubnet.id
#  }

# DB subnet
resource "aws_db_subnet_group" "dbsubnet_group" {
  name       = "dbsubnet_group"
  subnet_ids = [aws_subnet.myprivatesubnet.id, aws_subnet.myprivatesubnet2.id]

  tags = {
    Name = "dbsubnet_group"
  }
}

# Security and Ports
resource "aws_security_group" "server-sg" {
    vpc_id = aws_vpc.main-vpc.id

    egress {
        description = "Allow all outbound traffic"
        from_port = 0
        to_port = 0
        protocol = -1  #allow all
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "Allow SSH from any IP"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        // This means, all ip address are allowed to ssh !
        // Do not do it in the production.
        // Put your office or home address in it!
        cidr_blocks = ["0.0.0.0/0"]
    }
    //setting up port 80 to access to server?
    ingress {
        description = "Allow all traffic through http"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
      Name = "server-sg"
    }
}

# Database Security groups
resource "aws_security_group" "db-sg" {
    name = "db-sg"
    vpc_id = aws_vpc.main-vpc.id

    ingress {
        description = "Allow only traffic from the ec2 server"
        from_port = 5432
        to_port = 5432
        protocol = "tcp"
        security_groups = [aws_security_group.server-sg.id]
    }
    tags = {
      Name = "db-sg"
    }
}

#
