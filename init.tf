locals {
  name = "jenkins-terraform-kubernetes-demo"
}

provider "aws" {
  version = "= 1.53.0"
  region  = "us-east-1"
}

resource "aws_s3_bucket" "state_bucket" {
  bucket = "${local.name}"
  acl    = "private"
  region = "us-east-1"

  versioning {
    enabled = true
  }
}

resource "aws_dynamodb_table" "state_dynamodb_table_admin" {
  name           = "${local.name}"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  backend "local" {}

  # Will only work when the bucket already exist
  # backend "s3" {
  #   bucket         = "jenkins-terraform-kubernetes-demo"
  #   key            = "state"
  #   region         = "us-east-1"
  #   acl            = "private"
  #   dynamodb_table = "jenkins-terraform-kubernetes-demo"
  # }
}

module "network" {
  source = "./terraform/network"

  providers {
    "aws" = "aws"
  }

  name = "${local.name}"
  cidr = "10.0.0.0/16"
}

module "k8s" {
  source = "./terraform/eks"

  providers {
    "aws" = "aws"
  }

  name              = "${local.name}"
  vpc_id            = "${module.network.vpc_id}"
  allow_ip          = ["173.54.148.252/32"]
  cluster_subnet_id = ["${module.network.private_id}"]
}
