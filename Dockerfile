# Fijamos Debian 12 (bookworm) explícitamente para evitar sorpresas
# si Docker Hub actualiza la imagen "slim" a una versión de Debian más
# nueva (lección aprendida con main-app/FastAPI)
FROM python:3.12-slim-bookworm

# Driver de PostgreSQL (psycopg2) necesita estas librerías de compilación
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc libpq-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Archivos estáticos: Django los recolecta en build time hacia
# /app/staticfiles, que coincide con el volumen "static_data" del compose
RUN python manage.py collectstatic --noinput || true

EXPOSE 8000

# AJUSTA "config.wsgi" según el nombre real de tu carpeta de settings
# (el proyecto creado con "django-admin startproject config ." usaría esto)
CMD ["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:8000", "--workers", "3"]
