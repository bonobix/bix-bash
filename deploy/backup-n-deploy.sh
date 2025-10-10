#!/bin/bash

"""
Questo script copia i file di una dir dichiarata nella dir del server web es. nginx e ne fa un backup in un'altra dir separata.
- Backup
Crea un backup dell’attuale versione
- Deploy
Copia i nuovi file nel web root
- Restart
Riavvia il servizio web

"""

# Variables
SOURCE_DIR="/home/user/app/build"  # Where your built app lives
DEPLOY_DIR="/var/www/html"         # Web server directory (e.g., Nginx/Apache)
SERVICE_NAME="nginx"               # Service to restart

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory $SOURCE_DIR not found!"
    exit 1
fi

# Backup existing deployment
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
BACKUP_DIR="/backups/deploy_$TIMESTAMP"
echo "Backing up current deployment to $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR"
cp -r "$DEPLOY_DIR"/* "$BACKUP_DIR" 2>/dev/null

# Deploy new files
echo "Deploying files from $SOURCE_DIR to $DEPLOY_DIR..."
cp -r "$SOURCE_DIR"/* "$DEPLOY_DIR"
if [ $? -eq 0 ]; then
    echo "Files copied successfully."
else
    echo "Error: File copy failed!"
    exit 1
fi

# Restart service
echo "Restarting $SERVICE_NAME..."
systemctl restart "$SERVICE_NAME"
if [ $? -eq 0 ]; then
    echo "$SERVICE_NAME restarted successfully."
else
    echo "Error: Failed to restart $SERVICE_NAME!"
    exit 1
fi

echo "Deployment completed!"
