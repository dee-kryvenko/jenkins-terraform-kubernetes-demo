resource "aws_vpc" "this" {
  cidr_block           = "${var.cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "${var.name}"
  }
}

output "vpc_id" {
  value = "${aws_vpc.this.id}"
}

resource "aws_vpc_dhcp_options" "this" {
  domain_name_servers = ["AmazonProvidedDNS"]

  tags {
    Name = "${var.name}"
  }
}

resource "aws_vpc_dhcp_options_association" "this" {
  vpc_id          = "${aws_vpc.this.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.this.id}"
}

resource "aws_internet_gateway" "this" {
  vpc_id = "${aws_vpc.this.id}"

  tags {
    Name = "${var.name}"
  }
}
