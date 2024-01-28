# resource "helm_release" "wordpress" {
#   name       = "wordpress"
#   repository = "https://charts.bitnami.com/bitnami"
#   chart      = "wordpress"
#   set {
#     name  = "service.type"
#     value = "LoadBalancer"
#   }
#   set {
#     name = "wordpressUsername"
#     value = "admin"
#   }
#   set {
#     name = "wordpressPassword"
#     value = "Narotam"
#   }
#   set {
#     name = "mariadb.enabled"
#     value = false
#   }
# }

# resource "aws_security_group" "sg-rds" {

#   name        = "rds-sg"
#   description = "Allow MySQL Port"
#   # vpc_id = var.vpc
 
#   ingress {
#     description = "Allowing Connection for SSH"
#     from_port   = 3306
#     to_port     = 3306
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "RDS"
#   }
# }

# resource "aws_db_subnet_group" "rds_subnet_group" {
#   name       = "rds-subnet-group"
#   subnet_ids = var.eks_private_subnet
# }

# resource "aws_db_instance" "rds" {
#   engine               = "mysql"
#   engine_version       = "5.7"
#   instance_class       = "db.t2.micro"
#   allocated_storage    = 10
#   storage_type         = "gp2"
#   username             = "admin"
#   password             = "Naortam123"
#   parameter_group_name = "default.mysql5.7"
#   publicly_accessible = true
#   skip_final_snapshot = true
#   # db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
#   vpc_security_group_ids = [aws_security_group.sg-rds.id]
#   tags = {
#   name = "RDS"
#    }
# }

# resource "aws_elasticache_cluster" "memcached" {
#   cluster_id           = 
#   engine               = "memcached"
#   node_type            = "cache.t2.micro"
#   num_cache_nodes      = 1
#   parameter_group_name = "default.memcached1.4"
#   subnet_group_name    = "your-subnet-group"
# }

resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    annotations = {
      "name" = "ingress-nginx"
    }
    name = "ingress-nginx"
  }
}
resource "helm_release" "nginx-ingress-controller" {
  depends_on = [ 
    kubernetes_namespace.ingress_nginx
   ]
  name       = "nginx-ingress-controller"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx-ingress-controller"
  namespace = "ingress-nginx"


  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

}

resource "kubernetes_deployment" "wordpress" {
  metadata {
    name = "wordpress"
    labels = {
      App = "wordpress"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "wordpress"
      }
    }
    template {
      metadata {
        labels = {
          App = "wordpress"
        }
      }
      spec {
        container {
          image = "wordpress:4.8-apache"
          name  = "wordpress"
		      env{
            name = "WORDPRESS_DB_HOST"
            value = var.db-host
          }
          env{
            name = "WORDPRESS_DB_USER"
            value = var.db-user
          }
          env{
            name = "WORDPRESS_DB_PASSWORD"
             value = var.db-password
          }
          env{
          name = "WORDPRESS_DB_DATABASE"
          value = var.db-name
          }
          env {
            name  = "MEMCACHED_HOST"
            value = var.memcached-host
          }
          env {
            name  = "MEMCACHED_PORT"
            value = var.memcache-port
          }  
          port {
            container_port = 80
          }

          resources {
            limits = {
              "cpu" = "0.5"
              "memory" = "512Mi" 
            }
            requests = {
              "cpu" = "250m"
              "memory" = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "wordpress" {
  depends_on = [ 
    kubernetes_deployment.wordpress
   ]
  metadata {
    name = "wordpress"
  }
  spec {
    selector = {
      App = kubernetes_deployment.wordpress.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port        = 80
      target_port = 80
    }

    type = "NodePort"
  }
}

resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.12.3"
  namespace        = "kube-system"
  timeout          = 120
  set {
    name  = "createCustomResource"
    value = "true"
  }
  set {
    name = "installCRDs"
    value = "true"
  }
}

# locals {
#   clusterissuer = "./issuer.yaml"
# }

# data "kubectl_file_documents" "clusterissuer" {
#   content = file(local.clusterissuer)
# }

# resource "kubectl_manifest" "clusterissuer" {
#   for_each  = data.kubectl_file_documents.clusterissuer.manifests
#   yaml_body = each.value
#   depends_on = [
#     data.kubectl_file_documents.clusterissuer
#   ]
# }

# resource "helm_release" "cluster-issuer" {
#   name      = "cluster-issuer"
#   chart     = "../helm_charts/cluster-issuer"
#   namespace = "kube-system"
#   depends_on = [
#     helm_release.cert-manager,
#   ]
#   set {
#     name  = "letsencrypt_email"
#     value = "narotam1111@gmail.com"
#   }
# }

resource "kubernetes_ingress_v1" "ingress" {
  depends_on = [ 
    helm_release.nginx-ingress-controller,
   ]
  wait_for_load_balancer = true
  metadata {
    name = "ingress"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "cert-manager.io/cluster-issuer" = helm_release.cert-manager.name
      "appgw.ingress.kubernetes.io/ssl-redirect" = "true"
      "cert-manager.io/acme-challenge-type" = "http01"
    }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = "test-project.dev.debuide.com"
      http {
        path {
          path = "/"
          backend {
            service {
              name = kubernetes_service.wordpress.metadata.0.name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
    tls {
      hosts = [ "test-project.dev.debuide.com" ]
      secret_name = "tls-secret"
    }
  }
}
