provider "aws" {
  profile    = "phuc-edu"
  region     = "eu-west-3"
  shared_credentials_file = file(var.credentials_path)
}

// backend s3 is for remote state back up -> will not use for now
#terraform {
#  required_version = "~>0.12"
#  backend "s3" {
#    region = "eu-west-3"
#    bucket = "phucawsbucket"
#    key    = "tfstates/"
#  }
#}

terraform {
  required_providers {
    aws = {
    source  = "hashicorp/aws"
    version = "~> 3.27"
    }
  }
  required_version = ">= 0.14.9"
}



module "vpc" {
  source = "./modules/vpc"
  app_name = var.app_name
  stage = var.stage
  database_port = var.database_port
}

module "aws-rds" {
  source = "./modules/aws-rds"
  app_name = var.app_name
  stage = var.stage
  subnet_id_a = module.vpc.subnet_server_id_a
  subnet_id_b = module.vpc.subnet_server_id_b
  instance_type = var.rds_instance_type
  security_group = module.vpc.database_security_group_id
  database_user = var.database_user
  database_password = var.database_password
  database_port = var.database_port
}

module "http-server" {
  source = "./modules/http-server"
  app_name = var.app_name
  stage = var.stage
  ssh_key_name = var.ssh_key_name
  subnet_id = module.vpc.subnet_server_id_a
  vpc_security_group_ids = module.vpc.vpc_security_group_ids
  instance_type = var.instance_type
  elastic_ip_allocation_id = var.http_server_elastic_ip_allocation_id
}
