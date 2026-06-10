data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# -------------------------------------------------------------------------
# INSTANCIA ÚNICA: TODO EL STACK (Frontend, Backends y Base de Datos)
# -------------------------------------------------------------------------
resource "aws_instance" "innovatech_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id # Desplegada en la pública para acceso al Frontend
  vpc_security_group_ids = [aws_security_group.sg_innovatech.id]
  key_name               = var.key_name
  tags                   = { Name = "EC2-Innovatech-Server" }

  iam_instance_profile = "LabInstanceProfile"

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  user_data = <<-EOF
              #!/bin/bash
              # Actualizar paquetes del sistema
              sudo yum update -y
              
              # Instalar e iniciar Docker
              sudo yum install docker -y
              sudo systemctl start docker
              sudo systemctl enable docker
              
              # Añadir el usuario del sistema al grupo docker para evitar usar sudo
              sudo usermod -aG docker ec2-user
              
              # Crear directorio de plugins globales de Docker si no existe
              sudo mkdir -p /usr/local/lib/docker/cli-plugins/

              # CORRECCIÓN: Instalar Docker Buildx moderno (>= 0.17.0) para evitar caídas en AL2023
              sudo curl -SL https://github.com/docker/buildx/releases/download/v0.17.1/buildx-v0.17.1.linux-amd64 -o /usr/local/lib/docker/cli-plugins/docker-buildx
              sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-buildx
              
              # Instalar Docker Compose V2 como plugin de Docker CLI
              sudo curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
              sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
              EOF
}