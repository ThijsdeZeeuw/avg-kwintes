#!/bin/bash
# Fix Script for Kwintes.cloud VPS
# This script fixes the Caddy configuration and domain issues

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root or with sudo"
    exit 1
fi

# Set working directory
WORKING_DIR="/root/avg-kwintes"
if [ ! -d "$WORKING_DIR" ]; then
    echo "Working directory not found: $WORKING_DIR"
    echo "Please run this script from the correct directory"
    exit 1
fi

cd "$WORKING_DIR"

echo "===== Starting Caddy and Subdomain Fix ====="

# 1. Update .env file with correct email and timezone
echo "Updating .env file..."
if [ -f ".env" ]; then
    # Check if LETSENCRYPT_EMAIL already exists
    if grep -q "LETSENCRYPT_EMAIL=" ".env"; then
        # Update existing entry
        sed -i 's/LETSENCRYPT_EMAIL=.*/LETSENCRYPT_EMAIL=tddezeeuw@gmail.com/' ".env"
    else
        # Add new entry
        echo "LETSENCRYPT_EMAIL=tddezeeuw@gmail.com" >> ".env"
    fi
    
    # Set timezone
    if grep -q "TZ=" ".env"; then
        sed -i 's/TZ=.*/TZ=Europe\/Amsterdam/' ".env"
    else
        echo "TZ=Europe/Amsterdam" >> ".env"
    fi

    # Modify n8n port to avoid conflict with Supabase
    if grep -q "N8N_PORT=" ".env"; then
        sed -i 's/N8N_PORT=.*/N8N_PORT=5678/' ".env"
    else
        echo "N8N_PORT=5678" >> ".env"
    fi
else
    # Create .env file
    cat > ".env" << EOF
DOMAIN_NAME=kwintes.cloud
LETSENCRYPT_EMAIL=tddezeeuw@gmail.com
TZ=Europe/Amsterdam
N8N_PORT=5678
EOF
    echo "Created new .env file"
fi

# 2. Apply the updated Caddyfile
echo "Creating updated Caddyfile..."
cat > Caddyfile << 'EOL'
{
    # Global options
    email tddezeeuw@gmail.com
    auto_https on
    admin off
    servers {
        protocol {
            experimental_http3
        }
    }
}

# Root domain dashboard
{$DOMAIN_NAME} {
    root * /etc/caddy/dashboard
    file_server
    tls {
        protocols tls1.2 tls1.3
    }
}

# N8N
{$N8N_HOSTNAME} {
    reverse_proxy n8n:5678
    tls {
        protocols tls1.2 tls1.3
    }
}

# Open WebUI
{$WEBUI_HOSTNAME} {
    reverse_proxy open-webui:8080
    tls {
        protocols tls1.2 tls1.3
    }
}

# Flowise
{$FLOWISE_HOSTNAME} {
    reverse_proxy flowise:3001
    tls {
        protocols tls1.2 tls1.3
    }
}

# Ollama API
{$OLLAMA_HOSTNAME} {
    reverse_proxy ollama:11434
    tls {
        protocols tls1.2 tls1.3
    }
}

# Supabase
{$SUPABASE_HOSTNAME} {
    reverse_proxy supabase-studio:3000
    tls {
        protocols tls1.2 tls1.3
    }
}

