terraform {
  required_providers {
    aws ={
        source = "hashicorp/aws"
        version = "~>5.0"
    }
  }
}

# === #
# EKS #
# === #

resource "aws_eks_cluster" "eks" {
    name     = var.name_cluster
    role_arn = data.aws_iam_role.labrole.arn
    vpc_config {
      subnet_ids = [
        aws_subnet.public[0].id,
        aws_subnet.public[1].id,
        aws_subnet.private[0].id,
        aws_subnet.private[1].id
      ]
    }
}

resource "aws_eks_node_group" "workers" {
    cluster_name    = aws_eks_cluster.eks.name
    node_group_name = var.name_node
    node_role_arn   = data.aws_iam_role.labrole.arn
    
    subnet_ids = [
      aws_subnet.private[0].id,
      aws_subnet.private[1].id
    ]

    scaling_config {
      desired_size = 2
      max_size     = 2
      min_size     = 1
    }

    instance_types = ["t3.medium"]
    capacity_type  = "ON_DEMAND"
}

# === #
# ECR #
# === #

resource "aws_ecr_repository" "innovatech_ventas_repo" {
  name = var.back_venta_ecr_repo_name
  image_scanning_configuration {
    scan_on_push = true
  }
  force_delete = true
  tags = {
    Name = "innovatech-ventas"
  }
}

resource "aws_ecr_repository" "innovatech_despachos_repo" {
  name = var.back_despacho_ecr_repo_name
  image_scanning_configuration {
    scan_on_push = true
  }
  force_delete = true
  tags = {
    Name = "innovatech-despachos"
  }
}

resource "aws_ecr_repository" "innovatech_frontend_repo" {
  name = var.front_ecr_repo_name
  image_scanning_configuration {
    scan_on_push = true
  }
  force_delete = true
  tags = {
    Name = "innovatech-frontend"
  }
}