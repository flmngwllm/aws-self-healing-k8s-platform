
resource "aws_vpc" "self_heal_vpc" {
  cidr_block = "172.20.0.0/16"

  tags = {
    Name = "self_heal_vpc"
  }
}

resource "aws_subnet" "self_heal_public_subnet" {
  map_public_ip_on_launch = true
  vpc_id     = aws_vpc.self_heal_vpc.id
  for_each = var.public_subnets
  cidr_block = cidrsubnet((aws_vpc.self_heal_vpc.cidr_block), 8, each.value)
  availability_zone = each.key

  tags = {
    Name = "self_heal_public_subnet"
  }
}

resource "aws_subnet" "self_heal_private_subnet" {
  for_each = var.private_subnets
  vpc_id     = aws_vpc.self_heal_vpc.id
  cidr_block = cidrsubnet((aws_vpc.self_heal_vpc.cidr_block), 8, each.value)
  availability_zone = each.key

  tags = {
    Name = "self_heal_private_subnet"
  }
}

resource "aws_route_table" "self_heal_table_public" {
  vpc_id = aws_vpc.self_heal_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.self_heal_igw.id
  }

  tags = {
    Name = "self_heal_table_public"
  }
}

resource "aws_route_table" "self_heal_table_private" {
  vpc_id = aws_vpc.self_heal_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.self_heal_nat.id
  }

  tags = {
    Name = "self_heal_table_private"
  }
}

resource "aws_internet_gateway" "self_heal_igw" {
  vpc_id = aws_vpc.self_heal_vpc.id

  tags = {
    Name = "self_heal_igw"
  }
}

resource "aws_nat_gateway" "self_heal_nat" {
  allocation_id = aws_eip.self_heal_eip.id
  subnet_id     = aws_subnet.self_heal_public_subnet["us-east-1a"].id
  depends_on = [aws_internet_gateway.self_heal_igw]

  tags = {
    Name = "self_heal_nat"
  }

}

resource "aws_route_table_association" "self_heal_public_association" {
  for_each = aws_subnet.self_heal_public_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.self_heal_table_public.id
}

resource "aws_route_table_association" "self_heal_private_association" {
  for_each = aws_subnet.self_heal_private_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.self_heal_table_private.id
}

resource "aws_eip" "self_heal_eip" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.self_heal_igw]
}