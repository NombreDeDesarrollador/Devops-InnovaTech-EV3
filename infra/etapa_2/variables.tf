variable "aws_region" {
  description = "Región de AWS"
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  default     = "t2.micro"
}

variable "key_name" {
  description = "Nombre de la llave SSH (vkey) ya creada en AWS"
  default     = "key_proyecto"
}

variable "cluster_name" {
  default = "devops-u2-cluster"
}

variable "service_name" {
  default = "app"
}
