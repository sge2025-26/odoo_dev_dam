#!/bin/bash
# Script para restaurar datos directamente a un Volumen Nombrado de Docker.

echo "======================================================="
echo "    INICIANDO RESTAURACIÓN CON VOLUMEN NOMBRADO"
echo "======================================================="

PKG_PATH="data/backups/odoo_data_package.tar.gz"
TEMP_RESTORE_DIR="data/temp_postgres_restore"
VOLUME_NAME="odoo_dev_dam_postgres_data_volume" # Nombre completo del volumen (predecible)

# 1. Verificar si el paquete de datos existe
if [ ! -f $PKG_PATH ]; then
    echo "ERROR: No se encontró el archivo de datos '$PKG_PATH'. Asegúrate de haber hecho 'git pull'."
    exit 1
fi

# 2. Desempaquetar los datos al directorio temporal del host
echo "-> Desempaquetando datos en directorio temporal..."
rm -rf $TEMP_RESTORE_DIR
tar -xzvf $PKG_PATH --strip-components=1 -C data/dataPostgreSQL 

# 3. Eliminar el volumen nombrado antiguo para asegurar una restauración limpia
echo "-> Eliminando volumen de PostgreSQL anterior..."
docker volume rm $VOLUME_NAME 2>/dev/null || true

# 4. Crear un contenedor temporal para copiar los datos del host al volumen nombrado
echo "-> Copiando datos del host al Volumen Nombrado..."
docker run --rm \
    -v $TEMP_RESTORE_DIR:/from_host \
    -v $VOLUME_NAME:/to_volume \
    postgres:15 \
    sh -c "cp -a /from_host/. /to_volume/ && chown -R postgres:postgres /to_volume/"

# 5. Limpiar el directorio temporal del host
echo "-> Limpiando directorio temporal..."
rm -rf $TEMP_RESTORE_DIR

# 6. Levantar los servicios de Docker (usando el volumen nombrado)
echo "-> Iniciando Docker Compose..."
docker-compose up -d

echo "======================================================="
echo " ¡RESTAURACIÓN COMPLETA! Se ha evitado el problema de permisos del SO."
echo " Acceso a Odoo en: http://localhost:8069"
echo "======================================================="