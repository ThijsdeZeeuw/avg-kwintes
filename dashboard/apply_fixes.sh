#!/bin/bash
# Apply port conflict fixes to the docker-compose setup
# This script fixes n8n and other configuration issues

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root or with sudo"
    exit 1
fi

echo "===== Starting configuration fixes ====="

# Set working directory
cd /root/avg-kwintes || { echo "Working directory not found"; exit 1; }

# Update .env file with correct n8n port
echo "Updating .env file..."
if [ -f ".env" ]; then
    # Update n8n port
    sed -i 's/N8N_PORT=.*/N8N_PORT=5678/' ".env"
    echo "- Updated N8N_PORT to 5678"
else
    echo "WARNING: .env file not found. Create it first!"
    exit 1
fi

# Update Caddyfile to use the correct ports
echo "Updating Caddyfile..."
sed -i 's/reverse_proxy n8n:8000/reverse_proxy n8n:5678/' Caddyfile
sed -i 's/reverse_proxy localhost:11434/reverse_proxy ollama:11434/' Caddyfile
sed -i 's/reverse_proxy localhost:8080/reverse_proxy searxng:8080/' Caddyfile
sed -i 's/reverse_proxy open-webui:3000/reverse_proxy open-webui:8080/' Caddyfile
echo "- Updated Caddyfile reverse proxy settings"

# Create override file
echo "Creating docker-compose.override.yml..."
cat > docker-compose.override.yml << 'EOL'
version: '3'

services:
  # Fix n8n port conflict with Supabase
  n8n:
    ports:
      - "5678:5678"
    environment:
      - N8N_PORT=5678
      - N8N_EDITOR_BASE_URL=https://n8n.${DOMAIN_NAME:-kwintes.cloud}
      - N8N_PROTOCOL=${N8N_PROTOCOL:-https}
      - NODE_FUNCTION_ALLOW_EXTERNAL=*
      - N8N_METRICS_ENABLED=true

  # Fix WebUI port mapping
  open-webui:
    ports:
      - "3000:8080"
    networks:
      - monitoring

  # Ensure all services use the monitoring network
  searxng:
    networks:
      - monitoring
    
  ollama-cpu:
    networks:
      - monitoring

  ollama-gpu:
    networks:
      - monitoring

  ollama-gpu-amd:
    networks:
      - monitoring

  flowise:
    networks:
      - monitoring

  qdrant:
    networks:
      - monitoring

  prometheus:
    networks:
      - monitoring

  grafana:
    networks:
      - monitoring

  redis:
    networks:
      - monitoring
EOL
echo "- Created docker-compose.override.yml"

# Update docker-compose.yml if needed
echo "Updating docker-compose.yml..."
sed -i 's/- 8008:8000/- 5678:5678/' docker-compose.yml
echo "- Updated n8n port in docker-compose.yml"

# Restart services
echo "Restarting services..."
docker compose down
docker compose up -d

# Show status
echo "Checking service status..."
sleep 5
docker ps

echo "===== Configuration fixes completed ====="
echo ""
echo "n8n should now be accessible at:"
echo "- https://n8n.kwintes.cloud"
echo "- http://46.202.155.155:5678"
echo ""
echo "Check n8n container logs with: docker logs n8n" 