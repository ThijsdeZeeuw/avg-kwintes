#!/bin/bash
# Configuration Script for Local AI Stack on Ubuntu 24.04
# Prepares environment before running start_services.py

set -e # Exit on error

# Display banner
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║   Local AI Stack - VPS Configuration Tool for Ubuntu 24.04 ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "❌ This script must be run as root or with sudo"
    exit 1
fi

# Set working directory
if [ -d "/root/avg-kwintes" ]; then
    cd /root/avg-kwintes
elif [ -d "$(dirname "$0")" ]; then
    cd "$(dirname "$0")"
else
    echo "❌ Working directory not found. Run this script from the project directory."
    exit 1
fi

echo "📂 Working directory: $(pwd)"

# Define color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to check if a port is in use
check_port() {
    local port=$1
    if netstat -tuln | grep -q ":$port "; then
        return 0  # Port is in use
    else
        return 1  # Port is free
    fi
}

# Function to find a free port starting from the given port
find_free_port() {
    local start_port=$1
    local port=$start_port
    local max_attempts=10
    local attempts=0

    echo -e "${YELLOW}! Port $start_port is already in use. Searching for a free port...${NC}"
    
    while check_port $port && [ $attempts -lt $max_attempts ]; do
        port=$((port + 1))
        attempts=$((attempts + 1))
    done

    if [ $attempts -eq $max_attempts ]; then
        echo -e "${RED}❌ Could not find a free port after $max_attempts attempts${NC}"
        return $start_port
    fi

    echo -e "${GREEN}✓ Found free port: $port${NC}"
    return $port
}

# 1. Check required packages
echo -e "${BLUE}🔧 Checking required packages...${NC}"

# Check if netstat is installed
if ! command -v netstat >/dev/null 2>&1; then
    echo -e "${YELLOW}! netstat not installed. Installing net-tools...${NC}"
    apt-get update
    apt-get install -y net-tools
    echo -e "${GREEN}✓ net-tools installed${NC}"
fi

# 2. Check for Docker installation and proper versions
echo -e "${BLUE}🔧 Checking Docker installation...${NC}"
if ! command -v docker >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not installed. Installing Docker...${NC}"
    apt-get update
    apt-get install -y docker.io
    systemctl enable docker
    systemctl start docker
    echo -e "${GREEN}✓ Docker installed successfully${NC}"
else
    DOCKER_VERSION=$(docker --version | cut -d ' ' -f3 | cut -d ',' -f1)
    echo -e "${GREEN}✓ Docker version: $DOCKER_VERSION${NC}"
fi

# 3. Check Docker Compose installation
echo -e "${BLUE}🔧 Checking Docker Compose installation...${NC}"

# First check for standalone docker-compose (recommended for Ubuntu 24.04)
if [ -x "/usr/local/bin/docker-compose" ]; then
    DOCKER_COMPOSE_CMD="/usr/local/bin/docker-compose"
    DOCKER_COMPOSE_VERSION=$($DOCKER_COMPOSE_CMD --version | cut -d ' ' -f3 | cut -d ',' -f1)
    echo -e "${GREEN}✓ Docker Compose standalone version: $DOCKER_COMPOSE_VERSION${NC}"
# Then check for system-installed docker-compose
elif command -v docker-compose >/dev/null 2>&1; then
    DOCKER_COMPOSE_CMD="docker-compose"
    DOCKER_COMPOSE_VERSION=$(docker-compose --version | cut -d ' ' -f3 | cut -d ',' -f1)
    echo -e "${GREEN}✓ Docker Compose version: $DOCKER_COMPOSE_VERSION${NC}"
# Then check for Docker Compose plugin
elif docker compose version >/dev/null 2>&1; then
    DOCKER_COMPOSE_CMD="docker compose"
    DOCKER_COMPOSE_VERSION=$(docker compose version --short)
    echo -e "${GREEN}✓ Docker Compose plugin version: $DOCKER_COMPOSE_VERSION${NC}"
# If none found, install standalone Docker Compose
else
    echo -e "${YELLOW}! Docker Compose not found. Installing Docker Compose...${NC}"
    curl -L "https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    DOCKER_COMPOSE_CMD="/usr/local/bin/docker-compose"
    DOCKER_COMPOSE_VERSION=$($DOCKER_COMPOSE_CMD --version | cut -d ' ' -f3 | cut -d ',' -f1 || echo "Unknown")
    echo -e "${GREEN}✓ Docker Compose installed version: $DOCKER_COMPOSE_VERSION${NC}"
