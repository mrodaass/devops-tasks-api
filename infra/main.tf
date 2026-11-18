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
      Purpose   = "aprendizaje"
    }
  }
}

# ---------- Datos que Terraform consulta (no crea nada) ----------

# La imagen más reciente de Amazon Linux 2023
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# La red (VPC) que AWS trae por defecto
data "aws_vpc" "default" {
  default = true
}

# ---------- Firewall ----------
resource "aws_security_group" "api" {
  name_prefix = "${var.project_name}-"
  description = "Permite HTTP hacia la API"
  vpc_id      = data.aws_vpc.default.id

  # Entrada: solo HTTP (puerto 80) desde cualquier lugar
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Salida: todo permitido (necesita descargar Docker y tu imagen)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------- Servidor ----------
resource "aws_instance" "api" {
  ami                    = data.aws_ssm_parameter.al2023.value
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.api.id]

  # Script de arranque, con la imagen como parámetro
  user_data                   = templatefile("${path.module}/user_data.sh", { image = var.image })
  user_data_replace_on_change = true

  # Seguridad: exige IMDSv2 (protege las credenciales internas del servidor)
  metadata_options {
    http_tokens = "required"
  }

  # Disco cifrado
  root_block_device {
    encrypted = true
  }

  tags = {
    Name = var.project_name
  }
}