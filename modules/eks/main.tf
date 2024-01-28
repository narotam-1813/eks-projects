resource "aws_eks_cluster" "eks_cluster" {
 name = var.cluster_name
 role_arn = var.eks-role

 vpc_config {
  subnet_ids = var.eks_subnet
 }

 depends_on = [
  var.eks-role,
 ]
}

resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_role_arn = var.node_role_arn
  subnet_ids = var.eks_subnet
  node_group_name = "${var.cluster_name}_nodes"
  ami_type = "AL2_x86_64"
  

  scaling_config {
    desired_size = var.desired_capacity
    max_size     = var.desired_capacity + 1
    min_size     = var.desired_capacity - 1
  }
  
  instance_types = [var.instance_type]

  depends_on = [aws_eks_cluster.eks_cluster]
}