# SearXNG
{$SEARXNG_HOSTNAME} {
    encode zstd gzip
    
    @api {
        path /config
        path /healthz
        path /stats/errors
        path /stats/checker
    }
    @search {
        path /search
    }
    @imageproxy {
        path /image_proxy
    }
    @static {
        path /static/*
    }
    
    header {
        # CSP (https://content-security-policy.com)
        Content-Security-Policy "upgrade-insecure-requests; default-src 'none'; script-src 'self'; style-src 'self' 'unsafe-inline'; form-action 'self' https://github.com/searxng/searxng/issues/new; font-src 'self'; frame-ancestors 'self'; base-uri 'self'; connect-src 'self' https://overpass-api.de; img-src * data:; frame-src https://www.youtube-nocookie.com https://player.vimeo.com https://www.dailymotion.com https://www.deezer.com https://www.mixcloud.com https://w.soundcloud.com https://embed.spotify.com;"
        # Disable some browser features
        Permissions-Policy "accelerometer=(),camera=(),geolocation=(),gyroscope=(),magnetometer=(),microphone=(),payment=(),usb=()"
        # Set referrer policy
        Referrer-Policy "no-referrer"
        # Force clients to use HTTPS
        Strict-Transport-Security "max-age=31536000"
        # Prevent MIME type sniffing from the declared Content-Type
        X-Content-Type-Options "nosniff"
        # X-Robots-Tag (comment to allow site indexing)
        X-Robots-Tag "noindex, noarchive, nofollow"
        # Remove "Server" header
        -Server
    }
    
    header @api {
        Access-Control-Allow-Methods "GET, OPTIONS"
        Access-Control-Allow-Origin "*"
    }
    
    route {
        # Cache policy
        header Cache-Control "max-age=0, no-store"
        header @search Cache-Control "max-age=5, private"
        header @imageproxy Cache-Control "max-age=604800, public"
        header @static Cache-Control "max-age=31536000, public, immutable"
    }
    
    # SearXNG (uWSGI)
    reverse_proxy searxng:8080 {
        header_up X-Forwarded-Port {http.request.port}
        header_up X-Real-IP {http.request.remote.host}
        # https://github.com/searx/searx-docker/issues/24
        header_up Connection "close"
    }
    tls {
        protocols tls1.2 tls1.3
    }
}

# Grafana
grafana.{$DOMAIN_NAME} {
    reverse_proxy grafana:3000
    tls {
        protocols tls1.2 tls1.3
    }
}

# Prometheus
prometheus.{$DOMAIN_NAME} {
    reverse_proxy prometheus:9090
    tls {
        protocols tls1.2 tls1.3
    }
}

# Qdrant API
qdrant.{$DOMAIN_NAME} {
    reverse_proxy qdrant:6333
    tls {
        protocols tls1.2 tls1.3
    }
}
EOL
echo "- Created updated Caddyfile"

# 3. Create a temporary docker-compose file to fix the Caddy configuration
echo "Creating docker-compose override file..."
cat > docker-compose.override.yml << 'EOL'
version: '3'

services:
  # Fix n8n port mapping to avoid conflict with Supabase
  n8n:
    ports:
      - 5678:5678
    environment:
      - N8N_PORT=5678
      - N8N_EDITOR_BASE_URL=https://n8n.${DOMAIN_NAME:-kwintes.cloud}

  caddy:
    image: docker.io/library/caddy:2-alpine
    ports:
      - "80:80"
      - "443:443"
    restart: unless-stopped
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - ./dashboard:/etc/caddy/dashboard:ro
      - caddy-data:/data:rw
      - caddy-config:/config:rw
    environment:
      - N8N_HOSTNAME=n8n.${DOMAIN_NAME:-kwintes.cloud}
      - WEBUI_HOSTNAME=openwebui.${DOMAIN_NAME:-kwintes.cloud}
      - FLOWISE_HOSTNAME=flowise.${DOMAIN_NAME:-kwintes.cloud}
      - OLLAMA_HOSTNAME=ollama.${DOMAIN_NAME:-kwintes.cloud}
      - SUPABASE_HOSTNAME=supabase.${DOMAIN_NAME:-kwintes.cloud}
      - SEARXNG_HOSTNAME=searxng.${DOMAIN_NAME:-kwintes.cloud}
      - LETSENCRYPT_EMAIL=${LETSENCRYPT_EMAIL:-tddezeeuw@gmail.com}
      - TZ=${TZ:-Europe/Amsterdam}
      - DOMAIN_NAME=${DOMAIN_NAME:-kwintes.cloud}
    networks:
      - monitoring
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
    logging:
      driver: "json-file"
      options:
        max-size: "1m"
        max-file: "1"
EOL
echo "- Created docker-compose.override.yml"

# 4. Set up the dashboard
echo "Setting up dashboard..."
mkdir -p dashboard
if [ -f "dashboard/setup_dashboard.sh" ]; then
  chmod +x dashboard/setup_dashboard.sh
  ./dashboard/setup_dashboard.sh
  echo "- Dashboard setup completed"
else
  echo "- Dashboard setup script not found, creating basic dashboard files..."
  # Create basic index.html
  mkdir -p dashboard
  echo "<html><body><h1>Kwintes.cloud Dashboard</h1><p>Dashboard is being set up...</p></body></html>" > dashboard/index.html
  echo "- Created basic dashboard files"
fi

# 5. Stop and restart services
echo "Restarting services..."
echo "- Stopping containers..."
docker compose down

echo "- Starting containers with fixed configuration..."
docker compose -f docker-compose.yml -f docker-compose.override.yml up -d

# 6. Check service status
echo "Checking service status..."
sleep 5
docker ps

# 7. Check Caddy logs
echo "Checking Caddy logs (showing last 20 lines)..."
docker logs caddy --tail 20

echo "===== Fix completed ====="
echo ""
echo "If Caddy is still having issues:"
echo "1. Check full logs with: docker logs caddy"
echo "2. Verify DNS records for kwintes.cloud and subdomains"
echo "3. Ensure ports 80 and 443 are open on the firewall"
echo ""
echo "Services should be accessible at:"
echo "- Dashboard: https://kwintes.cloud"
echo "- n8n: https://n8n.kwintes.cloud"
echo "- Open WebUI: https://openwebui.kwintes.cloud"
echo "- And other subdomains as configured" 