#!/bin/bash

# Define variables
SERVER_USER="root"
SERVER_IP="185-47-172-213.cloud-xip.com"
LOCAL_PROJECT_DIR="."  # Deploying the entire project directory
REMOTE_DIR="/var/www/ag-server-nextjs-app-01"

echo "Running from directory: $(pwd)"
echo "Deploying project from $LOCAL_PROJECT_DIR to $SERVER_USER@$SERVER_IP:$REMOTE_DIR"

# Sync the entire project to the server excluding node_modules
rsync -avz --delete --exclude='node_modules/' $LOCAL_PROJECT_DIR/ $SERVER_USER@$SERVER_IP:$REMOTE_DIR
if [ $? -eq 0 ]; then
    echo "Rsync completed successfully."
else
    echo "Rsync failed with status $?"
    exit 1
fi

# SSH command to install dependencies, build and restart the application
ssh -t $SERVER_USER@$SERVER_IP << EOF
cd $REMOTE_DIR
npm install
npm run build
pm2 restart all || pm2 start npm --name "next-app" -- start
EOF

if [ $? -eq 0 ]; then
    echo "Commands on server executed successfully."
else
    echo "Server commands failed with status $?"
    exit 1
fi

echo "Deployment complete."
