variable "cluster_name" {
  description = "put cluster name"
}

variable "eks_subnet" {
    type        = list(string)
    description = "put subnet from vpc"
}

variable "node_role_arn" {
  description = "mention role arn for eks nodes"
}

variable "desired_capacity" {
  description = "desire node capacity"
}

variable "instance_type" {
  description = "mention instance type"
}

variable "eks-role" {
    description = "mention eks role"
  
}

output "cluster-name" {
  value = aws_eks_cluster.eks_cluster.name
}

output "cluster-id" {
  value = aws_eks_cluster.eks_cluster.id
}