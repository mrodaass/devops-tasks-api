# 1. Imagen base: Linux mínimo con Python 3.11
FROM python:3.11-slim

# 2. Ajustes de Python recomendados para contenedores
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# 3. Carpeta de trabajo dentro del contenedor
WORKDIR /app

# 4. Primero SOLO las dependencias (aprovecha la caché)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 5. Después el código
COPY app ./app

# 6. Seguridad: no ejecutar como root
RUN useradd --create-home appuser
USER appuser

# 7. Puerto en el que escucha la app
EXPOSE 8000

# 8. Docker revisa /health cada 30 s para saber si la app está sana
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"

# 9. Comando para arrancar
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]