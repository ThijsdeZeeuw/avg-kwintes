# Environment Variables Documentation

This document describes all the environment variables used in the Local AI Stack.

> **Note:** This project is based on work from [coleam00/local-ai-packaged](https://github.com/coleam00/local-ai-packaged) and [Digitl-Alchemyst/Automation-Stack](https://github.com/Digitl-Alchemyst/Automation-Stack) with customizations and improvements.

## Core Configuration

### Domain and URL Settings

| Variable | Description | Default |
|----------|-------------|---------|
| `DOMAIN_NAME` | Main domain for all services | `kwintes.cloud` |
| `SUBDOMAIN` | Subdomain for n8n service | `n8n` |
| `N8N_HOSTNAME` | Full hostname for n8n | `n8n.kwintes.cloud` |
| `WEBUI_HOSTNAME` | Full hostname for Web UI | `openwebui.kwintes.cloud` |
| `FLOWISE_HOSTNAME` | Full hostname for Flowise | `flowise.kwintes.cloud` |
| `SUPABASE_HOSTNAME` | Full hostname for Supabase | `supabase.kwintes.cloud` |
| `OLLAMA_HOSTNAME` | Full hostname for Ollama | `ollama.kwintes.cloud` |
| `SEARXNG_HOSTNAME` | Full hostname for SearXNG | `searxng.kwintes.cloud` |
| `LETSENCRYPT_EMAIL` | Email for Let's Encrypt certificates | `tddezeeuw@gmail.com` |

### n8n Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `N8N_ENCRYPTION_KEY` | Encryption key for n8n (required) | Generated random string |
| `N8N_USER_MANAGEMENT_JWT_SECRET` | JWT secret for n8n user management | Generated random string |
| `N8N_HOST` | Hostname for n8n | `n8n.kwintes.cloud` |
| `N8N_PROTOCOL` | Protocol for n8n (http/https) | `https` |
| `N8N_PORT` | Port for n8n | `5678` (using port 5678 to avoid conflict with Supabase) |
| `N8N_EDITOR_BASE_URL` | Base URL for n8n editor | `https://n8n.kwintes.cloud` |
| `WEBHOOK_URL` | URL for external webhooks to reach n8n | `https://n8n.kwintes.cloud/` |
| `GENERIC_TIMEZONE` | Timezone for n8n workflows | `Europe/Amsterdam` |
| `NODE_FUNCTION_ALLOW_EXTERNAL` | Domains/IPs n8n can connect to | `*` (all) |

### Supabase Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `POSTGRES_PASSWORD` | PostgreSQL password | Generated random string |
| `JWT_SECRET` | JWT secret for Supabase (at least 32 chars) | Generated random string |
| `ANON_KEY` | Anonymous key for Supabase API | Generated token |
| `SERVICE_ROLE_KEY` | Service role key for Supabase API | Generated token |
| `DASHBOARD_USERNAME` | Username for Supabase Studio | `supabase` |
| `DASHBOARD_PASSWORD` | Password for Supabase Studio | Generated random string |
| `POOLER_TENANT_ID` | Tenant ID for connection pooler | `1001` |
| `POSTGRES_HOST` | PostgreSQL host | `db` |
| `POSTGRES_DB` | PostgreSQL database name | `postgres` |
| `POSTGRES_PORT` | PostgreSQL port | `5432` |

## Service Configurations

### Flowise Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `FLOWISE_USERNAME` | Username for Flowise | `admin` |
| `FLOWISE_PASSWORD` | Password for Flowise | `password` (change this!) |
| `ENABLE_METRICS` | Enable Prometheus metrics | `true` |
| `METRICS_PROVIDER` | Metrics provider for Flowise | `prometheus` |
| `METRICS_INCLUDE_NODE_METRICS` | Include node metrics | `true` |

### Grafana Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `GRAFANA_ADMIN_USER` | Admin username for Grafana | `admin` |
| `GRAFANA_ADMIN_PASS` | Admin password for Grafana | `password` (change this!) |
| `DATA_FOLDER` | Folder for persistent data storage | `./data` |

### SearXNG Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `SEARXNG_HOSTNAME` | Hostname for SearXNG | `searxng.kwintes.cloud` |
| `SEARXNG_UWSGI_WORKERS` | Number of worker processes | `4` |
| `SEARXNG_UWSGI_THREADS` | Number of threads per worker | `4` |
| `SEARXNG_EXTERNAL_BANG` | Enable !bang support | Not set (disabled) |
| `SEARXNG_EXTERNAL_PLUGINS` | Enable external plugins | Not set (disabled) |
| `SEARXNG_DISABLE_METRICS` | Disable metrics collection | Not set (enabled) |

### System Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `TZ` | Timezone | `Europe/Amsterdam` |
| `LANG` | Language locale | `en_US.UTF-8` |
| `LC_ALL` | Locale setting | `en_US.UTF-8` |

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
| SearXNG | 8088→8080 | External port 8088 maps to internal port 8080 |
| Caddy | 80/443 | Reverse proxy for all services |

## Advanced Configuration

For additional configuration options, refer to the comments in the `.env.example` file or the documentation for the specific services.

- n8n: https://docs.n8n.io/hosting/environment-variables/
- Supabase: https://supabase.com/docs/guides/self-hosting/docker
- Flowise: https://docs.flowiseai.com/deployment
- Grafana: https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/

---

Adapted and customized from the original projects:
- [coleam00/local-ai-packaged](https://github.com/coleam00/local-ai-packaged)
- [Digitl-Alchemyst/Automation-Stack](https://github.com/Digitl-Alchemyst/Automation-Stack) 