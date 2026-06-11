output "IP_PUBLICA_SERVIDOR" {
  description = "IP publica del servidor unico de Innovatech"
  value       = aws_instance.innovatech_server.public_ip
}

output "IP_PRIVADA_SERVIDOR" {
  description = "IP privada del servidor unico de Innovatech"
  value       = aws_instance.innovatech_server.private_ip
}