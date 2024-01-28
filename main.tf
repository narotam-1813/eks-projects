variable "region" {
    default = "ap-south-1"
  
}

module "vpc" {
    source = "./modules/vpc"
}

module "role" {
    source = "./modules/iamRoles"
}

module "eks" {
    source = "./modules/eks"
    cluster_name = "eks-cluster"
    desired_capacity = "1"
    eks_subnet = module.vpc.private-subnet
    instance_type = "t2.medium"
    node_role_arn = module.role.eks_node_arn
    eks-role = module.role.eks_role
}

module "sg" {
  source = "./modules/sg"
  vpc = module.vpc.vpc-id
}
module "rds" {
    source = "./modules/rds"
    engine = "mysql"
    engine-version = "5.7"
    instance-class = "db.t2.micro"
    prameter-group-name = "default.mysql5.7"
    rds-db-username = "admin"
    rds-db-password = "Narotam123"
    eks-private-subnet = module.vpc.private-subnet
    rds-sg = module.sg.rds-sg-id
  
}

module "memcached" {
    source = "./modules/memcache"
    cluster-id = module.eks.cluster-id
    engine = "memcached"
    node-type = "cache.t2.micro"
    subnet = module.vpc.private-subnet
  
}
module "helm" {
    source = "./modules/helm"
    depends_on = [ module.eks,
    module.rds, module.memcached, module.sg ]
    eks_private_subnet = module.vpc.private-subnet
    vpc = module.vpc.vpc-id
    db-host = module.rds.rds-db-host
    db-user = module.rds.rds-db-user
    db-password = module.rds.rds-db-password
    db-name = module.rds.rds-db-name
    memcached-host = module.memcached.memcache-host
}