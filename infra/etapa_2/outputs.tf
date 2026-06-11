output "cluster_name" {
  description = "Nombre del clúster EKS"
  value       = aws_eks_cluster.eks.name
}

output "cluster_endpoint" {
  description = "Endpoint de la API de Kubernetes"
  value       = aws_eks_cluster.eks.endpoint
}
