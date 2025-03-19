#!/bin/bash
# Kwintes.cloud Dashboard Setup Script
# Created and maintained by Z4Y

# Check if running as root
if [ "$EUID" -ne 0 ] && [ -z "$SUDO_USER" ]; then
  echo "Please run as root or with sudo"
  exit 1
fi

# Set working directory to avg-kwintes
if [ -d "/root/avg-kwintes" ]; then
  cd /root/avg-kwintes
elif [ -d "$(dirname "$0")/.." ]; then
  cd $(dirname "$0")/..
else
  echo "Error: Cannot find avg-kwintes directory. Run this script from the project directory."
  echo "For example: sudo ./dashboard/setup_dashboard.sh"
  exit 1
fi

echo "Working directory: $(pwd)"

# Get domain from .env file or prompt user
DOMAIN_NAME=""
if [ -f ".env" ]; then
  # Try to extract domain from .env file
  DOMAIN_FROM_ENV=$(grep "DOMAIN_NAME=" .env | cut -d '=' -f2 | tr -d '"' | tr -d "'")
  if [ -n "$DOMAIN_FROM_ENV" ]; then
    DOMAIN_NAME=$DOMAIN_FROM_ENV
    echo "Found domain in .env file: $DOMAIN_NAME"
  fi
fi

# If domain not found in .env, prompt the user
if [ -z "$DOMAIN_NAME" ]; then
  read -p "Enter your domain name (e.g., example.com): " DOMAIN_NAME
  if [ -z "$DOMAIN_NAME" ]; then
    echo "Domain name is required. Exiting."
    exit 1
  fi
fi

# Create dashboard directory if it doesn't exist
mkdir -p dashboard

