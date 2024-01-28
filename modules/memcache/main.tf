resource "aws_elasticache_subnet_group" "memcached_subnet_group" {
  name       = "memcached-subnet-group"
  subnet_ids = var.subnet
}

resource "aws_elasticache_cluster" "memcached" {
  cluster_id           = var.cluster-id
  engine               = var.engine
  node_type            = var.node-type
  num_cache_nodes      = 1
  parameter_group_name = "default.memcached1.6"
  subnet_group_name    = aws_elasticache_subnet_group.memcached_subnet_group.name
}
