
resource "aws_vpc" "this" {
  cidr_block = var.cidr_block
  enable_dns_hostnames = true
  tags = {
    Name = "vpc-${var.environment_lower}-${var.service_name}"
  }
}

resource "aws_subnet" "sbn-tf-daniel-public" {
  count = length(var.public_subnet_cidr)
  vpc_id = aws_vpc.this.id
  cidr_block = element(var.public_subnet_cidr, count.index )
  availability_zone = element(var.azs, count.index )
  tags = {
    Name = "sbn-${var.environment_lower}-an2-${var.service_name}-public-${
      replace(element(var.azs, count.index), var.aws_region, "")
    }"
  }

  depends_on = [
    aws_vpc.this
  ]
}

resource "aws_subnet" "sbn-tf-daniel-private" {
  count = length(var.private_subnet_cidr)
  vpc_id = aws_vpc.this.id
  cidr_block = element(var.private_subnet_cidr, count.index )
  availability_zone = element(var.azs, count.index )
  tags = {
    Name = "sbn-${var.environment_lower}-an2-${var.service_name}-private-${
      replace(element(var.azs, count.index), var.aws_region, "")
    }"
  }

  depends_on = [
    aws_vpc.this
  ]
}

resource "aws_internet_gateway" "igw-tf-daniel" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "igw-${var.environment_lower}-${var.service_name}"
  }
}

# "create_before_destroy"는 해당 리소스만 삭제한다.
# 기존에 생성된 aws_eip가 존재하는 경우 해당 리소스는 삭제하지 않는다.
resource "aws_eip" "nat_eip" {
  vpc   = true

  tags = {
    Name = "eip-${var.environment_lower}-an2-${var.service_name}-nat"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "nat-tf-daniel" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.sbn-tf-daniel-public[0].id

  tags = {
    Name = "nat-${var.environment_lower}-an2-${var.service_name}"
  }

  depends_on = [aws_internet_gateway.igw-tf-daniel]
}

# Internet Gateway 추가
resource "aws_route_table" "rt-vpc" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-tf-daniel.id
  }
  tags = {
    Name = "rt-${var.environment_lower}-an2-${var.service_name}-vpc"
  }
  depends_on = [
    aws_internet_gateway.igw-tf-daniel
  ]
}

#Route Table 생성
resource "aws_route_table" "rt-subnet-public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-tf-daniel.id
  }
  tags = {
    Name = "rt-${var.environment_lower}-an2-${var.service_name}-public"
  }
  depends_on = [
    aws_internet_gateway.igw-tf-daniel
  ]
}

resource "aws_route_table" "rt-subnet-private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-tf-daniel.id
  }
  tags = {
    Name = "rt-${var.environment_lower}-an2-${var.service_name}-private"
  }
  depends_on = [
    aws_internet_gateway.igw-tf-daniel
  ]
}

resource "aws_main_route_table_association" "rt-vpc-tf-daniel" {
  vpc_id = aws_vpc.this.id
  route_table_id = aws_route_table.rt-vpc.id
}

resource "aws_route_table_association" "rt-sbn-tf-daniel-public" {
  count = length(var.public_subnet_cidr)
  subnet_id = element(aws_subnet.sbn-tf-daniel-public[*].id, count.index)
  route_table_id = aws_route_table.rt-subnet-public.id
}

resource "aws_route_table_association" "rt-sbn-tf-daniel-private" {
  count = length(var.private_subnet_cidr)
  subnet_id = element(aws_subnet.sbn-tf-daniel-private[*].id, count.index)
  route_table_id = aws_route_table.rt-subnet-private.id
}