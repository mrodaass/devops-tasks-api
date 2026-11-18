variable "region" {
  description = "Región de AWS donde se crean los recursos"
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  description = "Nombre del proyecto, usado en nombres y etiquetas"
  type        = string
  default     = "devops-tasks-api"
}

variable "instance_type" {
  description = "Tamaño del servidor EC2"
  type        = string
  default     = "t3.micro"
}

variable "image" {
  description = "Imagen Docker que ejecutará el servidor"
  type        = string
  default     = "ghcr.io/mrodaass/devops-tasks-api:latest"
}