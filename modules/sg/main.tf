resource "aws_security_group" "sg-rds" {

  name        = "rds-sg"
  description = "Allow MySQL Port"
  vpc_id = var.vpc
 
  ingress {
    description = "Allowing Connection for SSH"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS"
  }
}

output "rds-sg-id" {
  value = aws_security_group.sg-rds.id
}