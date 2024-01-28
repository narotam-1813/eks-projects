variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
  description = "CIDR block for the VPC"
}

data "aws_availability_zones" "available" {
  state = "available"
}

variable "public_subnet_cidr_blocks" {
  type        = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
  description = "CIDR blocks for public subnets"
}

variable "private_subnet_cidr_blocks" {
  type        = list(string)
  default = ["10.0.3.0/24", "10.0.4.0/24"]
  description = "CIDR blocks for private subnets"
}