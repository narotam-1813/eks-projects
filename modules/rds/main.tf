resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = var.eks-private-subnet
}

resource "aws_db_instance" "rds" {
  engine               = var.engine
  engine_version       = var.engine-version
  instance_class       = var.instance-class
  allocated_storage    = 10
  storage_type         = "gp2"
  username             = var.rds-db-username
  password             = var.rds-db-password
  parameter_group_name = var.prameter-group-name
  publicly_accessible = true
  skip_final_snapshot = true
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [var.rds-sg]
  tags = {
  name = "RDS"
   }
}