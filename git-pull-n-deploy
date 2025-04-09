#!/bin/bash

# Variables
REPO_URL="https://github.com/yourusername/your-repo.git"
DEPLOY_DIR="/var/www/myapp"
BRANCH="main"
SERVICE_NAME="nodeapp"  # Example: a custom systemd service for a Node.js app

# Check if deploy directory exists, clone if not
if [ ! -d "$DEPLOY_DIR" ]; then
    echo "Cloning repository $REPO_URL into $DEPLOY_DIR..."
    git clone -b "$BRANCH" "$REPO_URL" "$DEPLOY_DIR"
    cd "$DEPLOY_DIR"
else
    echo "Updating repository in $DEPLOY_DIR..."
    cd "$DEPLOY_DIR"
    git fetch origin
    git reset --hard "origin/$BRANCH"
fi

# Install dependencies (e.g., for a Node.js app)
echo "Installing dependencies..."
npm install
if [ $? -ne 0 ]; then
    echo "Error: Dependency installation failed!"
    exit 1
fi

# Restart service
echo "Restarting $SERVICE_NAME..."
systemctl restart "$SERVICE_NAME"
if [ $? -eq 0 ]; then
    echo "Deployment successful!"
else
    echo "Error: Service restart failed!"
    exit 1
fi
