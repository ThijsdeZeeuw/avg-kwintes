# Ubuntu 24.04 Setup Guide for Local AI Stack

This guide provides specific instructions for setting up the Local AI Stack on Ubuntu 24.04 LTS.

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
sudo ufw allow 8000  # n8n
sudo ufw allow 3001  # Flowise
sudo ufw allow 3000  # Web UI & Grafana
sudo ufw allow 5678  # n8n webhook
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
git clone https://github.com/Z4Y/avg-kwintes.git
cd avg-kwintes
```

## Step 4: Environment Setup

First, open the `.env.example` file and review it:

```bash
nano .env.example
```

Set at least the following values:
- Domain and URL Settings:
  - `DOMAIN_NAME`: Your main domain (e.g., `kwintes.cloud`)
  - `SUBDOMAIN`: The subdomain for n8n (e.g., `n8n`)
  - `N8N_HOST` and `N8N_HOSTNAME`: The hostname for your n8n instance

- Authentication Credentials:
  - `FLOWISE_USERNAME` and `FLOWISE_PASSWORD`: Credentials for Flowise
  - `GRAFANA_ADMIN_USER` and `GRAFANA_ADMIN_PASS`: Credentials for Grafana
  - `DASHBOARD_USERNAME` and `DASHBOARD_PASSWORD`: Credentials for Supabase dashboard

- System Settings:
  - `LETSENCRYPT_EMAIL`: Your email for Let's Encrypt certificates
  - `TZ`: Your timezone (e.g., `Germany/Berlin`)
  - `DATA_FOLDER`: Location for persistent data storage

After reviewing, save it as `.env`:

```bash
cp .env.example .env
```

Or use the interactive setup to generate a configuration:

```bash
python3 start_services.py --interactive
```

## Step 5: Start Services

The updated start_services.py script includes specific handling for Ubuntu 24.04:

```bash
# Run the start script with CPU profile
python3 start_services.py --use-example --profile cpu
```

This will:
1. Detect Ubuntu 24.04 and use the standalone docker-compose
2. Clone the Supabase repository 
3. Generate secure keys for SearXNG
4. Start Supabase and the local AI stack

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

## Accessing Services

After installation, you can access the following services:

- n8n: https://n8n.your-domain.com
- Web UI: https://openwebui.your-domain.com
- Flowise: https://flowise.your-domain.com
- Supabase: https://supabase.your-domain.com
- Supabase Studio: http://localhost:54321 or https://studio.supabase.your-domain.com
- Grafana: https://grafana.your-domain.com
- Prometheus: https://prometheus.your-domain.com
- Whisper API: https://whisper.your-domain.com
- Qdrant API: https://qdrant.your-domain.com 