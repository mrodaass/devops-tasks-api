output "api_url" {
  description = "URL pública del health check"
  value       = "http://${aws_instance.api.public_ip}/health"
}

output "instance_id" {
  description = "ID del servidor EC2"
  value       = aws_instance.api.id
}