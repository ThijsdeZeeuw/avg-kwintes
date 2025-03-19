#!/bin/bash
# Service Restart Script for Kwintes.cloud VPS
# This script updates the configuration and restarts necessary services

# Check if running as root
if [ "$EUID" -ne 0 ] && [ -z "$SUDO_USER" ]; then
  echo "Please run as root or with sudo"
  exit 1
fi

# Set working directory
if [ -d "/root/avg-kwintes" ]; then
  cd /root/avg-kwintes
else
  echo "Error: Cannot find /root/avg-kwintes directory."
  echo "This script is intended to run on the VPS in the correct directory."
  exit 1
fi

echo "Starting configuration update..."

# Update .env file with correct LETSENCRYPT_EMAIL if needed
if grep -q "LETSENCRYPT_EMAIL=" .env; then
  sed -i 's/LETSENCRYPT_EMAIL=.*/LETSENCRYPT_EMAIL=tddezeeuw@gmail.com/' .env
  echo "Updated LETSENCRYPT_EMAIL in .env file"
else
  echo "LETSENCRYPT_EMAIL=tddezeeuw@gmail.com" >> .env
  echo "Added LETSENCRYPT_EMAIL to .env file"
fi

# Check if Caddyfile.template exists
if [ -f "dashboard/caddyfile.template" ]; then
  echo "Found caddyfile.template, applying to Caddyfile..."
  
  # Apply environment variables to template and create new Caddyfile
  DOMAIN_NAME=$(grep "DOMAIN_NAME=" .env | cut -d '=' -f2 | tr -d '"' | tr -d "'")
  
  # If domain name not found, default to kwintes.cloud
  if [ -z "$DOMAIN_NAME" ]; then
    DOMAIN_NAME="kwintes.cloud"
    echo "Domain not found in .env, using default: $DOMAIN_NAME"
  else
    echo "Using domain from .env: $DOMAIN_NAME"
  fi
  
  cp dashboard/caddyfile.template Caddyfile
  echo "Applied Caddyfile template"
fi

# Stop Caddy container
echo "Stopping Caddy container..."
docker stop caddy

# Check and create dashboard directory if needed
if [ ! -d "dashboard" ]; then
  mkdir -p dashboard
  echo "Created dashboard directory"
fi

# Run dashboard setup to ensure files are created
echo "Running dashboard setup..."
bash dashboard/setup_dashboard.sh

# Start Caddy container
echo "Starting Caddy container..."
docker start caddy

# Check Caddy logs
echo "Checking Caddy logs..."
sleep 5
docker logs caddy

echo "Checking all service status..."
docker ps

echo "Configuration update completed."
echo ""
echo "If Caddy is still restarting, check detailed logs with: docker logs caddy"
echo "You may need to restart all services with: docker compose down && docker compose up -d" 