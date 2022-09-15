terraform {
  required_version = ">= 1.2.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.30.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.13.1"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "aws_availability_zones" "available" {
}

resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.4"

  name                 = "test-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = "1.22"
  subnet_ids      = module.vpc.private_subnets
  version         = "18.29.0"
  # cluster_timeouts = "1h"
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id = module.vpc.vpc_id

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  eks_managed_node_group_defaults = {
    disk_size      = 50
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    blue = {}
    green = {
      min_size     = 1
      max_size     = 10
      desired_size = 1

      instance_types = ["t3.large"]
      capacity_type  = "SPOT"
    }
  }

  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  # Extend node-to-node security group rules
  node_security_group_ntp_ipv6_cidr_block = ["fd00:ec2::123/128"]
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  aws_auth_roles    = var.map_roles
  aws_auth_users    = var.map_users
  aws_auth_accounts = var.map_accounts
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# resource "kubernetes_persistent_volume" "postgresql-pv" {
#   metadata {
#     name = "postgresql-pv"
#     labels {
#       type = local
#     }
#   }
#   spec {
#     storageClassName = manual
#     capacity = {
#       storage = "10Gi"
#     }
#     access_modes = ["ReadWriteOnce"]
#     persistent_volume_source {
#       vsphere_volume {
#         volume_path = "/mnt/data"
#       }
#     }
#   }
# }




# resource "kubernetes_deployment" "_" {
#   metadata {
#     name = "terraform-example"
#     labels = {
#       test = "MyExampleApp"
#     }
#   }

#   spec {
#     replicas = 3

#     selector {
#       match_labels = {
#         test = "MyExampleApp"
#       }
#     }

#     template {
#       metadata {
#         labels = {
#           test = "MyExampleApp"
#         }
#       }

#       spec {
#         container {
#           image = "nginx:1.21.6"
#           name  = "example"

#           resources {
#             limits = {
#               cpu    = "0.5"
#               memory = "512Mi"
#             }
#             requests = {
#               cpu    = "250m"
#               memory = "50Mi"
#             }
#           }

#           liveness_probe {
#             http_get {
#               path = "/"
#               port = 80

#               http_header {
#                 name  = "X-Custom-Header"
#                 value = "Awesome"
#               }
#             }

#             initial_delay_seconds = 3
#             period_seconds        = 3
#           }
#         }
#       }
#     }
#   }
# }

# resource "kubernetes_service" "_" {
#   metadata {
#     name = "terraform-example"
#   }
#   spec {
#     selector = {
#       test = kubernetes_deployment._.metadata.0.labels.test
#     }
#     # session_affinity = "ClientIP"
#     port {
#       port        = 8080
#       target_port = 80
#     }

#     type = "LoadBalancer"
#   }
# }