variable "engine" {
  description = "This is rds engine"
}

variable "engine-version" {
  description = "This is engine version"
}

variable "instance-class" {
  description = "Instance class or type"
}

variable "prameter-group-name" {
  description = "prameter group name"
}

variable "rds-db-username" {
  description = "db username"
}

variable "rds-db-password" {
  description = "db password"
}

variable "rds-sg" {
  description = "rds security group"
}

variable "eks-private-subnet" {
  description = "private subnet for rds"
}

output "rds-db-host" {
  value = aws_db_instance.rds.address
}

output "rds-db-user" {
  value = aws_db_instance.rds.username 
}

output "rds-db-password" {
  value = aws_db_instance.rds.password
}
output "rds-db-name" {
  value = aws_db_instance.rds.db_name
}