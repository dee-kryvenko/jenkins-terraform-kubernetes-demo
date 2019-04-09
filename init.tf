locals {
  # This is used as ID or prefix for resources
  name = "jenkins-terraform-kubernetes-demo"

  # This is where local kube config is saved
  kubeconfig = "${pathexpand("${path.module}/.kube/config")}"
}

# There is a whole bunch of providers configured below
# Mainly we just pin the versions to get the whole thing reproducible
provider "null" {
  version = "= 1.0.0"
}

provider "local" {
  version = "= 1.1.0"
}

provider "random" {
  version = "= 2.0.0"
}

provider "template" {
  version = "= 1.0.0"
}

provider "external" {
  version = "= 1.0.0"
}

provider "aws" {
  version = "= 1.53.0"
  region  = "us-east-1"
}

# Bucket and DynamoDB below is for TF state file itself
# If you want to use it - uncomment it and s3 backend configuration below
# resource "aws_s3_bucket" "state_bucket" {
#   bucket        = "${local.name}"
#   acl           = "private"
#   region        = "us-east-1"
#   force_destroy = "true"
# }

# resource "aws_dynamodb_table" "state_dynamodb_table_admin" {
#   name           = "${local.name}"
#   read_capacity  = 1
#   write_capacity = 1
#   hash_key       = "LockID"
#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }

terraform {
  backend "local" {}

  # Will only work when the buckets already exist
  # backend "s3" {
  #   bucket         = "jenkins-terraform-kubernetes-demo"
  #   key            = "state"
  #   region         = "us-east-1"
  #   acl            = "private"
  #   dynamodb_table = "jenkins-terraform-kubernetes-demo"
  # }
}

variable "azs" {
  description = "Number of availability zones to use"
}

# This module will create 3 tier network
module "network" {
  source = "./terraform/network"

  providers {
    "aws" = "aws"
  }

  name = "${local.name}"
  cidr = "10.0.0.0/16"
  azs  = "${var.azs}"
}

output "backend_subnets" {
  value = "${module.network.backend_subnets}"
}

output "private_subnets" {
  value = "${module.network.private_subnets}"
}

output "dmz_subnets" {
  value = "${module.network.dmz_subnets}"
}

variable "allow_ip_cidr" {
  description = "Give a CIDR to be whitelisted for k8s API and Ingress"
}

# This module will create EKS cluster
module "k8s" {
  source = "./terraform/eks"

  providers {
    "local"    = "local"
    "external" = "external"
    "aws"      = "aws"
  }

  name              = "${local.name}"
  vpc_id            = "${module.network.vpc_id}"
  allow_ip          = ["${var.allow_ip_cidr}"]
  cluster_subnet_id = ["${keys(module.network.private_subnets)}"]
  kubeconfig        = "${local.kubeconfig}"
}

output "cluster_dns" {
  value = "${module.k8s.cluster_dns}"
}

# Now it's time to configure k8s/helm providers
# Luckily these two supports interpolation
# Using previous modules output here will create implicit dependency
provider "kubernetes" {
  version                = "= 1.4.0"
  host                   = "${module.k8s.cluster_dns}"
  cluster_ca_certificate = "${module.k8s.cluster_ca}"
  token                  = "${module.k8s.cluster_token}"
}

provider "helm" {
  version         = "= 0.7.0"
  install_tiller  = "true"
  service_account = "tiller"

  kubernetes {
    host                   = "${module.k8s.cluster_dns}"
    cluster_ca_certificate = "${module.k8s.cluster_ca}"
    token                  = "${module.k8s.cluster_token}"
  }
}

# When cluster is ready - it's time for some addons
module "k8s-addons" {
  source = "./terraform/k8s-addons"

  providers {
    "null"       = "null"
    "aws"        = "aws"
    "kubernetes" = "kubernetes"
    "helm"       = "helm"
  }

  name       = "${local.name}"
  kubeconfig = "${local.kubeconfig}"

  # TF in current version poorly handles some edge cases with regards to dependencies
  # What is done here - an md5 string based on the output of several resources
  # That will be used for null_resource that then will be used as depends_on to glue the sequence together
  # That will make sure we start deploying addons only when the cluster is ready
  cluster_dependency_id = "${module.k8s.cluster_dependency_id}"

  node_role_arn               = "${module.k8s.node_role_arn}"
  nginx_ingress_chart_version = "1.1.1"
  nginx_ingress_version       = "0.21.0"
}

output "ingress_lb" {
  value = "${module.k8s-addons.ingress_lb}"
}

output "ingress_internal_lb" {
  value = "${module.k8s-addons.ingress_internal_lb}"
}

variable "github_token" {}

# So now that the cluster is fully functional - it's time to deploy jenkins
module "jenkins" {
  source = "./terraform/jenkins"

  providers {
    "null"       = "null"
    "template"   = "template"
    "aws"        = "aws"
    "kubernetes" = "kubernetes"
    "helm"       = "helm"
  }

  name = "${local.name}"

  # Same trick with md5, null_resource and depends_on as above but for tiller
  tiller_dependency_id = "${module.k8s-addons.tiller_dependency_id}"

  chart_version   = "0.26.0"
  jenkins_version = "2.150.1"
  ingress_lb      = "${module.k8s-addons.ingress_lb}"
  github_token    = "${var.github_token}"
}

output "ecr_url" {
  value = "${module.jenkins.ecr_url}"
}
