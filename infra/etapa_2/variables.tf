provider "aws" {
    region = "us-east-1"
}

data "aws_iam_role" "labrole" {
  name = "LabRole"
}

variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "name_cluster" {
  default = "innovatech-cluster"
}

variable "name_node" {
  default = "innovatech-workers"
  description = "Nombre de nodos"
}

variable "back_venta_ecr_repo_name" {
  default = "innovatech-ventas"
}

variable "back_despacho_ecr_repo_name" {
  default = "innovatech-despachos"
}

variable "front_ecr_repo_name" {
  default = "innovatech-frontend"
}