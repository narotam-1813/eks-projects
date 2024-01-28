variable "cluster-id" {
  description = "cluster id for elastic cache"
}

variable "engine" {
  description = "elasticecache engine"
}

variable "node-type" {
  description = "node tpye"
}

variable "subnet" {
  description = "subnet for elasticcache"
}

output "memcache-host" {
  value = aws_elasticache_cluster.memcached.configuration_endpoint
}