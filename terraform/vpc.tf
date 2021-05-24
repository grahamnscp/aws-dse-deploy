# vpc.tf 

# VPC
resource "aws_vpc" "nw-vpc" {
  cidr_block           = "${var.vpcCIDRblock}"
  instance_tenancy     = "${var.instanceTenancy}" 
  enable_dns_support   = "${var.dnsSupport}" 
  enable_dns_hostnames = "${var.dnsHostNames}"

  tags = {
    Name = "${var.name_prefix}_vpc"
    owner = "${var.owner_tag}"
  }
}

# Subnet
resource "aws_subnet" "nw-subnet" {
  vpc_id                  = "${aws_vpc.nw-vpc.id}"
  cidr_block              = "${var.subnetCIDRblock}"
  map_public_ip_on_launch = "${var.mapPublicIP}" 
#  availability_zone       = "${data.aws_availability_zones.available.names[1]}"

  tags = {
    Name = "${var.name_prefix}_subnet"
    owner = "${var.owner_tag}"
  }
}

# Gateway
resource "aws_internet_gateway" "nw-gateway" {
  vpc_id = "${aws_vpc.nw-vpc.id}"

  tags = {
    Name = "${var.name_prefix}_gateway"
    owner = "${var.owner_tag}"
  }
}

# Route
resource "aws_route_table" "nw-route" {
  vpc_id = "${aws_vpc.nw-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.nw-gateway.id}"
  }

  tags = {
    Name = "${var.name_prefix}_route"
    owner = "${var.owner_tag}"
  }
}

# Associate Route to Subnet
resource "aws_route_table_association" "nw-subnet-route" {
  subnet_id      = "${aws_subnet.nw-subnet.id}"
  route_table_id = "${aws_route_table.nw-route.id}"
}


