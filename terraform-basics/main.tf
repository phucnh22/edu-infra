terraform {
  required_providers {
    aws = {
    source  = "hashicorp/aws"
    version = "~> 3.27"
    }
  }
  required_version = ">= 0.14.9"
}

provider "aws" {
  region = var.aws_region
  profile = "phuc-edu"
  # credentials are config-ed as environment variables
}

# Find an official Ubuntu AMI
data "aws_ami" "ubuntu" {
    most_recent = true
    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }
    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
    filter {
        name   = "architecture"
        values = ["x86_64"]
    }
    owners = ["099720109477"] # Canonical official
}

# EC2 instance
resource "aws_instance" "server" {
    ami = data.aws_ami.ubuntu.id
    instance_type = "t2.micro"
    # VPC
    subnet_id = aws_subnet.mypublicsubnet.id
    # Security Group
    vpc_security_group_ids = [aws_security_group.server-sg.id]
    key_name = aws_key_pair.local_key_pair.key_name
    tags = {
      Name = var.instance_name
    }
}

# Key pair to connect to the instance
resource "aws_key_pair" "local_key_pair" {
    key_name = "local_key_pair"
    public_key = file(var.pub_key_path)
}


# Database instance
resource "aws_db_instance" "postgres_db" {
  allocated_storage      = 5
  engine                 = "postgres"
  name                   = "postgres_db"
  instance_class         = "db.t3.micro"
  username               = var.db_instance_username
  password               = var.db_instance_password
  db_subnet_group_name   = aws_db_subnet_group.dbsubnet_group.name
  vpc_security_group_ids = [aws_security_group.db-sg.id]
  publicly_accessible    = false
  skip_final_snapshot    = true
}
