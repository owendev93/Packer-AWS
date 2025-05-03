#!/bin/bash
set -ex  # Detener ejecución ante cualquier error

# Actualizar sistema e instalar dependencias
sudo apt-get update

# Instalar nginx
sudo apt-get install -y nginx

# Instalar Node.js 18 y npm desde NodeSource
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Habilitar Nginx
sudo systemctl enable nginx

# Ruta de la aplicación
APP_DIR="/var/www/nodeapp"

# Crear directorio y copiar app
mkdir -p $APP_DIR
cp -r /tmp/app/* $APP_DIR

# Preparar la app
cd $APP_DIR
npm install || true

# Configuración de Nginx (solo si existe)
if [ -f "$APP_DIR/nginx-config.conf" ]; then
  cp "$APP_DIR/nginx-config.conf" /etc/nginx/sites-available/default
else
  echo "⚠️  nginx-config.conf no encontrado, se usará la configuración por defecto"
fi

# Permisos (opcional)
chmod -R 755 $APP_DIR

# Verificar y reiniciar Nginx
nginx -t && sudo systemctl restart nginx

