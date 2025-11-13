#!/bin/bash
# Script para restaurar datos y levantar el entorno Odoo

echo "======================================================="
echo "    INICIANDO RESTAURACIÓN Y SETUP"
echo "======================================================="

# Definimos la ruta del paquete para facilitar la actualización
PKG_PATH="scripts/odoo_data_package.tar.gz"

# 1. Verificar si el paquete de datos existe
if [ ! -f $PKG_PATH ]; then
    echo "ERROR: No se encontró el archivo de datos '$PKG_PATH'."
    echo "Asegúrate de haber hecho 'git clone' correctamente y que el archivo se haya descargado."
    exit 1
fi

# 2. Desempaquetar los datos, recreando las carpetas de volúmenes
echo "Restaurando estructura de carpetas de datos..."
tar -xzvf $PKG_PATH

# 3. AJUSTE CRÍTICO DE PERMISOS
# Usamos un contenedor temporal de postgres para cambiar el propietario del volumen de datos 
# a su usuario interno (UID 999 o 70). Esto es VITAL para la portabilidad.
echo "-> Corrigiendo permisos del volumen de datos de PostgreSQL..."
docker run --rm -v $(pwd)/data/dataPostgreSQL:/var/lib/postgresql/data postgres:15 chown -R 999:999 /var/lib/postgresql/data

# 4. Levantar los servicios de Docker
echo "Iniciando Docker Compose..."
docker-compose up -d

echo "======================================================="
echo " ¡RESTAURACIÓN COMPLETA!"
echo " Acceso a Odoo en: http://localhost:8069"
echo "======================================================="