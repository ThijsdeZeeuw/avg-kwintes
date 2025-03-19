#!/bin/bash
# Dashboard Setup Script for Kwintes.cloud
# This script sets up the dashboard with dynamic domain configuration

# Set working directory
if [ -d "/root/avg-kwintes" ]; then
  cd /root/avg-kwintes
elif [ -d "$(dirname "$0")/.." ]; then
  cd "$(dirname "$0")/.."
else
  echo "Error: Cannot find avg-kwintes directory. Run this script from the project directory."
  echo "For example: sudo ./dashboard/setup_dashboard.sh"
  exit 1
fi

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

echo "Setting up dashboard with domain: $DOMAIN_NAME"

# Create dashboard directory if it doesn't exist
mkdir -p dashboard

# Create index.html with dynamic domain
cat > dashboard/index.html << EOL
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${DOMAIN_NAME} - AI Services Dashboard</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #3b82f6;
            --primary-dark: #2563eb;
            --secondary: #6366f1;
            --dark: #1e293b;
            --light: #f8fafc;
            --success: #10b981;
            --warning: #f59e0b;
            --danger: #ef4444;
            --gray: #64748b;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Inter', sans-serif;
            background-color: var(--light);
            color: var(--dark);
            line-height: 1.6;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 2rem;
        }
        
        header {
            text-align: center;
            margin-bottom: 2.5rem;
            padding-bottom: 1.5rem;
            border-bottom: 1px solid rgba(0,0,0,0.1);
        }
        
        h1 {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 0.5rem;
            color: var(--primary);
        }
        
        .subtitle {
            font-size: 1.25rem;
            color: var(--gray);
            margin-bottom: 1rem;
        }
        
        .services-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 1.5rem;
        }
        
        .service-card {
            background-color: white;
            border-radius: 0.75rem;
            overflow: hidden;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            display: flex;
            flex-direction: column;
        }
        
        .service-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
        }
        
        .card-header {
            padding: 1.25rem;
            background-color: var(--primary);
            color: white;
        }
        
        .card-header h2 {
            font-size: 1.5rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
        }
        
        .card-header p {
            font-size: 0.875rem;
            opacity: 0.9;
        }
        
        .card-body {
            padding: 1.25rem;
            flex-grow: 1;
        }
        
        .card-body p {
            margin-bottom: 1rem;
            color: var(--gray);
        }
        
        .card-footer {
            padding: 1.25rem;
            background-color: rgba(0,0,0,0.02);
            border-top: 1px solid rgba(0,0,0,0.05);
        }
        
        .btn {
            display: inline-block;
            background-color: var(--primary);
            color: white;
            padding: 0.75rem 1.5rem;
            border-radius: 0.5rem;
            text-decoration: none;
            font-weight: 500;
            transition: background-color 0.3s ease;
            text-align: center;
            width: 100%;
        }
        
        .btn:hover {
            background-color: var(--primary-dark);
        }
        
        .status-indicator {
            display: inline-block;
            width: 12px;
            height: 12px;
            border-radius: 50%;
            margin-right: 8px;
            background-color: var(--success);
        }
        
        .status {
            display: flex;
            align-items: center;
            font-size: 0.875rem;
            margin-top: 0.5rem;
        }
        
        .service-card.automation .card-header {
            background-color: #3b82f6;
        }
        
        .service-card.ai .card-header {
            background-color: #8b5cf6;
        }
        
        .service-card.database .card-header {
            background-color: #10b981;
        }
        
        .service-card.monitoring .card-header {
            background-color: #f59e0b;
        }
        
        .service-card.search .card-header {
            background-color: #6366f1;
        }
        
        footer {
            margin-top: 3rem;
            text-align: center;
            color: var(--gray);
            font-size: 0.875rem;
            padding-top: 1.5rem;
            border-top: 1px solid rgba(0,0,0,0.1);
        }
        
        @media (max-width: 768px) {
            .services-grid {
                grid-template-columns: 1fr;
            }
            
            h1 {
                font-size: 2rem;
            }
            
            .container {
                padding: 1rem;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1 id="domain-title">${DOMAIN_NAME} AI Services</h1>
            <p class="subtitle">Your centralized AI automation platform</p>
        </header>
        
        <div class="services-grid">
            <!-- n8n -->
            <div class="service-card automation">
                <div class="card-header">
                    <h2>n8n</h2>
                    <p>Workflow Automation</p>
                </div>
                <div class="card-body">
                    <p>Create and manage automation workflows to connect applications and services.</p>
                    <div class="status">
                        <span class="status-indicator"></span>
                        <span>Checking...</span>
                    </div>
                </div>
                <div class="card-footer">
                    <a href="https://n8n.${DOMAIN_NAME}" class="btn">Access n8n</a>
                </div>
            </div>
            
            <!-- Open WebUI -->
            <div class="service-card ai">
                <div class="card-header">
                    <h2>Open WebUI</h2>
                    <p>AI Interface</p>
                </div>
                <div class="card-body">
                    <p>ChatGPT-like interface for interacting with local AI models through Ollama.</p>
                    <div class="status">
                        <span class="status-indicator"></span>
                        <span>Checking...</span>
                    </div>
                </div>
                <div class="card-footer">
                    <a href="https://openwebui.${DOMAIN_NAME}" class="btn">Access WebUI</a>
                </div>
            </div>
            
            <!-- Flowise -->
            <div class="service-card ai">
                <div class="card-header">
                    <h2>Flowise</h2>
                    <p>AI Flow Builder</p>
                </div>
                <div class="card-body">
                    <p>Build and deploy AI agents, chatbots, and complex conversational flows.</p>
                    <div class="status">
                        <span class="status-indicator"></span>
                        <span>Checking...</span>
                    </div>
                </div>
                <div class="card-footer">
                    <a href="https://flowise.${DOMAIN_NAME}" class="btn">Access Flowise</a>
                </div>
            </div>
            
            <!-- Supabase -->
            <div class="service-card database">
                <div class="card-header">
                    <h2>Supabase</h2>
                    <p>Backend Platform</p>
                </div>
                <div class="card-body">
                    <p>Postgres database, authentication, storage, and instant APIs for your applications.</p>
                    <div class="status">
                        <span class="status-indicator"></span>
                        <span>Checking...</span>
                    </div>
                </div>
                <div class="card-footer">
                    <a href="https://supabase.${DOMAIN_NAME}" class="btn">Access Supabase</a>
                </div>
            </div>
            
            <!-- Qdrant -->
            <div class="service-card database">
                <div class="card-header">
                    <h2>Qdrant</h2>
                    <p>Vector Database</p>
                </div>
                <div class="card-body">
                    <p>High-performance vector database for AI applications and similarity search.</p>
                    <div class="status">
                        <span class="status-indicator"></span>
                        <span>Checking...</span>
                    </div>
                </div>
                <div class="card-footer">
                    <a href="https://qdrant.${DOMAIN_NAME}" class="btn">Access Qdrant</a>
                </div>
            </div>
            
            <!-- Grafana -->
            <div class="service-card monitoring">
                <div class="card-header">
                    <h2>Grafana</h2>
                    <p>Monitoring Dashboard</p>
                </div>
                <div class="card-body">
                    <p>Visualize and monitor metrics from all services in real-time dashboards.</p>
                    <div class="status">
                        <span class="status-indicator"></span>
                        <span>Checking...</span>
                    </div>
                </div>
                <div class="card-footer">
                    <a href="https://grafana.${DOMAIN_NAME}" class="btn">Access Grafana</a>
                </div>
            </div>
            
            <!-- Prometheus -->
            <div class="service-card monitoring">
                <div class="card-header">
                    <h2>Prometheus</h2>
                    <p>Metrics Collection</p>
                </div>
                <div class="card-body">
                    <p>Collect and query time series data from all services for monitoring.</p>
                    <div class="status">
                        <span class="status-indicator"></span>
                        <span>Checking...</span>
                    </div>
                </div>
                <div class="card-footer">
                    <a href="https://prometheus.${DOMAIN_NAME}" class="btn">Access Prometheus</a>
                </div>
            </div>
            
            <!-- Ollama -->
            <div class="service-card ai">
                <div class="card-header">
                    <h2>Ollama</h2>
                    <p>Local LLM Engine</p>
                </div>
                <div class="card-body">
                    <p>Run large language models locally with API access for applications.</p>
                    <div class="status">
                        <span class="status-indicator"></span>
                        <span>Checking...</span>
                    </div>
                </div>
                <div class="card-footer">
                    <a href="https://ollama.${DOMAIN_NAME}" class="btn">Access Ollama API</a>
                </div>
            </div>
            
            <!-- SearXNG -->
            <div class="service-card search">
                <div class="card-header">
                    <h2>SearXNG</h2>
                    <p>Private Search Engine</p>
                </div>
                <div class="card-body">
                    <p>A privacy-respecting, self-hosted metasearch engine with numerous features.</p>
                    <div class="status">
                        <span class="status-indicator"></span>
                        <span>Checking...</span>
                    </div>
                </div>
                <div class="card-footer">
                    <a href="https://searxng.${DOMAIN_NAME}" class="btn">Access SearXNG</a>
                </div>
            </div>
        </div>
        
        <footer>
            <p>&copy; 2025 ${DOMAIN_NAME} - Local AI Stack</p>
        </footer>
    </div>
    
    <script src="status.js"></script>
</body>
</html>
EOL

# Create status.js with dynamic domain
cat > dashboard/status.js << EOL
document.addEventListener('DOMContentLoaded', function() {
    // Get domain from window.location
    const domain = window.location.hostname;
    
    // List of services to check
    const services = [
        { name: 'n8n', url: 'https://n8n.' + domain + '/healthz', selector: '.service-card.automation .status' },
        { name: 'openwebui', url: 'https://openwebui.' + domain + '/', selector: '.service-card.ai:nth-child(2) .status' },
        { name: 'flowise', url: 'https://flowise.' + domain + '/', selector: '.service-card.ai:nth-child(3) .status' },
        { name: 'supabase', url: 'https://supabase.' + domain + '/', selector: '.service-card.database:nth-child(4) .status' },
        { name: 'qdrant', url: 'https://qdrant.' + domain + '/healthz', selector: '.service-card.database:nth-child(5) .status' },
        { name: 'grafana', url: 'https://grafana.' + domain + '/', selector: '.service-card.monitoring:nth-child(6) .status' },
        { name: 'prometheus', url: 'https://prometheus.' + domain + '/-/healthy', selector: '.service-card.monitoring:nth-child(7) .status' },
        { name: 'ollama', url: 'https://ollama.' + domain + '/', selector: '.service-card.ai:nth-child(8) .status' },
        { name: 'searxng', url: 'https://searxng.' + domain + '/healthz', selector: '.service-card.search .status' }
    ];
    
    // Function to check service status
    function checkServiceStatus(service) {
        const statusElement = document.querySelector(service.selector);
        const indicator = statusElement.querySelector('.status-indicator');
        const statusText = statusElement.querySelector('span:last-child');
        
        // Make a fetch request with a timeout
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), 3000);
        
        fetch(service.url, { 
            method: 'GET',
            mode: 'no-cors', // Since we're crossing domains
            signal: controller.signal
        })
        .then(response => {
            clearTimeout(timeoutId);
            indicator.style.backgroundColor = 'var(--success)';
            statusText.textContent = 'Running';
        })
        .catch(error => {
            clearTimeout(timeoutId);
            indicator.style.backgroundColor = 'var(--danger)';
            statusText.textContent = 'Unavailable';
            console.error('Error checking ' + service.name + ':', error);
        });
    }
    
    // Check status of all services
    services.forEach(checkServiceStatus);
    
    // Refresh status every 60 seconds
    setInterval(() => {
        services.forEach(checkServiceStatus);
    }, 60000);
    
    // Log domain for debugging
    console.log('Using domain: ' + domain);
});
EOL

echo "Dashboard files created with domain: $DOMAIN_NAME"
echo "To apply changes, make sure to restart Caddy: docker restart caddy"