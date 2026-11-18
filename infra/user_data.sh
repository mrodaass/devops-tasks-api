#!/bin/bash
set -euxo pipefail

# Instalar y encender Docker
dnf install -y docker
systemctl enable --now docker

# Ejecutar la API: puerto 80 del servidor → 8000 del contenedor
docker run -d \
  --name tasks-api \
  --restart unless-stopped \
  -p 80:8000 \
  -e ENVIRONMENT=aws \
  ${image}