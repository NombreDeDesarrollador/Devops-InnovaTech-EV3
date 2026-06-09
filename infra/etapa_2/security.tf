resource "aws_security_group" "sg_innovatech" {
  name        = "sg_innovatech"
  description = "Permitir SSH, HTTP y puertos reales de la aplicacion"
  vpc_id      = aws_vpc.main_vpc.id

  # Acceso SSH para administracion y GitHub Actions
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Puerto Frontend (Nginx expuesto al mundo)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Puerto Backend Ventas (Mapeado en docker-compose como 8081:8080)
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Puerto Backend Despachos (Mapeado en docker-compose como 8082:8080)
  ingress {
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Puerto Base de Datos (MySQL expuesto en el host 3306:3306)
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Salida a internet permitida (Crucial para descargar imagenes de ECR y actualizaciones)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}