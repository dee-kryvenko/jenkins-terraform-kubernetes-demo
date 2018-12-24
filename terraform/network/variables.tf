variable "name" {}

variable "cidr" {}

variable "azs" {
  default     = "2"
  description = "Number of availability zones to use"
}
