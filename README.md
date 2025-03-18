# Local AI Stack for VPS Deployment

A comprehensive self-hosted AI stack designed for VPS deployment, featuring n8n, Ollama, Qdrant, Prometheus, Grafana, Whisper, and more.

## Features

- ✅ [**n8n**](https://n8n.io/) - Low-code automation platform with 400+ integrations
- ✅ [**Ollama**](https://ollama.com/) - Local LLM platform
- ✅ [**Qdrant**](https://qdrant.tech/) - High-performance vector store
- ✅ [**Prometheus**](https://prometheus.io/) - Monitoring and alerting toolkit
- ✅ [**Grafana**](https://grafana.com/) - Metrics visualization and analytics
- ✅ [**Whisper**](https://github.com/openai/whisper) - Speech-to-text processing
- ✅ [**Caddy**](https://caddyserver.com/) - Automatic HTTPS/TLS
- ✅ [**Supabase**](https://supabase.com/) - Database and authentication
- ✅ [**Flowise**](https://flowiseai.com/) - AI agent builder
- ✅ [**Open WebUI**](https://openwebui.com/) - ChatGPT-like interface

## Prerequisites

- Ubuntu VPS (tested on Ubuntu 22.04 LTS)
- Domain name with DNS access
- Minimum 16GB RAM recommended
- 100GB+ storage recommended
- Docker and Docker Compose installed

## Installation

1. Connect to your VPS via SSH:
```bash
ssh root@your-vps-ip
```

2. Install required packages:
```bash
sudo apt update && sudo apt install -y nano git docker.io python3 python3-pip docker-compose
```

3. Configure firewall:
```bash
sudo ufw enable
sudo ufw allow 8000  # n8n
sudo ufw allow 3001  # Flowise
sudo ufw allow 3000  # Web UI
sudo ufw allow 5678  # n8n webhook
sudo ufw allow 80    # HTTP
sudo ufw allow 443   # HTTPS
sudo ufw allow 8080  # SearXNG (if needed)
sudo ufw allow 11434 # Ollama
sudo ufw allow 6333  # Qdrant
sudo ufw allow 9090  # Prometheus
sudo ufw allow 3000  # Grafana
sudo ufw reload
```

4. Clone the repository:
```bash
git clone https://github.com/ThijsdeZeeuw/avg-kwintes.git
cd avg-kwintes
```

5. Run the interactive setup:
```bash
python3 start_services.py --interactive
```

The script will:
- Generate secure random values for all secrets
- Create a .env file with your configuration
- Save all secrets to secrets.txt
- Set up monitoring with Prometheus and Grafana
- Initialize all services

## Ollama Models

The following models are automatically installed and available in the system:

### Large Language Models (LLMs)

| Model | Source | Description |
|-------|---------|-------------|
| gemma3:12b | Google | A 12B parameter model from Google's Gemma family, optimized for general text understanding and generation |
| granite3-guardian:8b | IBM | An 8B parameter model focused on safety and ethical considerations in AI interactions |
| granite3.1-dense:latest | IBM | Latest version of IBM's dense transformer model for general language tasks |
| granite3.1-moe:3b | IBM | A 3B parameter mixture-of-experts model optimized for efficient inference |
| granite3.2:latest | IBM | Latest version of IBM's advanced language model with improved capabilities |
| llama3.2-vision | Meta | A multimodal model capable of understanding both text and images |
| minicpm-v:8b | OpenBMB | A compact 8B parameter model optimized for efficient deployment |
| mistral-nemo:12b | Mistral AI | A 12B parameter model based on Mistral's architecture with enhanced capabilities |
| qwen2.5:7b-instruct-q4_K_M | Alibaba | A quantized 7B parameter instruction-tuned model optimized for efficiency |
| reader-lm:latest | OpenBMB | A specialized model for document understanding and question answering |

### Embedding Models

| Model | Source | Description |
|-------|---------|-------------|
| granite-embedding:278m | IBM | A compact embedding model for efficient text vectorization |
| jeffh/intfloat-multilingual-e5-large-instruct:f16 | Hugging Face | A multilingual embedding model optimized for instruction following |
| nomic-embed-text:latest | Nomic AI | A general-purpose text embedding model for semantic search and similarity |

These models are automatically downloaded during the initial setup process. The system supports both CPU and GPU (NVIDIA/AMD) inference depending on your hardware configuration.

## Accessing Services

After installation, you can access the following services:

- n8n: https://n8n.kwintes.cloud
- Web UI: https://openwebui.kwintes.cloud
- Flowise: https://flowise.kwintes.cloud
- Supabase: https://supabase.kwintes.cloud
- Grafana: https://grafana.kwintes.cloud
- Prometheus: https://prometheus.kwintes.cloud
- Whisper API: https://whisper.kwintes.cloud
- Qdrant API: https://qdrant.kwintes.cloud

## Monitoring

The stack includes comprehensive monitoring:

1. Access Grafana at https://grafana.kwintes.cloud
   - Default credentials: admin / (password from secrets.txt)
   - Add Prometheus as a data source (URL: http://prometheus:9090)

2. Access Prometheus at https://prometheus.kwintes.cloud
   - View metrics and create alerts

## Security Notes

1. All secrets are saved to secrets.txt - keep this file secure
2. All services are configured to use HTTPS through Caddy
3. Firewall rules are configured to allow only necessary ports
4. Default credentials should be changed after first login

## Maintenance

To update the stack:
```bash
cd local-ai-packaged
git pull
python3 start_services.py --profile cpu
```

To restart services:
```bash
docker compose -p localai down
python3 start_services.py --profile cpu
```

## Troubleshooting

1. Check service logs:
```bash
docker compose -p localai logs -f [service_name]
```

2. Verify service status:
```bash
docker compose -p localai ps
```

3. Check monitoring:
- Visit Grafana dashboard
- Check Prometheus targets
- Review service health endpoints

## Support

For issues and feature requests, please open an issue on the GitHub repository.

---
Created and maintained by Z4Y

## Security Features

This setup prioritizes security through multiple layers:

1. **Local Deployment**
   - All AI models run locally on your VPS
   - No data is sent to external AI services
   - Complete control over data privacy and security

2. **Secure Infrastructure**
   - Automatic HTTPS/TLS encryption via Caddy
   - Firewall rules limiting access to necessary ports
   - Secure secret management with environment variables
   - Regular security updates through Docker containers

3. **Access Control**
   - Supabase authentication for user management
   - Role-based access control
   - Audit logging for all system activities
   - Secure API endpoints with authentication

4. **Data Protection**
   - Local vector database (Qdrant) for secure document storage
   - Encrypted communication between services
   - No external API dependencies for core functionality
   - Regular backup capabilities

## Local AI Capabilities

The system leverages powerful local models for various tasks:

### Text Processing
- Document summarization and analysis
- Multi-language support (via multilingual models)
- Question answering and information extraction
- Text classification and sentiment analysis

### Vision Capabilities
- Image analysis and description
- Document scanning and text extraction
- Visual understanding and reasoning
- Accessibility features for visual content

### Example Use Cases

1. **Document Analysis**
   ```python
   # Example: Analyzing client reports
   input_text = "Client report from session..."
   model = "qwen2.5:7b-instruct-q4_K_M"
   # Process and analyze the report locally
   ```

2. **Multi-language Support**
   ```python
   # Example: Processing documents in multiple languages
   text = "Document in Dutch..."
   model = "jeffh/intfloat-multilingual-e5-large-instruct:f16"
   # Process multilingual content
   ```

3. **Visual Document Processing**
   ```python
   # Example: Analyzing scanned documents
   image = "scanned_report.jpg"
   model = "llama3.2-vision"
   # Extract and analyze visual content
   ```

## GGZ/FBW Client Support

This system is particularly valuable for GGZ (Mental Healthcare) and FBW (Forensic Protected Living) organizations:

### Document Generation and Analysis

1. **Client Report Generation**
   - Automatically generate structured reports from session notes
   - Maintain consistent documentation standards
   - Support multiple languages for diverse client populations
   - Ensure privacy by processing all data locally

2. **Treatment Plan Analysis**
   - Analyze treatment plans for completeness and consistency
   - Identify potential gaps in documentation
   - Suggest improvements based on best practices
   - Track progress over time

3. **Risk Assessment Support**
   - Process and analyze risk assessment documents
   - Identify patterns and trends in risk factors
   - Generate structured risk reports
   - Support evidence-based decision making

### Client Understanding and Support

1. **Communication Analysis**
   - Process and analyze client communications
   - Identify key themes and concerns
   - Support multilingual communication
   - Track changes in client status over time

2. **Documentation Quality**
   - Ensure consistent documentation standards
   - Identify missing or incomplete information
   - Suggest improvements in documentation
   - Support quality assurance processes

3. **Knowledge Management**
   - Create searchable knowledge bases from client documents
   - Support evidence-based practice
   - Enable quick access to relevant information
   - Maintain privacy and security of sensitive data

### Benefits for GGZ/FBW Organizations

1. **Privacy and Compliance**
   - All processing happens locally
   - No external data transmission
   - Compliant with healthcare privacy regulations
   - Full control over data security

2. **Efficiency Improvements**
   - Automated document processing
   - Reduced administrative burden
   - Faster access to relevant information
   - Support for evidence-based practice

3. **Quality Enhancement**
   - Consistent documentation standards
   - Improved risk assessment
   - Better tracking of client progress
   - Enhanced decision support
