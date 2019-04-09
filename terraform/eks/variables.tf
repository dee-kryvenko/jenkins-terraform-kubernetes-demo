variable "name" {}

variable "vpc_id" {}

variable "allow_ip" {
  type = "list"
}

variable "cluster_subnet_id" {
  type = "list"
}

variable "eks_version" {
  default = "1.12"
}

variable "kubeconfig" {}
