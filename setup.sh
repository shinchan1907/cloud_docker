#!/bin/bash

# Create data directories
mkdir -p traefik-data redis-data n8n-data evolution-data

# Fix permissions for n8n and Evolution (Node.js containers usually run as user 1000)
# We use sudo here because this script is typically run on the server
echo "Setting permissions..."
sudo chown -R 1000:1000 n8n-data
sudo chown -R 1000:1000 evolution-data
sudo chown -R 1000:1000 redis-data

echo "Directories created and permissions set."
