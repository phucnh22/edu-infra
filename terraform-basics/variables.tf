variable "aws_region" {
  description = "The AWS region to create the VPC in."
  default = "eu-west-2"
  type = string
}

## Network variables
# CIDR block for main VPC
#variable "vpc-cidr" {
#default = "10.0.0.0/16"
#}

# CIDR block for public subnets
#variable "pubsubcidr" {
#default = "10.0.0.0/24"
#}

# CIDR block for private subnets
#variable "prisubcidr" {
#default = "10.0.1.0/24"
#}
variable "pub_key_path" {
  default ="~/.ssh/aws_server.pub"
}


variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type = string
  default = "TestInstance"
}

variable "db_instance_username" {
  default = "edu_phuc_db"
}

variable "db_instance_password" {
  default = "12345678"
}
