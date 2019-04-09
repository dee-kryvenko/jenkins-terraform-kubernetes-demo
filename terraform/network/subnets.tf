# Standard 3-tier model imply:
#  1. a backend network (for DB and such)
#  2. a private network for most of the stuff that is the only ingress source allowed in backend
#  3. a dmz network for LBs and such
locals {
  backend_cidr = "${cidrsubnet(var.cidr, "2", "0")}"
  private_cidr = "${cidrsubnet(var.cidr, "2", "1")}"
  dmz_cidr     = "${cidrsubnet(var.cidr, "2", "2")}"
}

output "backend_cidr" {
  value = "${local.backend_cidr}"
}

output "private_cidr" {
  value = "${local.private_cidr}"
}

output "dmz_cidr" {
  value = "${local.dmz_cidr}"
}

data "aws_availability_zones" "azs" {}

# Backend subnet is for DB
resource "aws_subnet" "backend" {
  count             = "${var.azs}"
  vpc_id            = "${aws_vpc.this.id}"
  availability_zone = "${data.aws_availability_zones.azs.names[count.index]}"
  cidr_block        = "${cidrsubnet(local.backend_cidr, "${var.azs - 1}", count.index)}"

  map_public_ip_on_launch = false

  tags {
    Name = "${var.name}-backend"
  }
}

output "backend_subnets" {
  value = "${zipmap(aws_subnet.backend.*.id, aws_subnet.backend.*.cidr_block)}"
}

resource "aws_route_table" "backend" {
  vpc_id = "${aws_vpc.this.id}"

  tags {
    Name = "${var.name}-backend"
  }
}

resource "aws_route_table_association" "backend" {
  count          = "${var.azs}"
  subnet_id      = "${element(aws_subnet.backend.*.id, count.index)}"
  route_table_id = "${aws_route_table.backend.id}"
}

# Private is for pretty much everything

resource "aws_subnet" "private" {
  count                   = "${var.azs}"
  vpc_id                  = "${aws_vpc.this.id}"
  availability_zone       = "${data.aws_availability_zones.azs.names[count.index]}"
  cidr_block              = "${cidrsubnet(local.private_cidr, "${var.azs - 1}", count.index)}"
  map_public_ip_on_launch = true

  tags = "${map("Name", "${var.name}-private", "kubernetes.io/cluster/${var.name}", "shared")}"
}

output "private_subnets" {
  value = "${zipmap(aws_subnet.private.*.id, aws_subnet.private.*.cidr_block)}"
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.this.id}"

  tags {
    Name = "${var.name}-private"
  }
}

resource "aws_route_table_association" "private" {
  count          = "${var.azs}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route" "private_internet_gateway_route" {
  route_table_id         = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.this.id}"

  timeouts {
    create = "5m"
  }
}

# DMZ is for LBs

resource "aws_subnet" "dmz" {
  count                   = "${var.azs}"
  vpc_id                  = "${aws_vpc.this.id}"
  availability_zone       = "${data.aws_availability_zones.azs.names[count.index]}"
  cidr_block              = "${cidrsubnet(local.dmz_cidr, "${var.azs - 1}", count.index)}"
  map_public_ip_on_launch = true

  tags = "${map("Name", "${var.name}-dmz", "kubernetes.io/role/internal-elb", "1", "kubernetes.io/role/elb", "1")}"
}

output "dmz_subnets" {
  value = "${zipmap(aws_subnet.dmz.*.id, aws_subnet.dmz.*.cidr_block)}"
}

resource "aws_route_table" "dmz" {
  vpc_id = "${aws_vpc.this.id}"

  tags {
    Name = "${var.name}-dmz"
  }
}

resource "aws_route_table_association" "dmz" {
  count          = "${var.azs}"
  subnet_id      = "${element(aws_subnet.dmz.*.id, count.index)}"
  route_table_id = "${aws_route_table.dmz.id}"
}

resource "aws_route" "dmz_internet_gateway_route" {
  route_table_id         = "${aws_route_table.dmz.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.this.id}"

  timeouts {
    create = "5m"
  }
}
