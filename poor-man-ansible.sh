#!/bin/bash

"""
This is: poor man’s Ansible

1.Copia i file della nuova build su ciascun server
2.Riavvia il servizio web remoto
3.Controlla che l’app risponda (HTTP 200)
4.Ferma il servizio se fallisce un deploy
5.Esegue tutto su più server

"""

# Variables
SOURCE_DIR="/home/user/app/build"
SERVERS=("web1.example.com" "web2.example.com")  # Array of target servers
DEPLOY_DIR="/var/www/html"
SERVICE_NAME="nginx"
HEALTH_URL="http://localhost/health"  # Endpoint to check

# Function to deploy to a server
deploy_to_server() {
    SERVER=$1
    echo "Deploying to $SERVER..."

    # Copy files via SCP
    scp -r "$SOURCE_DIR"/* "user@$SERVER:$DEPLOY_DIR"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to copy files to $SERVER!"
        return 1
    fi

    # Restart service via SSH
    ssh "user@$SERVER" "systemctl restart $SERVICE_NAME"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to restart $SERVICE_NAME on $SERVER!"
        return 1
    fi

    # Health check
    sleep 5  # Wait for service to stabilize
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://$SERVER/health")
    if [ "$STATUS" -ne 200 ]; then
        echo "Error: Health check failed on $SERVER (HTTP $STATUS)!"
        return 1
    fi

    echo "$SERVER deployed successfully."
    return 0
}

# Main deployment loop
for SERVER in "${SERVERS[@]}"; do
    deploy_to_server "$SERVER"
    if [ $? -ne 0 ]; then
        echo "Deployment failed on $SERVER. Rolling back..."
        ssh "user@$SERVER" "systemctl stop $SERVICE_NAME"  # Basic rollback: stop service
        exit 1
    fi
done

echo "All servers deployed successfully!"