fi

# 4. Update firewall settings
echo -e "${BLUE}🔧 Checking firewall settings...${NC}"
if command -v ufw > /dev/null; then
    echo -e "${YELLOW}! Configuring UFW firewall...${NC}"
    ufw status | grep -q "Status: active" || ufw enable
    
    # Define ports to open
    declare -A ports=(
        ["SSH"]="22"
        ["HTTP"]="80"
        ["HTTPS"]="443"
        ["n8n"]="5678"
        ["Flowise"]="3001"
        ["OpenWebUI"]="8080"
        ["Grafana"]="3000"
        ["Supabase API"]="8000"
        ["Ollama"]="11434"
        ["Qdrant"]="6333"
        ["Prometheus"]="9090"
        ["Supabase Studio"]="54321"
    )
    
    # Check and open ports
    for service in "${!ports[@]}"; do
        port="${ports[$service]}"
        if ! ufw status | grep -q "$port/tcp"; then
            echo -e "${YELLOW}! Opening port $port for $service${NC}"
            ufw allow "$port/tcp"
        else
            echo -e "${GREEN}✓ Port $port already open for $service${NC}"
        fi
    done
    
    echo -e "${GREEN}✓ Firewall configured${NC}"
else
    echo -e "${YELLOW}! UFW not installed. Please configure your firewall manually.${NC}"
fi

# 5. Check for port conflicts and update configuration if needed
echo -e "${BLUE}🔍 Checking for port conflicts...${NC}"

# 5.1 First check if .env exists
if [ -f ".env" ]; then
    # Load current values from .env
    source .env
    
    # Update n8n port to avoid conflict with Supabase
    sed -i 's/N8N_PORT=.*/N8N_PORT=5678/' ".env"
    
    # Ensure LETSENCRYPT_EMAIL is set
    if grep -q "LETSENCRYPT_EMAIL=" ".env"; then
        if [ -z "$LETSENCRYPT_EMAIL" ]; then
            echo -e "${YELLOW}! Setting default LETSENCRYPT_EMAIL${NC}"
            sed -i 's/LETSENCRYPT_EMAIL=.*/LETSENCRYPT_EMAIL=tddezeeuw@gmail.com/' ".env"
        fi
    else
        echo "LETSENCRYPT_EMAIL=tddezeeuw@gmail.com" >> ".env"
    fi
    
    # Set timezone if not already set
    if grep -q "TZ=" ".env"; then
        if [ -z "$TZ" ]; then
            echo -e "${YELLOW}! Setting default timezone${NC}"
            sed -i 's/TZ=.*/TZ=Europe\/Amsterdam/' ".env"
        fi
    else
        echo "TZ=Europe/Amsterdam" >> ".env"
    fi
    
    # Verify domain name is set
    if ! grep -q "DOMAIN_NAME=" ".env" || [ -z "$DOMAIN_NAME" ]; then
        read -p "Enter your domain name (e.g., example.com): " domain_name
        if [ -n "$domain_name" ]; then
            if grep -q "DOMAIN_NAME=" ".env"; then
                sed -i "s/DOMAIN_NAME=.*/DOMAIN_NAME=$domain_name/" ".env"
            else
                echo "DOMAIN_NAME=$domain_name" >> ".env"
            fi
            DOMAIN_NAME="$domain_name"
        else
            echo -e "${YELLOW}! Using default domain: kwintes.cloud${NC}"
            if grep -q "DOMAIN_NAME=" ".env"; then
                sed -i "s/DOMAIN_NAME=.*/DOMAIN_NAME=kwintes.cloud/" ".env"
            else
                echo "DOMAIN_NAME=kwintes.cloud" >> ".env"
            fi
            DOMAIN_NAME="kwintes.cloud"
        fi
    fi
    
    echo -e "${GREEN}✓ Updated .env file with correct settings${NC}"
else
    # Create basic .env file if it doesn't exist
    echo -e "${YELLOW}! .env file not found. Creating basic configuration.${NC}"
    
    read -p "Enter your domain name (e.g., example.com): " domain_name
    if [ -z "$domain_name" ]; then
        domain_name="kwintes.cloud"
        echo -e "${YELLOW}! Using default domain: kwintes.cloud${NC}"
    fi
    
    cat > ".env" << EOF
