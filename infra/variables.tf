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