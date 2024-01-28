variable "eks_private_subnet" {
    type        = list(string)
    description = "put subnet from vpc"
}

variable "vpc" {
  description = "vpc for rds sg"
}

variable "db-host" {
    description = "rds db host"
}

variable "db-user" {
  description = "db user"
}

variable "db-password" {
  description = "db password"
}

variable "db-name" {
  description = "rds db name"
}

variable "memcached-host" {
  description = "memcached host endpoint"
}

variable "memcache-port" {
  default = 11211
}