# Basic configuration generated by fix_config.sh
DOMAIN_NAME=${domain_name}
SUBDOMAIN=n8n
LETSENCRYPT_EMAIL=tddezeeuw@gmail.com
TZ=Europe/Amsterdam
N8N_PORT=5678
N8N_HOSTNAME=n8n.${domain_name}
WEBUI_HOSTNAME=openwebui.${domain_name}
FLOWISE_HOSTNAME=flowise.${domain_name}
SUPABASE_HOSTNAME=supabase.${domain_name}
OLLAMA_HOSTNAME=ollama.${domain_name}
SEARXNG_HOSTNAME=searxng.${domain_name}
FLOWISE_USERNAME=admin
FLOWISE_PASSWORD=password
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASS=password
N8N_ENCRYPTION_KEY=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 32)
N8N_USER_MANAGEMENT_JWT_SECRET=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 32)
EOF
    
    echo -e "${GREEN}✓ Created basic .env file${NC}"
    echo -e "${YELLOW}! Please review the .env file settings before starting services${NC}"
    
    # Load the newly created .env
    source .env
    DOMAIN_NAME="$domain_name"
fi

# 5.2 Check for port conflicts for key services
# Define service ports with their default and internal values
declare -A service_ports=(
    ["n8n"]="5678:5678"
    ["open-webui"]="8080:8080"
    ["flowise"]="3001:3001"
    ["grafana"]="3000:3000"
    ["prometheus"]="9090:9090"
    ["qdrant"]="6333:6333"
    ["ollama"]="11434:11434"
    ["supabase"]="54321:54321"
)

# Store port assignments for .env update
port_config_changes=()

# Check and adjust ports for each service
for service in "${!service_ports[@]}"; do
    mapping="${service_ports[$service]}"
    external_port=$(echo $mapping | cut -d':' -f1)
    internal_port=$(echo $mapping | cut -d':' -f2)
    
    echo -e "${BLUE}  Checking port $external_port for $service...${NC}"
    
    if check_port $external_port; then
        echo -e "${YELLOW}! Port $external_port is already in use${NC}"
        # Find a free port
        find_free_port $external_port
        new_port=$?
        
        if [ $new_port != $external_port ]; then
            echo -e "${YELLOW}! Setting $service to use port $new_port instead of $external_port${NC}"
            service_ports[$service]="$new_port:$internal_port"
            
            # Add to port changes list for .env update
            case $service in
                "n8n")
                    port_config_changes+=("N8N_PORT=$new_port")
                    ;;
                "open-webui")
                    port_config_changes+=("WEBUI_PORT=$new_port")
                    ;;
                "flowise")
                    port_config_changes+=("FLOWISE_PORT=$new_port")
                    ;;
                "grafana")
                    port_config_changes+=("GRAFANA_PORT=$new_port")
                    ;;
                "prometheus")
                    port_config_changes+=("PROMETHEUS_PORT=$new_port")
                    ;;
                "qdrant")
                    port_config_changes+=("QDRANT_PORT=$new_port")
                    ;;
                "ollama")
                    port_config_changes+=("OLLAMA_PORT=$new_port")
                    ;;
                "supabase")
                    port_config_changes+=("STUDIO_PORT=$new_port")
                    ;;
            esac
        else
            echo -e "${RED}❌ Could not find a free port for $service${NC}"
        fi
    else
        echo -e "${GREEN}✓ Port $external_port is available${NC}"
    fi
done