# Create index.html file with dynamic domain
cat > dashboard/index.html << EOL
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${DOMAIN_NAME} Dashboard</title>
    <style>
        :root {
            --primary: #3498db;
            --success: #2ecc71;
            --danger: #e74c3c;
            --warning: #f39c12;
            --dark: #34495e;
            --light: #ecf0f1;
            --text: #2c3e50;
            --border: #bdc3c7;
            --automation: #9b59b6;
            --ai: #3498db;
            --database: #e67e22;
            --monitoring: #27ae60;
        }
        
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: var(--text);
            background-color: var(--light);
            padding: 20px;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        
        .header {
            text-align: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 1px solid var(--border);
        }
        
        .header h1 {
            font-size: 2.5rem;
            color: var(--primary);
            margin-bottom: 10px;
        }
        
        .header p {
            font-size: 1.2rem;
            color: var(--dark);
        }
        
        .service-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
        }
        
        .service-card {
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            overflow: hidden;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            border-top: 5px solid var(--primary);
        }
        
        .service-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 15px rgba(0,0,0,0.15);
        }
        
        .service-card.automation {
            border-top-color: var(--automation);
        }
        
        .service-card.ai {
            border-top-color: var(--ai);
        }
        
        .service-card.database {
            border-top-color: var(--database);
        }
        
        .service-card.monitoring {
            border-top-color: var(--monitoring);
        }
        
        .card-header {
            padding: 15px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid var(--border);
        }
        
        .card-title {
            font-size: 1.25rem;
            font-weight: bold;
        }
        
        .status-indicator {
            display: inline-block;
            width: 12px;
            height: 12px;
            border-radius: 50%;
            background-color: var(--warning);
        }
        
        .status-indicator.online {
            background-color: var(--success);
        }
        
        .status-indicator.offline {
            background-color: var(--danger);
        }
        
        .card-body {
            padding: 15px;
        }
        
        .card-description {
            margin-bottom: 15px;
            color: var(--dark);
            min-height: 70px;
        }
        
        .card-footer {
            padding: 15px;
            border-top: 1px solid var(--border);
            text-align: center;
        }
        
        .service-link {
            display: inline-block;
            padding: 8px 15px;
            background-color: var(--primary);
            color: white;
            text-decoration: none;
            border-radius: 4px;
            transition: background-color 0.3s ease;
            width: 100%;
        }
        
        .service-link:hover {
            background-color: #2980b9;
        }
        
        .service-link.automation {
            background-color: var(--automation);
        }
        
        .service-link.automation:hover {
            background-color: #8e44ad;
        }
        
        .service-link.ai {
            background-color: var(--ai);
        }
        
        .service-link.ai:hover {
            background-color: #2980b9;
        }
        
        .service-link.database {
            background-color: var(--database);
        }
        
        .service-link.database:hover {
            background-color: #d35400;
        }
        
        .service-link.monitoring {
            background-color: var(--monitoring);
        }
        
        .service-link.monitoring:hover {
            background-color: #219653;
        }
        
        .category-header {
            margin: 30px 0 15px;
            padding-bottom: 10px;
            border-bottom: 1px solid var(--border);
            color: var(--dark);
        }
        
        @media (max-width: 768px) {
            .service-grid {
                grid-template-columns: 1fr;
            }
            
            .header h1 {
                font-size: 2rem;
            }
            
            .header p {
                font-size: 1rem;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>${DOMAIN_NAME} Dashboard</h1>
            <p>Self-hosted AI and automation services</p>
        </div>
        
        <h2 class="category-header">Automation</h2>
        <div class="service-grid">
            <div class="service-card automation">
                <div class="card-header">
                    <div class="card-title">n8n</div>
                    <div class="status-indicator" id="n8n-status"></div>
                </div>
                <div class="card-body">
                    <div class="card-description">
                        Powerful workflow automation with 400+ integrations. Connect apps, automate tasks, and build workflows.
                    </div>
                </div>
                <div class="card-footer">
                    <a href="https://n8n.${DOMAIN_NAME}" class="service-link automation">Open n8n</a>
                </div>
            </div>
            
            <div class="service-card automation">
                <div class="card-header">
                    <div class="card-title">Flowise</div>
                    <div class="status-indicator" id="flowise-status"></div>
                </div>
                <div class="card-body">
                    <div class="card-description">
                        Open-source tool to build LLM flows using a drag-and-drop interface. Create AI agents and chatbots.
                    </div>
                </div>
                <div class="card-footer">
                    <a href="https://flowise.${DOMAIN_NAME}" class="service-link automation">Open Flowise</a>
                </div>
            </div>
        </div>
        
        <h2 class="category-header">AI Tools</h2>
        <div class="service-grid">
            <div class="service-card ai">
                <div class="card-header">
                    <div class="card-title">Open WebUI</div>
                    <div class="status-indicator" id="openwebui-status"></div>
                </div>
                <div class="card-body">
                    <div class="card-description">
                        ChatGPT-like interface for local LLMs. Conversation history, file uploads, and more.
                    </div>
                </div>
                <div class="card-footer">
                    <a href="https://openwebui.${DOMAIN_NAME}" class="service-link ai">Open WebUI</a>
                </div>
            </div>
            
            <div class="service-card ai">
                <div class="card-header">
                    <div class="card-title">Ollama API</div>
                    <div class="status-indicator" id="ollama-status"></div>
                </div>
                <div class="card-body">
                    <div class="card-description">
                        API for running Ollama models. Used by other services for local AI inference.
                    </div>
                </div>
                <div class="card-footer">
                    <a href="https://ollama.${DOMAIN_NAME}" class="service-link ai">Ollama API</a>
                </div>
            </div>
            
            <div class="service-card ai">
                <div class="card-header">
                    <div class="card-title">SearXNG</div>
                    <div class="status-indicator" id="searxng-status"></div>
                </div>
                <div class="card-body">
                    <div class="card-description">
                        Private, self-hosted metasearch engine. Search the web without tracking.
                    </div>
                </div>
                <div class="card-footer">
                    <a href="https://searxng.${DOMAIN_NAME}" class="service-link ai">Open SearXNG</a>
                </div>
            </div>
        </div>
        
        <h2 class="category-header">Database & Storage</h2>
        <div class="service-grid">
            <div class="service-card database">
                <div class="card-header">
                    <div class="card-title">Supabase</div>
                    <div class="status-indicator" id="supabase-status"></div>
                </div>
                <div class="card-body">
                    <div class="card-description">
                        Open-source Firebase alternative. PostgreSQL database, authentication, storage, and more.
                    </div>
                </div>
                <div class="card-footer">
                    <a href="https://supabase.${DOMAIN_NAME}" class="service-link database">Open Supabase</a>
                </div>
            </div>
            
            <div class="service-card database">
                <div class="card-header">
                    <div class="card-title">Qdrant</div>
                    <div class="status-indicator" id="qdrant-status"></div>
                </div>
                <div class="card-body">
                    <div class="card-description">
                        Vector database for AI applications. Store and search vectors for semantic search and retrieval.
                    </div>
                </div>
                <div class="card-footer">
                    <a href="https://qdrant.${DOMAIN_NAME}" class="service-link database">Open Qdrant</a>
                </div>
            </div>
        </div>
        
        <h2 class="category-header">Monitoring</h2>
        <div class="service-grid">
            <div class="service-card monitoring">
                <div class="card-header">
                    <div class="card-title">Grafana</div>
                    <div class="status-indicator" id="grafana-status"></div>
                </div>
                <div class="card-body">
                    <div class="card-description">
                        Observability platform for metrics visualization and monitoring dashboards.
                    </div>
                </div>
                <div class="card-footer">
                    <a href="https://grafana.${DOMAIN_NAME}" class="service-link monitoring">Open Grafana</a>
                </div>
            </div>
            
            <div class="service-card monitoring">
                <div class="card-header">
                    <div class="card-title">Prometheus</div>
                    <div class="status-indicator" id="prometheus-status"></div>
                </div>
                <div class="card-body">
                    <div class="card-description">
                        Monitoring system and time series database. Collects metrics from all services.
                    </div>
                </div>
                <div class="card-footer">
                    <a href="https://prometheus.${DOMAIN_NAME}" class="service-link monitoring">Open Prometheus</a>
                </div>
            </div>
        </div>
    </div>
    
    <script src="status.js"></script>
</body>
</html>
EOL

# Create status.js file with dynamic domain
cat > dashboard/status.js << EOL
document.addEventListener('DOMContentLoaded', () => {
    // Get domain from window.location or use configured domain as fallback
    const domain = window.location.hostname.includes('.')
        ? window.location.hostname.substring(window.location.hostname.indexOf('.') + 1)
        : '${DOMAIN_NAME}';
    
    const services = [
        { id: 'n8n-status', url: \`https://n8n.\${domain}/healthz\` },
        { id: 'flowise-status', url: \`https://flowise.\${domain}/api/health\` },
        { id: 'openwebui-status', url: \`https://openwebui.\${domain}/api/health\` },
        { id: 'ollama-status', url: \`https://ollama.\${domain}/api/health\` },
        { id: 'searxng-status', url: \`https://searxng.\${domain}/healthz\` },
        { id: 'supabase-status', url: \`https://supabase.\${domain}/health\` },
        { id: 'qdrant-status', url: \`https://qdrant.\${domain}/healthz\` },
        { id: 'grafana-status', url: \`https://grafana.\${domain}/api/health\` },
        { id: 'prometheus-status', url: \`https://prometheus.\${domain}/-/healthy\` }
    ];
    
    const checkServiceStatus = async (service) => {
        const indicator = document.getElementById(service.id);
        if (!indicator) return;
        
        try {
            const response = await fetch(service.url, {
                method: 'GET',
                mode: 'no-cors',
                cache: 'no-store',
                headers: {
                    'Cache-Control': 'no-cache',
                    'Pragma': 'no-cache'
                }
            });
            
            // Since we're using no-cors, we can't actually check the status
            // But if the fetch doesn't throw an error, we'll consider it online
            indicator.classList.add('online');
            indicator.classList.remove('offline');
        } catch (error) {
            // If the fetch throws an error, the service is probably offline
            indicator.classList.add('offline');
            indicator.classList.remove('online');
        }
    };
    
    // Initial check
    services.forEach(service => {
        checkServiceStatus(service);
    });
    
    // Check every 60 seconds
    setInterval(() => {
        services.forEach(service => {
            checkServiceStatus(service);
        });
    }, 60000);
    
    // Log current domain for debugging
    console.log(\`Dashboard domain: \${window.location.hostname}\`);
    console.log(\`Services domain: \${domain}\`);
});
EOL

# Check if Caddyfile exists and modify it
echo "Looking for Caddyfile..."
if [ -f "Caddyfile" ]; then
    echo "Caddyfile found. Checking for root domain entry..."
    # Use grep with extended regex for more reliable matching
    if ! grep -E "^\{\\\$DOMAIN_NAME\}" "Caddyfile" > /dev/null && ! grep -E "^{\\$DOMAIN_NAME}" "Caddyfile" > /dev/null; then
        echo "Root domain entry not found. Adding it to Caddyfile..."
        
        # Create a temporary file with the new content
        cat > Caddyfile.new << 'EOL'
{
    # Global options - works for both environments
    email {$LETSENCRYPT_EMAIL}
    admin off
    auto_https off
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

EOL
        
        # Append the original file content excluding the first block
        sed -n '/^\}/,$ p' Caddyfile | tail -n +2 >> Caddyfile.new
        
        # Replace the original file
        mv Caddyfile.new Caddyfile
        echo "Updated Caddyfile with root domain entry"
    else
        echo "Root domain entry already exists in Caddyfile"
    fi
else
    echo "Error: Caddyfile not found. Please make sure you're in the correct directory."
    exit 1
fi

# Check if docker-compose.yml exists and modify it
echo "Looking for docker-compose.yml..."
if [ -f "docker-compose.yml" ]; then
    echo "docker-compose.yml found. Checking for dashboard mount..."
    
    # Check if dashboard mount already exists
    if ! grep -q "./dashboard:/etc/caddy/dashboard" "docker-compose.yml"; then
        echo "Dashboard mount not found. Adding it to docker-compose.yml..."
        
        # Use sed to add the dashboard mount
        # Look for the Caddyfile mount line and add the dashboard mount after it
        sed -i '/- \.\/Caddyfile:\/etc\/caddy\/Caddyfile/a \ \ \ \ \ \ - ./dashboard:/etc/caddy/dashboard:ro' docker-compose.yml
        echo "Added dashboard mount to docker-compose.yml"
    else
        echo "Dashboard mount already exists in docker-compose.yml"
    fi
    
    # Check if DOMAIN_NAME environment variable exists
    if ! grep -q "DOMAIN_NAME=\${DOMAIN_NAME" docker-compose.yml; then
        echo "DOMAIN_NAME environment variable not found. Adding it to docker-compose.yml..."
        
        # Use sed to add the environment variable
        # Add it to the caddy environment section
        sed -i '/environment:/a \ \ \ \ \ \ - DOMAIN_NAME=${DOMAIN_NAME:-'"$DOMAIN_NAME"'}' docker-compose.yml
        echo "Added DOMAIN_NAME environment variable to docker-compose.yml"
    else
        echo "DOMAIN_NAME environment variable already exists in docker-compose.yml"
    fi
else
    echo "Error: docker-compose.yml not found. Please make sure you're in the correct directory."
    exit 1
fi

# Check if caddy container is running and restart it
echo "Checking if Caddy container is running..."
if docker ps | grep -q "caddy"; then
    echo "Caddy container is running. Restarting it to apply changes..."
    docker restart caddy
    echo "Caddy container restarted."
else
    echo "Caddy container is not running. Changes will be applied when you start the services."
fi

# Set proper permissions for the dashboard directory if run with sudo
if [ -n "$SUDO_USER" ]; then
    echo "Setting proper ownership of dashboard directory..."
    chown -R $SUDO_USER:$SUDO_USER dashboard
fi

# Create README.md for dashboard if it doesn't exist
if [ ! -f "dashboard/README.md" ]; then
    cat > dashboard/README.md << EOL
# ${DOMAIN_NAME} Dashboard

This directory contains the necessary files for setting up the dashboard at ${DOMAIN_NAME}.

## Dashboard Setup

The dashboard provides a centralized overview of all the AI services running in your infrastructure.

### Implementation Instructions

1. **Run the automated setup script:**
   \`\`\`bash
   # Make the script executable (Linux/Mac)
   chmod +x dashboard/setup_dashboard.sh
   
   # Run the script
   sudo ./dashboard/setup_dashboard.sh
   \`\`\`

2. **Manual setup (if the script fails):**
   - Create the dashboard directory: \`mkdir -p dashboard\`
   - Copy the \`index.html\` and \`status.js\` files to the dashboard directory
   - Update the Caddyfile to add the root domain entry
   - Update docker-compose.yml to mount the dashboard directory
   - Restart Caddy: \`docker restart caddy\`

## Troubleshooting

If the dashboard isn't accessible:
1. Check if Caddy is running: \`docker ps | grep caddy\`
2. View Caddy logs: \`docker logs caddy\`
3. Verify the DNS records for your root domain

Created and maintained by Z4Y
EOL
fi

echo "Dashboard setup complete!"
echo "Your dashboard is now available at your root domain (https://${DOMAIN_NAME})."
echo ""
echo "Dashboard setup script completed successfully."