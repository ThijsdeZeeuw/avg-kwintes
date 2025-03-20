# Ubuntu 24.04 Setup Guide for Local AI Stack

This guide provides specific instructions for setting up the Local AI Stack on Ubuntu 24.04 LTS.

> **Note:** This project is based on work from [coleam00/local-ai-packaged](https://github.com/coleam00/local-ai-packaged) and [Digitl-Alchemyst/Automation-Stack](https://github.com/Digitl-Alchemyst/Automation-Stack) with customizations and improvements.

## Prerequisites

- Ubuntu 24.04 LTS (Noble Numbat)
- Root or sudo access to the server
- A domain name with DNS access (pointed to your server IP)

## Step 1: Initial Server Setup

Connect to your server and install required packages:

```bash
# Update the package lists
sudo apt update

# Install essential packages
sudo apt install -y nano git curl python3 python3-pip

# Install Docker
sudo apt install -y docker.io

# Install standalone Docker Compose (required for Ubuntu 24.04)
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker --version
/usr/local/bin/docker-compose --version
```

## Step 2: Configure Firewall

```bash
# Enable and configure firewall
sudo ufw enable
sudo ufw allow 22    # SSH
sudo ufw allow 80    # HTTP
sudo ufw allow 443   # HTTPS
sudo ufw allow 5678  # n8n (using port 5678 to avoid conflict with Supabase)
sudo ufw allow 3001  # Flowise
sudo ufw allow 8080  # Open WebUI
sudo ufw allow 3000  # Grafana
sudo ufw allow 8000  # Supabase API
sudo ufw allow 9090  # Prometheus
sudo ufw allow 11434 # Ollama
sudo ufw allow 6333  # Qdrant
sudo ufw allow 54321 # Supabase Studio
sudo ufw reload
```

## Step 3: Clone Repository

```bash
# Clone repository
git clone https://github.com/ThijsdeZeeuw/avg-kwintes.git
cd avg-kwintes
```

## Step 4: Pre-Configuration

Before setting up the environment, run the pre-configuration script to ensure all prerequisites are met and port conflicts are resolved:

```bash
# Make the script executable
chmod +x fix_config.sh

# Run the configuration preparation script
sudo ./fix_config.sh
```

This script will:

1. Check and install required packages (Docker, Docker Compose, net-tools)
2. Configure firewall settings for all needed ports
3. Detect any port conflicts and update configuration accordingly
4. Create a basic .env file if one doesn't exist
5. Generate utility scripts for updates and backups

## Step 5: Environment Setup

Now run the interactive setup script to finish configuration:

```bash
# Run the setup script with interactive mode
python3 start_services.py --interactive
```

This will guide you through the remaining configuration steps, prompting for important settings:
- Your main domain name
- Email for Let's Encrypt certificates
- Credentials for various services
- System configuration

## Step 6: Start Services

After completing the interactive setup, start all services with:

```bash
# Run the start script with CPU profile
python3 start_services.py --profile cpu
```

This will:
1. Detect Ubuntu 24.04 and use the standalone docker-compose
2. Clone the Supabase repository 
3. Generate secure keys for SearXNG
4. Start Supabase and the local AI stack

## Accessing Services

After installation, you can access the following services:

### Via Domain Names (with configured DNS)

- n8n: https://n8n.kwintes.cloud
- Web UI: https://openwebui.kwintes.cloud
- Flowise: https://flowise.kwintes.cloud
- Supabase: https://supabase.kwintes.cloud
- Supabase Studio: https://studio.supabase.kwintes.cloud
- Grafana: https://grafana.kwintes.cloud
- Prometheus: https://prometheus.kwintes.cloud
- Ollama API: https://ollama.kwintes.cloud
- Qdrant API: https://qdrant.kwintes.cloud

### Via IP Address (replace 46.202.155.155 with your VPS IP)

- Main Entry Point: http://46.202.155.155 (redirects to n8n)
- n8n: http://46.202.155.155:5678
- Web UI (Open WebUI): http://46.202.155.155:8080
- Flowise: http://46.202.155.155:3001
- Supabase API: http://46.202.155.155:8000
- Supabase Studio: http://46.202.155.155:54321
- Grafana: http://46.202.155.155:3000
- Prometheus: http://46.202.155.155:9090
- Ollama API: http://46.202.155.155:11434
- Qdrant API: http://46.202.155.155:6333

## n8n Container Configuration

The standard n8n container in our configuration now uses these settings:

```yaml
n8n:
  # Uses the base n8n configuration from x-n8n service
  <<: *service-n8n
  container_name: n8n
  restart: unless-stopped
  ports:
    - 5678:5678  # Using port 5678 to avoid conflict with Supabase
  environment:
    - N8N_PORT=5678
    - N8N_EDITOR_BASE_URL=https://n8n.${DOMAIN_NAME:-kwintes.cloud}
    - N8N_PROTOCOL=${N8N_PROTOCOL:-https}
    - NODE_FUNCTION_ALLOW_EXTERNAL=*
    - N8N_METRICS_ENABLED=true
    # These settings ensure external API access works properly
    - N8N_SECURE_COOKIE=false 
    - N8N_SKIP_WEBHOOK_DEREGISTRATION_SHUTDOWN=true
    - WEBHOOK_URL=https://${SUBDOMAIN:-n8n}.${DOMAIN_NAME:-kwintes.cloud}/
  volumes:
    - n8n_storage:/home/node/.n8n
    - ./n8n/backup:/backup
    - ./shared:/data/shared
  networks:
    - monitoring
```

---

Adapted and customized from the original projects:
- [coleam00/local-ai-packaged](https://github.com/coleam00/local-ai-packaged)
- [Digitl-Alchemyst/Automation-Stack](https://github.com/Digitl-Alchemyst/Automation-Stack) 

## Troubleshooting

### Common Issues on Ubuntu 24.04

1. **Docker Compose not found**

   If you encounter errors about docker-compose, ensure it's installed correctly:
   
   ```bash
   sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   ```

2. **Permission Issues**

   If you encounter permission issues with Docker:
   
   ```bash
   sudo usermod -aG docker $USER
   # Log out and log back in, or run:
   newgrp docker
   ```

3. **Service not accessible**

   Check your firewall settings and ensure the services are running:
   
   ```bash
   sudo ufw status
   /usr/local/bin/docker-compose -p localai ps
   ```

4. **Logs**

   Check the logs for troubleshooting:
   
   ```bash
   /usr/local/bin/docker-compose -p localai logs -f [service_name]
   ```

5. **n8n Interface Not Loading**

   If the n8n interface at your root domain is not loading:
   
   ```bash
   # Check Caddy logs
   docker logs caddy
   
   # Restart Caddy
   docker restart caddy
   ```

6. **Port Conflicts**

   If you see port conflicts between services (particularly n8n and Supabase which both want to use port 8000):
   
   ```bash
   # Apply the apply_fixes.sh script
   sudo ./apply_fixes.sh
   ```

7. **n8n Not Working**

   If n8n is still showing the wrong port configuration (like `0.0.0.0:8008->8000/tcp`):
   
   ```bash
   # Stop all containers
   docker compose down
   
   # Apply the fix and restart
   sudo ./apply_fixes.sh
   
   # Check n8n container status
   docker ps | grep n8n
   
   # The correct port mapping should be 5678:5678
   ```

## Connecting n8n to External APIs

For n8n to properly connect to external APIs and receive webhooks, the following environment variables have been added:

```
WEBHOOK_URL=https://${SUBDOMAIN}.${DOMAIN_NAME}/
GENERIC_TIMEZONE=${TZ}
NODE_FUNCTION_ALLOW_EXTERNAL=*
```

These variables will:

1. **WEBHOOK_URL**: Set the base URL for webhooks to reach your n8n instance
2. **GENERIC_TIMEZONE**: Set the timezone for n8n workflows to match your system
3. **NODE_FUNCTION_ALLOW_EXTERNAL**: Allow n8n to connect to any external API

If you're experiencing issues connecting to external APIs:

1. Ensure your domain is properly configured with DNS records
2. Check that your SSL certificates are valid
3. Verify the SUBDOMAIN and DOMAIN_NAME variables are correctly set in your .env file
4. Test webhook endpoints using a tool like Postman or Insomnia

## Important: n8n Port Configuration

**Note:** There is a critical configuration that needs to be fixed for n8n to work properly. The default setup has a port conflict between n8n and Supabase (both want to use port 8000 internally). To fix this, we've configured n8n to use port 5678 instead.

If your n8n service is still configured with the old port mapping (showing as `0.0.0.0:8008->8000/tcp`), you need to apply the fix:

```bash
# Run the fix script
sudo ./apply_fixes.sh
```

This will:
1. Update your .env file to set N8N_PORT=5678
2. Update the Caddyfile to point to the right port
3. Update docker-compose.yml with the correct port mappings
4. Restart all services

## Troubleshooting

### Common Issues on Ubuntu 24.04

1. **Docker Compose not found**

   If you encounter errors about docker-compose, ensure it's installed correctly:
   
   ```bash
   sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   ```

2. **Permission Issues**

   If you encounter permission issues with Docker:
   
   ```bash
   sudo usermod -aG docker $USER
   # Log out and log back in, or run:
   newgrp docker
   ```

3. **Service not accessible**

   Check your firewall settings and ensure the services are running:
   
   ```bash
   sudo ufw status
   /usr/local/bin/docker-compose -p localai ps
   ```

4. **Logs**

   Check the logs for troubleshooting:
   
   ```bash
   /usr/local/bin/docker-compose -p localai logs -f [service_name]
   ```

5. **n8n Interface Not Loading**

   If the n8n interface at your root domain is not loading:
   
   ```bash
   # Check Caddy logs
   docker logs caddy
   
   # Restart Caddy
   docker restart caddy
   ```

6. **Port Conflicts**

   If you see port conflicts between services (particularly n8n and Supabase which both want to use port 8000):
   
   ```bash
   # Apply the apply_fixes.sh script
   sudo ./apply_fixes.sh
   ```

7. **n8n Not Working**

   If n8n is still showing the wrong port configuration (like `0.0.0.0:8008->8000/tcp`):
   
   ```bash
   # Stop all containers
   docker compose down
   
   # Apply the fix and restart
   sudo ./apply_fixes.sh
   
   # Check n8n container status
   docker ps | grep n8n
   
   # The correct port mapping should be 5678:5678
   ```

## Accessing Services

After installation, you can access the following services:

### Via Domain Names (with configured DNS)

- n8n: https://n8n.kwintes.cloud
- Web UI: https://openwebui.kwintes.cloud
- Flowise: https://flowise.kwintes.cloud
- Supabase: https://supabase.kwintes.cloud
- Supabase Studio: https://studio.supabase.kwintes.cloud
- Grafana: https://grafana.kwintes.cloud
- Prometheus: https://prometheus.kwintes.cloud
- Ollama API: https://ollama.kwintes.cloud
- Qdrant API: https://qdrant.kwintes.cloud

### Via IP Address (replace 46.202.155.155 with your VPS IP)

- Main Entry Point: http://46.202.155.155 (redirects to n8n)
- n8n: http://46.202.155.155:5678
- Web UI (Open WebUI): http://46.202.155.155:8080
- Flowise: http://46.202.155.155:3001
- Supabase API: http://46.202.155.155:8000
- Supabase Studio: http://46.202.155.155:54321
- Grafana: http://46.202.155.155:3000
- Prometheus: http://46.202.155.155:9090
- Ollama API: http://46.202.155.155:11434
- Qdrant API: http://46.202.155.155:6333

## n8n Container Configuration

The standard n8n container in our configuration now uses these settings:

```yaml
n8n:
  # Uses the base n8n configuration from x-n8n service
  <<: *service-n8n
  container_name: n8n
  restart: unless-stopped
  ports:
    - 5678:5678  # Using port 5678 to avoid conflict with Supabase
  environment:
    - N8N_PORT=5678
    - N8N_EDITOR_BASE_URL=https://n8n.${DOMAIN_NAME:-kwintes.cloud}
    - N8N_PROTOCOL=${N8N_PROTOCOL:-https}
    - NODE_FUNCTION_ALLOW_EXTERNAL=*
    - N8N_METRICS_ENABLED=true
    # These settings ensure external API access works properly
    - N8N_SECURE_COOKIE=false 
    - N8N_SKIP_WEBHOOK_DEREGISTRATION_SHUTDOWN=true
    - WEBHOOK_URL=https://${SUBDOMAIN:-n8n}.${DOMAIN_NAME:-kwintes.cloud}/
  volumes:
    - n8n_storage:/home/node/.n8n
    - ./n8n/backup:/backup
    - ./shared:/data/shared
  networks:
    - monitoring
```

---

Adapted and customized from the original projects:
- [coleam00/local-ai-packaged](https://github.com/coleam00/local-ai-packaged)
- [Digitl-Alchemyst/Automation-Stack](https://github.com/Digitl-Alchemyst/Automation-Stack) 