# 5.3 Update .env with the new port assignments
if [ ${#port_config_changes[@]} -gt 0 ]; then
    echo -e "${BLUE}🔧 Updating .env with new port assignments...${NC}"
    
    for change in "${port_config_changes[@]}"; do
        var_name=$(echo "$change" | cut -d'=' -f1)
        var_value=$(echo "$change" | cut -d'=' -f2)
        
        if grep -q "^$var_name=" .env; then
            # Update existing entry
            sed -i "s/^$var_name=.*/$var_name=$var_value/" .env
        else
            # Add new entry
            echo "$var_name=$var_value" >> .env
        fi
        
        echo -e "${GREEN}✓ Updated $var_name to $var_value in .env${NC}"
    done
    
    # Important: Update the N8N_PORT in env
    if grep -q "N8N_PORT=" .env; then
        n8n_mapping="${service_ports["n8n"]}"
        n8n_port=$(echo $n8n_mapping | cut -d':' -f1)
        sed -i "s/N8N_PORT=.*/N8N_PORT=$n8n_port/" .env
        echo -e "${GREEN}✓ Updated N8N_PORT to $n8n_port in .env${NC}"
    fi
    
    # Re-source the updated .env file
    source .env
fi

# 6. Create helper scripts for later use
echo -e "${BLUE}🔧 Creating utility scripts...${NC}"

# 6.1 Update script
cat > update_stack.sh << 'EOF'
#!/bin/bash
# Quick update script for Local AI Stack

set -e # Exit on error

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔄 Updating Local AI Stack...${NC}"

# Check for Docker Compose
if [ -x "/usr/local/bin/docker-compose" ]; then
    DOCKER_COMPOSE_CMD="/usr/local/bin/docker-compose"
elif command -v docker-compose >/dev/null 2>&1; then
    DOCKER_COMPOSE_CMD="docker-compose"
elif docker compose version >/dev/null 2>&1; then
    DOCKER_COMPOSE_CMD="docker compose"
else
    echo -e "${RED}❌ Docker Compose not found. Please install Docker Compose first.${NC}"
    exit 1
fi

# Stop services
echo -e "${BLUE}🛑 Stopping services...${NC}"
$DOCKER_COMPOSE_CMD -p localai down
echo -e "${GREEN}✓ Services stopped${NC}"

# Apply configuration fixes
echo -e "${BLUE}🔧 Running configuration checks...${NC}"
./fix_config.sh
echo -e "${GREEN}✓ Configuration checked${NC}"

# Start services
echo -e "${BLUE}🚀 Starting services...${NC}"
python3 start_services.py --profile cpu
echo -e "${GREEN}✓ Services started${NC}"

echo -e "${GREEN}✅ Update completed successfully!${NC}"
EOF
chmod +x update_stack.sh

# 6.2 Backup script
cat > backup_stack.sh << 'EOF'
#!/bin/bash
# Backup script for Local AI Stack data

set -e # Exit on error

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="$BACKUP_DIR/local-ai-stack-backup-$TIMESTAMP.tar.gz"

echo -e "${BLUE}📦 Backing up Local AI Stack data...${NC}"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Check for Docker Compose
if [ -x "/usr/local/bin/docker-compose" ]; then
    DOCKER_COMPOSE_CMD="/usr/local/bin/docker-compose"
elif command -v docker-compose >/dev/null 2>&1; then
    DOCKER_COMPOSE_CMD="docker-compose"
elif docker compose version >/dev/null 2>&1; then
    DOCKER_COMPOSE_CMD="docker compose"
else
    echo -e "${RED}❌ Docker Compose not found. Please install Docker Compose first.${NC}"
    exit 1
fi

# Get volume names
echo -e "${BLUE}🔍 Identifying volumes to backup...${NC}"
VOLUMES=$($DOCKER_COMPOSE_CMD -p localai config --volumes 2>/dev/null | sort | uniq) || echo "No volumes found yet (stack may not be started)"

# Backup critical files
echo -e "${BLUE}📋 Backing up configuration files...${NC}"
mkdir -p "$BACKUP_DIR/config"
cp -f .env "$BACKUP_DIR/config/" 2>/dev/null || echo -e "${YELLOW}! .env not found${NC}"
cp -f Caddyfile "$BACKUP_DIR/config/" 2>/dev/null || echo -e "${YELLOW}! Caddyfile not found${NC}"
cp -f docker-compose.yml "$BACKUP_DIR/config/" 2>/dev/null || echo -e "${YELLOW}! docker-compose.yml not found${NC}"
cp -f prometheus.yml "$BACKUP_DIR/config/" 2>/dev/null || echo -e "${YELLOW}! prometheus.yml not found${NC}"
cp -f secrets.txt "$BACKUP_DIR/config/" 2>/dev/null || echo -e "${YELLOW}! secrets.txt not found${NC}"

# Export volumes if they exist
if [ -n "$VOLUMES" ]; then
    echo -e "${BLUE}💾 Backing up Docker volumes...${NC}"
    for volume in $VOLUMES; do
        echo -e "${BLUE}  Backing up $volume...${NC}"
        # Create a temporary container that mounts the volume and archive its contents
        docker run --rm -v $volume:/source -v $(pwd)/$BACKUP_DIR:/backup alpine sh -c "tar czf /backup/$volume.tar.gz -C /source ." || echo -e "${YELLOW}! Could not backup volume: $volume (may not exist yet)${NC}"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}  ✓ Backed up $volume${NC}"
        else
            echo -e "${RED}  ❌ Failed to back up $volume${NC}"
        fi
    done
    
    # Create final archive with volumes
    echo -e "${BLUE}📦 Creating final backup archive with volumes...${NC}"
    tar czf "$BACKUP_FILE" -C "$BACKUP_DIR" config $(for volume in $VOLUMES; do echo "$volume.tar.gz"; done 2>/dev/null)
else
    # Create final archive with just config
    echo -e "${BLUE}📦 Creating final backup archive (config only)...${NC}"
    tar czf "$BACKUP_FILE" -C "$BACKUP_DIR" config
fi

# Clean up intermediate files
echo -e "${BLUE}🧹 Cleaning up temporary files...${NC}"
rm -f "$BACKUP_DIR"/*.tar.gz
rm -rf "$BACKUP_DIR/config"

echo -e "${GREEN}✅ Backup completed successfully!${NC}"
echo -e "${GREEN}📁 Backup saved to: $BACKUP_FILE${NC}"
EOF
chmod +x backup_stack.sh

# 7. Generate environment variable documentation
echo -e "${BLUE}🔧 Generating environment variable documentation...${NC}"
cat > ENV_VARIABLES.md << EOF
# Environment Variables Documentation

This document describes all the environment variables used in the Local AI Stack.

> **Note:** This project is based on work from [coleam00/local-ai-packaged](https://github.com/coleam00/local-ai-packaged) and [Digitl-Alchemyst/Automation-Stack](https://github.com/Digitl-Alchemyst/Automation-Stack) with customizations and improvements.

## Core Configuration

### Domain and URL Settings

| Variable | Description | Default |
|----------|-------------|---------|
| \`DOMAIN_NAME\` | Main domain for all services | \`kwintes.cloud\` |
| \`SUBDOMAIN\` | Subdomain for n8n service | \`n8n\` |
| \`N8N_HOSTNAME\` | Full hostname for n8n | \`n8n.kwintes.cloud\` |
| \`WEBUI_HOSTNAME\` | Full hostname for Web UI | \`openwebui.kwintes.cloud\` |
| \`FLOWISE_HOSTNAME\` | Full hostname for Flowise | \`flowise.kwintes.cloud\` |
| \`SUPABASE_HOSTNAME\` | Full hostname for Supabase | \`supabase.kwintes.cloud\` |
| \`OLLAMA_HOSTNAME\` | Full hostname for Ollama | \`ollama.kwintes.cloud\` |
| \`SEARXNG_HOSTNAME\` | Full hostname for SearXNG | \`searxng.kwintes.cloud\` |
| \`LETSENCRYPT_EMAIL\` | Email for Let's Encrypt certificates | \`tddezeeuw@gmail.com\` |

### n8n Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| \`N8N_ENCRYPTION_KEY\` | Encryption key for n8n (required) | Generated random string |
| \`N8N_USER_MANAGEMENT_JWT_SECRET\` | JWT secret for n8n user management | Generated random string |
| \`N8N_HOST\` | Hostname for n8n | \`n8n.kwintes.cloud\` |
| \`N8N_PROTOCOL\` | Protocol for n8n (http/https) | \`https\` |
| \`N8N_PORT\` | Port for n8n | \`5678\` (using port 5678 to avoid conflict with Supabase) |
| \`N8N_EDITOR_BASE_URL\` | Base URL for n8n editor | \`https://n8n.kwintes.cloud\` |
| \`WEBHOOK_URL\` | URL for external webhooks to reach n8n | \`https://n8n.kwintes.cloud/\` |
| \`GENERIC_TIMEZONE\` | Timezone for n8n workflows | \`Europe/Amsterdam\` |
| \`NODE_FUNCTION_ALLOW_EXTERNAL\` | Domains/IPs n8n can connect to | \`*\` (all) |

### System Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| \`TZ\` | Timezone | \`Europe/Amsterdam\` |
| \`LANG\` | Language locale | \`en_US.UTF-8\` |
| \`LC_ALL\` | Locale setting | \`en_US.UTF-8\` |

## Port Configuration

To ensure consistency and avoid port conflicts, we've configured each service to use the same port number internally and externally:

| Service | Port | Notes |
|---------|------|-------|
| n8n | 5678 | Using port 5678 to avoid conflict with Supabase |
| Supabase API | 8000 | Kong API Gateway |
| Flowise | 3001 | |
| OpenWebUI | 8080 | |
| Grafana | 3000 | |
| Prometheus | 9090 | |
| Qdrant | 6333 | |
| Ollama | 11434 | |
| SearXNG | 8080 | |
| Caddy | 80/443 | Reverse proxy for all services |

EOF
echo -e "${GREEN}✓ Generated ENV_VARIABLES.md${NC}"

# Get server's public IP
SERVER_IP=$(hostname -I | awk '{print $1}')

# Get final dynamic port assignments for status display
n8n_mapping="${service_ports["n8n"]-"5678:5678"}"
n8n_port=$(echo $n8n_mapping | cut -d':' -f1)
webui_mapping="${service_ports["open-webui"]-"8080:8080"}"
webui_port=$(echo $webui_mapping | cut -d':' -f1)
flowise_mapping="${service_ports["flowise"]-"3001:3001"}"
flowise_port=$(echo $flowise_mapping | cut -d':' -f1)
grafana_mapping="${service_ports["grafana"]-"3000:3000"}"
grafana_port=$(echo $grafana_mapping | cut -d':' -f1)
prometheus_mapping="${service_ports["prometheus"]-"9090:9090"}"
prometheus_port=$(echo $prometheus_mapping | cut -d':' -f1)
qdrant_mapping="${service_ports["qdrant"]-"6333:6333"}"
qdrant_port=$(echo $qdrant_mapping | cut -d':' -f1)
ollama_mapping="${service_ports["ollama"]-"11434:11434"}"
ollama_port=$(echo $ollama_mapping | cut -d':' -f1)
supabase_mapping="${service_ports["supabase"]-"54321:54321"}"
supabase_port=$(echo $supabase_mapping | cut -d':' -f1)

# Final summary
echo -e "${GREEN}✅ Configuration preparation completed successfully!${NC}"
echo ""
echo -e "${BLUE}⚙️ Next steps:${NC}"
echo -e "1. ${YELLOW}Run the interactive setup to finish configuration:${NC}"
echo -e "   ${GREEN}python3 start_services.py --interactive${NC}"
echo -e "2. ${YELLOW}Start services with:${NC}"
echo -e "   ${GREEN}python3 start_services.py --profile cpu${NC}"
echo ""
echo -e "${BLUE}🌐 Services will be accessible at:${NC}"
echo -e "${GREEN}• n8n:${NC} https://n8n.${DOMAIN_NAME} or http://${SERVER_IP}:${n8n_port}"
echo -e "${GREEN}• OpenWebUI:${NC} https://openwebui.${DOMAIN_NAME} or http://${SERVER_IP}:${webui_port}"
echo -e "${GREEN}• Flowise:${NC} https://flowise.${DOMAIN_NAME} or http://${SERVER_IP}:${flowise_port}"
echo -e "${GREEN}• Grafana:${NC} https://grafana.${DOMAIN_NAME} or http://${SERVER_IP}:${grafana_port}"
echo -e "${GREEN}• Supabase Studio:${NC} https://studio.${DOMAIN_NAME} or http://${SERVER_IP}:${supabase_port}"
echo -e "${GREEN}• Qdrant:${NC} https://qdrant.${DOMAIN_NAME} or http://${SERVER_IP}:${qdrant_port}"
echo -e "${GREEN}• Prometheus:${NC} https://prometheus.${DOMAIN_NAME} or http://${SERVER_IP}:${prometheus_port}"
echo -e "${GREEN}• Ollama:${NC} https://ollama.${DOMAIN_NAME} or http://${SERVER_IP}:${ollama_port}"
echo ""
echo -e "${BLUE}📋 Management commands:${NC}"
echo -e "${GREEN}• Update stack:${NC} ./update_stack.sh"
echo -e "${GREEN}• Backup data:${NC} ./backup_stack.sh"
echo -e "${GREEN}• Check port usage:${NC} netstat -tuln | grep [port]"
echo ""
echo -e "${YELLOW}! If you encountered port conflicts, some services will run on different ports than default!${NC}" 