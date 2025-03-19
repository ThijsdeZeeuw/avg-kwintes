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
sudo ufw allow 5678  # n8n (changed from 8008 to avoid conflict with Supabase)
sudo ufw allow 3001  # Flowise
sudo ufw allow 3005  # Grafana
sudo ufw allow 8000  # Supabase API
sudo ufw allow 8080  # SearXNG
sudo ufw allow 11434 # Ollama
sudo ufw allow 6333  # Qdrant
sudo ufw allow 9090  # Prometheus
sudo ufw allow 54321 # Supabase Studio
sudo ufw reload
```

## Step 3: Clone Repository

```bash
# Clone repository
git clone https://github.com/ThijsdeZeeuw/avg-kwintes.git
cd avg-kwintes
```

## Step 4: Environment Setup

The most user-friendly method is to use the interactive setup option:

```bash
# Run the setup script with interactive mode
python3 start_services.py --interactive
```

This will guide you through the configuration, prompting for important settings:
- Your main domain name
- Email for Let's Encrypt certificates
- Credentials for various services
- System configuration

Alternatively, you can manually create and edit the `.env` file:

```bash
# Copy the example file
cp .env.example .env

# Edit the file with your settings
nano .env
```

Make sure to update at least the following values:
- Domain and URL Settings:
  - `DOMAIN_NAME`: Your main domain (e.g., `yourdomain.com`)
  - `SUBDOMAIN`: The subdomain for n8n (e.g., `n8n`)
  - `N8N_HOST` and `N8N_HOSTNAME`: The hostname for your n8n instance
  - `N8N_PORT`: Set to 5678 to avoid conflict with Supabase's use of port 8000

- Authentication Credentials:
  - `FLOWISE_USERNAME` and `FLOWISE_PASSWORD`: Credentials for Flowise
  - `GRAFANA_ADMIN_USER` and `GRAFANA_ADMIN_PASS`: Credentials for Grafana
  - `DASHBOARD_USERNAME` and `DASHBOARD_PASSWORD`: Credentials for Supabase dashboard

- System Settings:
  - `LETSENCRYPT_EMAIL`: Your email for Let's Encrypt certificates
  - `TZ`: Your timezone (e.g., `Europe/Amsterdam`)
  - `DATA_FOLDER`: Location for persistent data storage

## Step 5: Start Services

```bash
# Run the start script with CPU profile
python3 start_services.py --profile cpu
```

This will:
1. Detect Ubuntu 24.04 and use the standalone docker-compose
2. Clone the Supabase repository 
3. Generate secure keys for SearXNG
4. Start Supabase and the local AI stack

## Step 6: Set Up the Services Dashboard

Now you'll set up a centralized dashboard at your root domain. This dashboard will automatically use the domain configured in your `.env` file:

```bash
# Make the setup script executable
chmod +x dashboard/setup_dashboard.sh

# Run the setup script
sudo ./dashboard/setup_dashboard.sh
```

The script will:
1. Create the dashboard files with a modern, responsive UI
2. Update the Caddyfile to serve the dashboard at your root domain
3. Configure Docker Compose to mount the dashboard directory
4. Restart the Caddy service to apply changes

After running the script, you can access the main dashboard at your root domain (e.g., `https://yourdomain.com`). This dashboard provides:
- Links to all services
- Status indicators showing if each service is running
- Service descriptions and categories

If the script fails, you can perform these steps manually:

```bash
# Create dashboard directory
mkdir -p dashboard

# Edit the Caddyfile to add root domain
nano Caddyfile
# Add the following before the first service entry:
# 
# # Root domain dashboard
# {$DOMAIN_NAME} {
#     root * /etc/caddy/dashboard
#     file_server
#     tls {
#         protocols tls1.2 tls1.3
#     }
# }

# Edit docker-compose.yml to mount dashboard
nano docker-compose.yml
# Add this line in the caddy service, under volumes:
#       - ./dashboard:/etc/caddy/dashboard:ro
# 
# Also add this environment variable:
#       - DOMAIN_NAME=${DOMAIN_NAME:-yourdomain.com}

# Restart Caddy to apply changes
docker restart caddy
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
sudo ./dashboard/fix_caddy.sh
```

This will:
1. Update your .env file to set N8N_PORT=5678
2. Create a docker-compose override to use the correct port
3. Fix the Caddyfile to point to the right port
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

5. **Dashboard Not Loading**

   If the dashboard at your root domain is not loading:
   
   ```bash
   # Check Caddy logs
   docker logs caddy
   
   # Verify the dashboard files exist
   ls -la dashboard/
   
   # Restart Caddy
   docker restart caddy
   ```

6. **Port Conflicts**

   If you see port conflicts between services (particularly n8n and Supabase which both want to use port 8000):
   
   ```bash
   # Apply the fix_caddy.sh script
   sudo ./dashboard/fix_caddy.sh
   ```

7. **n8n Not Working**

   If n8n is still showing the wrong port configuration (like `0.0.0.0:8008->8000/tcp`):
   
   ```bash
   # Stop all containers
   docker compose down
   
   # Apply the fix and restart
   sudo ./dashboard/fix_caddy.sh
   
   # Check n8n container status
   docker ps | grep n8n
   
   # The correct port mapping should be 5678:5678
   ```

## Accessing Services

After installation, you can access the following services:

### Via Domain Names (with configured DNS)

- Main Dashboard: https://kwintes.cloud
- n8n: https://n8n.kwintes.cloud
- Web UI: https://openwebui.kwintes.cloud
- Flowise: https://flowise.kwintes.cloud
- Supabase: https://supabase.kwintes.cloud
- Supabase Studio: https://studio.supabase.kwintes.cloud
- Grafana: https://grafana.kwintes.cloud
- Prometheus: https://prometheus.kwintes.cloud
- Ollama API: https://ollama.kwintes.cloud
- Qdrant API: https://qdrant.kwintes.cloud
- SearXNG: https://searxng.kwintes.cloud

### Via IP Address (replace 46.202.155.155 with your VPS IP)

- Main Dashboard: http://46.202.155.155
- n8n: http://46.202.155.155:5678 (NOT port 8008)
- Web UI (Open WebUI): http://46.202.155.155:3000
- Flowise: http://46.202.155.155:3001
- Supabase API: http://46.202.155.155:8000
- Supabase Studio: http://46.202.155.155:54321
- Grafana: http://46.202.155.155:3005
- Prometheus: http://46.202.155.155:9090
- Ollama API: http://46.202.155.155:11434
- Qdrant API: http://46.202.155.155:6333
- SearXNG: http://46.202.155.155:8080

## n8n Container Configuration

The standard n8n container in our configuration now uses these settings:

```yaml
n8n:
  # Uses the base n8n configuration from x-n8n service
  <<: *service-n8n
  container_name: n8n
  restart: unless-stopped
  ports:
    - 5678:5678  # Changed from 8008:8000 to avoid conflict with Supabase
  environment:
    - N8N_PORT=5678
    - N8N_EDITOR_BASE_URL=https://n8n.${DOMAIN_NAME:-kwintes.cloud}
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