# 1. Qué versión de Terraform y qué "proveedores" necesitamos
terraform {
  required_version = ">= 1.17"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# 2. Configuración del proveedor de AWS
provider "aws" {
  region = var.region

  # Estas etiquetas se ponen solas en TODOS los recursos
  default_tags {
    tags = {
      Project   = var.project_name
      ManagedBy = "terraform"
      Purpose = "aprendizaje"
    }
  }
}

# 3. Recurso: un bucket de S3
resource "aws_s3_bucket" "artefactos" {
  bucket_prefix = "${var.project_name}-" # AWS agrega un sufijo único
  force_destroy = true                   # permite borrarlo aunque tenga archivos
}

# 4. Recurso: bloquear todo acceso público al bucket
resource "aws_s3_bucket_public_access_block" "artefactos" {
  bucket = aws_s3_bucket.artefactos.id # ← referencia al recurso de arriba

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}