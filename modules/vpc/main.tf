resource "aws_vpc" "eks-vpc" {
  cidr_block = var.vpc_cidr_block
#   enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "eks-vpc"
  }
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr_blocks)
  depends_on = [
    aws_vpc.eks-vpc
  ]
  vpc_id                  = aws_vpc.eks-vpc.id
  cidr_block              = var.public_subnet_cidr_blocks[count.index]
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidr_blocks)
  depends_on = [
    aws_vpc.eks-vpc,
    aws_subnet.public
  ]
  vpc_id                  = aws_vpc.eks-vpc.id
  cidr_block              = var.private_subnet_cidr_blocks[count.index]
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "eks-vpc-ig" {
  depends_on = [
    aws_vpc.eks-vpc,
    aws_subnet.public,
    aws_subnet.private
  ]    
  vpc_id = aws_vpc.eks-vpc.id

  tags = {
    Name = "eks-vpc-internet-gateway"
  }
}

resource "aws_route_table" "public" {
  count = length(var.public_subnet_cidr_blocks)
  depends_on = [
    aws_vpc.eks-vpc,
    aws_internet_gateway.eks-vpc-ig
  ]
  vpc_id = aws_vpc.eks-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks-vpc-ig.id
  }
  tags = {
    Name = "public-route-table-${count.index + 1}"
  }
}

resource "aws_route_table" "private" {
  count = length(var.private_subnet_cidr_blocks)
  depends_on = [
    aws_nat_gateway.private
  ]
  vpc_id = aws_vpc.eks-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.private[count.index].id
  }
  tags = {
    Name = "private-route-table-${count.index + 1}"
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidr_blocks)
  depends_on = [
    aws_vpc.eks-vpc,
    aws_subnet.public,
    aws_subnet.private,
    aws_route_table.public
  ]
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidr_blocks)
  depends_on = [
    aws_route_table.private
  ]
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route" "public_internet_gateway" {
  count                   = length(var.public_subnet_cidr_blocks)
  route_table_id          = aws_route_table.public[count.index].id
  destination_cidr_block  = "0.0.0.0/0"
  gateway_id              = aws_internet_gateway.eks-vpc-ig.id
}

resource "aws_eip" "Nat-Gateway-EIP" {
  count                   = length(var.public_subnet_cidr_blocks)
  depends_on = [
    aws_route_table_association.public
  ]
}

resource "aws_nat_gateway" "private" {
    count = length(var.private_subnet_cidr_blocks)
    depends_on = [
        aws_eip.Nat-Gateway-EIP
    ]
    allocation_id = aws_eip.Nat-Gateway-EIP[count.index].id
    subnet_id     = aws_subnet.public[count.index].id

    tags = {
        Name = "nat-gateway-${count.index + 1}"
    }
}

output "private-subnet" {
    value = aws_subnet.private[*].id
}

output "vpc-id" {
  value = aws_vpc.eks-vpc.id
}