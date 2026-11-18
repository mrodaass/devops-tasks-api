output "bucket_name" {
  description = "Nombre final del bucket creado"
  value       = aws_s3_bucket.artefactos.bucket
}