################
# VPC
################
resource "aws_vpc" "main" {
  cidr_block           = "${var.cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = "${merge(map("Name", format("%s", var.name)), var.tags)}"
}

###################
# Internet gateway
###################
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.main.id}"

  tags = "${merge(map("Name", format("%s", var.name)), var.tags)}"
}

###################
# NAT gateway
###################
resource "aws_eip" "nat" {
  vpc = true

  tags = "${merge(map("Name", format("%s-nat", var.name)), var.tags)}"

  depends_on = ["aws_internet_gateway.igw"]
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public.0.id}"

  tags = "${merge(map("Name", format("%s", var.name)), var.tags)}"
}

################
# Public subnet
################
resource "aws_subnet" "public" {
  count = "${length(var.azs)}"

  vpc_id                  = "${aws_vpc.main.id}"
  availability_zone       = "${element(var.azs, count.index)}"
  cidr_block              = "${element(var.public_subnets, count.index)}"
  map_public_ip_on_launch = true

  tags {
    Name        = "${format("%s-public-%s", var.name, element(var.azs, count.index))}"
    Environment = "internal"
    Purpose     = "public-subnet"
  }
}

################
# Private subnet
################
resource "aws_subnet" "private" {
  count = "${length(var.azs)}"

  vpc_id                  = "${aws_vpc.main.id}"
  availability_zone       = "${element(var.azs, count.index)}"
  cidr_block              = "${element(var.private_subnets, count.index)}"
  map_public_ip_on_launch = false

  tags {
    Name        = "${format("%s-private-%s", var.name, element(var.azs, count.index))}"
    Environment = "internal"
    Purpose     = "private-subnet"
  }
}

########################
# Default route tables
########################
resource "aws_default_route_table" "this" {
  default_route_table_id = "${aws_vpc.main.default_route_table_id}"

  tags = "${merge(map("Name", format("%s-default", var.name)), var.tags)}"
}

########################
# Public route tables
########################
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = "${merge(map("Name", format("%s-public", var.name)), var.tags)}"
}

resource "aws_route_table_association" "public" {
  count = "${length(var.azs)}"

  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

########################
# Private route tables
########################
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.ngw.id}"
  }

  tags = "${merge(map("Name", format("%s-private", var.name)), var.tags)}"
}

resource "aws_route_table_association" "private" {
  count = "${length(var.azs)}"

  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}

######################
# VPC Endpoint for S3
######################
data "aws_vpc_endpoint_service" "s3" {
  service = "s3"
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = "${aws_vpc.main.id}"
  service_name = "${data.aws_vpc_endpoint_service.s3.service_name}"
}

resource "aws_vpc_endpoint_route_table_association" "public" {
  route_table_id  = "${aws_route_table.public.id}"
  vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
}

resource "aws_vpc_endpoint_route_table_association" "private" {
  route_table_id  = "${aws_route_table.private.id}"
  vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
}
