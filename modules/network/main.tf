
resource "aws_vpc" "this" {
  cidr_block = var.cidr_block[terraform.workspace]
  enable_dns_hostnames = true
  tags = {
    Name = "vpc-${var.environment_lower[terraform.workspace]}-daniel"
  }
}

resource "aws_subnet" "sbn-tf-daniel-public" {
  count = length(var.public_subnet_cidrs[terraform.workspace])
  vpc_id = aws_vpc.this.id
  cidr_block = element(var.public_subnet_cidrs[terraform.workspace], count.index )
  availability_zone = element(var.azs[terraform.workspace], count.index )
  tags = {
    Name = "sbn-${var.environment_lower[terraform.workspace]}-an2-daniel-public-${
      replace(element(var.azs[terraform.workspace], count.index), var.demo_devops_region[terraform.workspace], "")
    }"
  }

  depends_on = [
    aws_vpc.this
  ]
}

resource "aws_subnet" "sbn-tf-daniel-private" {
  count = length(var.private_subnet_cidrs[terraform.workspace])
  vpc_id = aws_vpc.this.id
  cidr_block = element(var.private_subnet_cidrs[terraform.workspace], count.index )
  availability_zone = element(var.azs[terraform.workspace], count.index )
  tags = {
    Name = "sbn-${var.environment_lower[terraform.workspace]}-an2-daniel-private-${
      replace(element(var.azs[terraform.workspace], count.index), var.demo_devops_region[terraform.workspace], "")
    }"
  }

  depends_on = [
    aws_vpc.this
  ]
}

resource "aws_internet_gateway" "igw-tf-daniel" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "igw-${var.environment_lower[terraform.workspace]}-daniel"
  }
}

# "create_before_destroy"는 해당 리소스만 삭제한다.
# 기존에 생성된 aws_eip가 존재하는 경우 해당 리소스는 삭제하지 않는다.
resource "aws_eip" "nat_eip" {
  vpc   = true

  tags = {
    Name = "eip-${var.environment_lower[terraform.workspace]}-an2-daniel-nat"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "nat-tf-daniel" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.sbn-tf-daniel-public[0].id

  tags = {
    Name = "nat-${var.environment_lower[terraform.workspace]}-an2-daniel"
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
    Name = "rt-${var.environment_lower[terraform.workspace]}-an2-daniel-vpc"
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
    Name = "rt-${var.environment_lower[terraform.workspace]}-an2-daniel-public"
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
    Name = "rt-${var.environment_lower[terraform.workspace]}-an2-daniel-private"
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
  count = length(var.public_subnet_cidrs[terraform.workspace])
  subnet_id = element(aws_subnet.sbn-tf-daniel-public[*].id, count.index)
  route_table_id = aws_route_table.rt-subnet-public.id
}

resource "aws_route_table_association" "rt-sbn-tf-daniel-private" {
  count = length(var.private_subnet_cidrs[terraform.workspace])
  subnet_id = element(aws_subnet.sbn-tf-daniel-private[*].id, count.index)
  route_table_id = aws_route_table.rt-subnet-private.id
}