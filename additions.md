prompts:

I am currently hosting a VPS on hostinger.com the domain is kwintes.cloud

setupkwintedcloud.txt is current actual steps, which reference ubuntu console commands (on VPS server) and what to do after downloading the package from github. I need to make a different version, one where you do not change the env file, but are required to give user input, to create a .env file while durring setting up the server. I also need in n8n whence set up to also be able to connect to external sources by their API's and stuff, so unlike currently this happening: http://localhost:5678/webhook/6b08dcf6-ec3a-4131-9575-d83de21aaa53/webhook. However using Ollama locally is a must. Alson integrate as an addition; qdrant, prometheus, grafana, and whisper, and local python. usethis guide to help you: 
 https://liberating-galley-48d.notion.site/Installing-N8N-Flowise-w-Qdrant-monitoring-with-Prometheus-Grafana-on-Hetzner-Cloud-1b3cf2b3a53980d39ae8f38a121a33fd
 https://github.com/Digitl-Alchemyst/Automation-Stack?tab=readme-ov-file
https://community.n8n.io/t/cant-set-up-whisper-or-python-locally/74378/2

Owner avatar
Automation-Stack
Public
Digitl-Alchemyst/Automation-Stack
Go to file
t
Name		
Digitl-Alchemyst
Digitl-Alchemyst
Comment
b6a7b7d
 · 
2 days ago
caddy
Added MCP for n8n
2 days ago
.env
Added MCP for n8n
2 days ago
README.md
Update README.md
3 days ago
docker-compose.yml
Comment
2 days ago
prometheus.yml
first commit
last week
Repository files navigation
README
Lightweight AI Automation Stack for Cloud Hosting
An all-in-one Docker Compose setup that provides a complete stack for AI workflow automation, integration, and monitoring.

🔗 Detailed Setup Guide: Complete Installation Guide on Notion

📺 Video Tutorial: How to Set Up on Hetzner Cloud (YouTube)

🧪 Need Help?: Visit Alchemyst Digital to get expert assistance building AI and automation solutions for your business.

What's Included
This stack combines the following tools:

n8n: Powerful workflow automation tool to connect applications and automate tasks
Flowise: Low-code UI builder for creating LLM flows
Qdrant: Vector database for AI applications
Monitoring stack:
Prometheus: Metrics collection system
Grafana: Analytics and monitoring dashboard
Postgres Exporter: Postgres metrics collector
Infrastructure:
PostgreSQL: Database storage for n8n and other services
Caddy: Reverse proxy with automatic HTTPS
Prerequisites
Docker and Docker Compose V2
A server with ports 80 and 443 accessible
A domain name pointed to your server
Getting Started
For a complete step-by-step guide with screenshots, follow our Notion Setup Guide.

You can also watch our YouTube tutorial that demonstrates the entire setup process on Hetzner Cloud.

1. Clone the repository
git clone https://github.com/yourusername/ai-automation-stack.git
cd ai-automation-stack
2. Configure environment variables
Edit the .env file to customize your setup:

# Set your domain name
DOMAIN_NAME=yourdomain.com
SUBDOMAIN=n8n

# Set secure passwords for services
POSTGRES_PASSWORD=your-secure-password
PGRST_JWT_SECRET=your-secret-key
GRAFANA_ADMIN_PASS=your-secure-password
FLOWISE_PASSWORD=your-secure-password
3. Configure Caddyfile
The default Caddyfile is set up for subdomains. Edit caddy/Caddyfile to match your domain:

Replace all instances of example.com with your domain name from the .env file.

4. Start the stack
docker compose up -d
5. Access your services
After deployment, you can access your services at:

n8n: https://n8n.yourdomain.com
Flowise: https://flowise.yourdomain.com
Grafana: https://grafana.yourdomain.com
Prometheus: https://prometheus.yourdomain.com
Qdrant: https://qdrant.yourdomain.com/dashboard
Architecture
This stack is designed to provide a complete environment for building AI-powered automation workflows:

n8n serves as the central automation platform
Flowise allows you to build LLM-powered flows
Qdrant provides vector database capabilities for AI applications
PostgreSQL stores workflow data and application state
Prometheus & Grafana monitor the health and performance of all components
Caddy handles routing and TLS certificate management
Configuration Details
n8n Configuration
n8n is configured with PostgreSQL as the database backend and has metrics and runners enabled. The container exposes port 5678 internally.

Flowise Configuration
Flowise is configured with metrics enabled and uses the internal directory for storage. It exposes port 3000 internally.

Monitoring
Prometheus is configured to scrape metrics from:

n8n
PostgreSQL (via postgres-exporter)
Qdrant
Flowise
Host machine (requires node-exporter)
Grafana connects to Prometheus as a data source and provides dashboards for monitoring.

Security
All services are only accessible through the Caddy reverse proxy
Caddy automatically obtains and renews HTTPS certificates
Each service has its own credentials defined in the .env file
Persistence
All data is stored in Docker volumes:

n8n_data: n8n workflows and credentials
postgres_data: Database storage
flowise_data: Flowise configurations
qdrant_data: Vector database storage
prometheus_data: Metrics history
grafana_data: Dashboards and configurations
caddy_data: TLS certificates
Maintenance
Updating
To update the stack to the latest versions:

docker compose pull
docker compose up -d
Backup
Backup the Docker volumes for complete data protection:

# Example backup command
docker run --rm -v ai-automation-stack_n8n_data:/source -v $(pwd)/backups:/dest alpine tar czf /dest/n8n_backup.tar.gz -C /source .
Logs
View logs for any service:

docker compose logs -f n8n
Troubleshooting
Service not starting
Check service logs:

docker compose logs service_name
Cannot access services
Verify Caddy is running: docker compose ps caddy
Check Caddy logs: docker compose logs caddy
Ensure your domain DNS is correctly configured
License
MIT License

About
This stack is maintained by Alchemyst Digital, experts in AI implementation and business automation solutions. Visit our website to learn how we can help you leverage AI for your business needs.



# Installing N8N + Flowise w/ Qdrant & monitoring with Prometheus & Grafana on Hetzner Cloud

[Private Cloud AI Automation Stack n8n Flowise Qdrant | Full Setup Guide w/ Docker on Hetzner Cloud](https://www.youtube.com/watch?v=MaWEt5zYx2c)

# 1. Create an account at Hetzner

- [ ]  Go to [hetzner.com](http://hetzner.com/)
- [ ]  Click on login/cloud
- [ ]  Click on Register Now to Create an account
- [ ]  Fill in your details
- [ ]  Add payment method (they'll charge you monthly at the end of the cycle)
- [ ]  Verify your ID, not all users have to do this, watch your email and do this when asked or your server will be disabled.

![image.png](attachment:8004293b-d848-416b-9e15-093324fe95a1:image.png)

# 2. Create a project in Cloud

![image.png](attachment:a0366d3c-80b8-401a-b0ce-af30cfbe25fa:image.png)

- [ ]  Click on New project, name the project, and click Add Project
- [ ]  Click + Create Server on your new Project Card
- [ ]  Choose a location nearest to you
- [ ]  Choose “Docker CE” in the Apps tab

![image.png](attachment:a8c53291-87ae-453d-ae82-a5c8a1dcb03e:image.png)

- [ ]  in type
    - Choose “shared vCPU/ x86(intel/AMD)
    - CPX11 the cheapest option is more than enough to run n8n and a few other services. You can always go bigger if you need.
    
    ![image.png](attachment:515e205a-e1cb-4038-864f-008b8dceef93:image.png)
    

- [ ]  Set up Networking
    - Choose Public IPv4
    - Choose Public IPv6
    
    ![image.png](attachment:65a7d455-f1a7-4628-bfe5-92cbe77e2a2d:image.png)
    

# 3. Create an SSH key

There are many methods to generate the SSH keys needed to sign into your server. For this guide we will use putty.

- [ ]  Open Putty Key Gen
- [ ]  Select RSA 4096
- [ ]  Click Generate
- [ ]  Move mouse over blank area

![image.png](attachment:d528f654-5dfc-4eef-80bd-966b77b2159d:image.png)

- [ ]  Save the private Key with the button at the bottom right
- [ ]  Copy the “Public key for pasting” from the top block

![image.png](attachment:f22756d9-e992-4e32-ad8c-ee3d96e1ffe5:image.png)

- [ ]  Past the Public Key in the SSH Key block
- [ ]  Give the key a name and set as default then Add SSH Key
    
    ![CleanShot 2025-01-04 at 11.38.08@2x.png](attachment:8107059d-0d99-4eab-b70e-d5234d527abe:CleanShot_2025-01-04_at_11.38.082x.png)
    

![image.png](attachment:658e8f11-acb8-470a-a66a-d8570eb859f4:image.png)

# 4. Optional Steps

- [ ]  Enabling backups is recommended (but you can also do it later)

![CleanShot 2025-01-04 at 11.39.52@2x.png](attachment:d8552da3-8d09-4dff-82e1-2685b7ec99b3:CleanShot_2025-01-04_at_11.39.522x.png)

# 5. Finalize your Server Purchase

- [ ]  Review the pricing for your server
- [ ]  Click Create & Buy now
- [ ]  

![image.png](attachment:9aac683a-8b8e-4eb3-86c4-662a5178f02b:image.png)

# 6. Domain and Subdomain Setup

## Prerequisites

- [ ]  A domain purchased from any domain registrar I recommend Cloudflare or Hostinger for domains
- [ ]  Your server's IP address from Hetzner (or your hosting provider)
    
    ![CleanShot 2025-01-04 at 11.47.23@2x.png](attachment:1b6b3764-bf69-4036-8b4f-e2941bd60dbd:CleanShot_2025-01-04_at_11.47.232x.png)
    
- [ ]  Access to your DNS management panel

## Step 1: Determine Your Domain Structure

- **Main Domain**: Your primary website address (https://example.com)
- **Subdomains**: Prefixes for different services:
    - n8n.example.com (for n8n workflows)
    - flowise.example.com (for Flowise AI)
    - grafana.example.com (for monitoring)
    - qdrant.example.com (for vector database)
    - prometheus.example.com (for metrics)

## Step 2: Configure DNS Records in Provider

- [ ]  Log in to your Domain Provider account
- [ ]  Navigate to Account → Dashboard
- [ ]  Find your domain (example.com) and click "Manage"
- [ ]  Select "Advanced DNS" from the navigation
- [ ]  Under "Host Records" section, add the following A Records:
    
    
    | Type | Host | Value | TTL |
    | --- | --- | --- | --- |
    | A Record | n8n | [Your Server IP] | Automatic |
    | A Record | flowise | [Your Server IP] | Automatic |
    | A Record | grafana | [Your Server IP] | Automatic |
    | A Record | qdrant | [Your Server IP] | Automatic |
    | A Record | prometheus | [Your Server IP] | Automatic |
- [ ]  Click "Save Changes"

# 7. Connect to & Configure your Server

- [ ]  Open Putty
- [ ]  Under Connections > SSH > Auth attach your Private key file we saved earlier

![image.png](attachment:e25103a3-b5dc-4b29-ac79-1e898dde4de3:image.png)

- [ ]  Back to the Session Tab
- [ ]  Enter your IP from the root@HetznerServerIP
- [ ]  Give the connection a name in Saved Sessions and click save
- [ ]  Click Open

![image.png](attachment:4cb20989-2fb6-4870-bff4-347d4ab9dca3:image.png)

## SSH Terminal Opens

```bash
# A terminal will open and login you into your server using your SSH Key
# Your terminal will look similar to this
root@docker-ce-ubuntu-2gb-ash-1:~/cloud-server#

# Run the following command to update your your server
apt update && apt -y upgrade
# app-update: Updates the list of available packages and their versions
# apt -y upgrade: Installs the newer versions of packages you have (-y) means "yes" to any prompt (automatic approval)

```

## Open Ports

- [ ]  Open the following ports in the server's firewall by running the following two commands:

```bash
sudo ufw allow 80
# then
sudo ufw allow 443
```

## Install Docker Compose

### What is Docker?

Docker containers package everything your application needs to run and can be moved easily between computers.

- [ ]  Install the plugin with the following command

```bash

apt install docker-compose-plugin
```

# 8. Configure the Docker Container

n8n requires postgres to run, this instance also comes packaged with qdrant as a light weight vector database, as well as Flowise for a full automation stack. Prometheus & Grafana are added for server monitoring & analytics

## Clone configuration repository

I recommend you to use the preconfigured docker-compose file I provide below to stream the configuration of the server. 

<aside>
💡

Very important this is ran on the remote server, not on your computer

</aside>

- [ ]  Clone the config files from github

```bash
git clone https://github.com/Digitl-Alchemyst/Automation-Stack.git

# Then change directory to the root of the repository you cloned:

cd Automation-Stack
```

## Configure environment variables

- [ ]  Open the file with the following command:

```bash
nano .env
```

The file contains inline comments to help you know what to change.

<aside>
💡

To navigate with nano use the keyboard arrows
To exit click `ctrl + X` and Yes to save, or you can click `ctrl + O` to save before exit

</aside>

- [ ]  Change all the environment variables you see listed below

```bash
N8N_HOST=n8n.example.com # URL for your n8n instance this will be the subdomain.yoururl

POSTGRES_PASSWORD=set-a-password # set a secure password
PGRST_JWT_SECRET=generate-a-key # generate a secret key

DOMAIN_NAME=example.com   # Just your main domain

FLOWISE_USERNAME=admin # any user name oyu like
FLOWISE_PASSWORD=password # set a secure password

GRAFANA_ADMIN_USER=admin # any user name you like
GRAFANA_ADMIN_PASS=password # set a secure passowrd
```

### COMMON MISTAKE TO AVOID!

When setting up your `.env` file on the server, here's the correct way:

```bash
# CORRECT WAY ✅
DOMAIN_NAME=mywebsite.com    # Just your main domain
SUBDOMAIN=n8n                # Just 'n8n'
N8N_HOST=n8n.example.com     # with the subdomain 

# WRONG WAY ❌
DOMAIN_NAME=n8n.mywebsite.com    # Don't include n8n in the domain name!
SUBDOMAIN=n8n                    # This would create n8n.n8n.mywebsite.com
N8N_HOST=example.com             # This would look for n8n at mywebsite.com
```

## Configure Caddy Webserver

- [ ]  Navigate to the caddy folder
- [ ]  Open the Caddyfile with nano

```bash
# Run the following commands to edit the Caddyfile

cd caddy

nano Caddyfile
```

- [ ]  Edit all services to use your web address

```yaml
n8n.example.com {
    reverse_proxy n8n:5678 {
        flush_interval -1
    }
}

grafana.example.com {
    reverse_proxy grafana:3000
}

flowise.example.com {
    reverse_proxy flowise:3000
}

qdrant.example.com {
    reverse_proxy qdrant:6333
}

prometheus.example.com {
    reverse_proxy prometheus:9090
}
```

- [ ]  Save the Caddyfile and exit nano

# 9. Start docker compose

- [ ]  Start the docker container with the following command:

```bash
docker compose up -d
```

## **Test your setup**

In your browser, open the URL formed of the subdomain and domain name defined earlier. Enter the user name and password defined earlier, and you should be able to access any of the services we have configured.

```bash
n8n.yourwebsite.com
flowise.yourwebsite.com
qdrant.yourwebsite.com/dashboard
prometheus.yourwebsite.com
grafana.yourwebsite.com
```

This may take a few minuets to populate the DNS records and for the services to be reachable. If you check before this you may get a 502 error 

## Updating

Follow these steps to update your services:

```bash

# Stop and remove older version
docker compose down

# Pull latest version
docker compose pull

# Start the container
docker compose up -d
```

# 10. Setting Up Node Exporter

## Download Node Exporter

Begin by downloading Node Exporter using the wget command:

```bash
wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
```

Note: Ensure you are using the latest version of Node Exporter and the correct architecture build for your server. The provided link is for amd64. For the latest releases, check here - [Prometheus Node Exporter Releases](https://github.com/prometheus/node_exporter/releases)

## Extract the Contents

After downloading, extract the contents with the following command:

```yaml
tar xvf node_exporter-1.7.0.linux-amd64.tar.gz
```

## Move the Node Exporter Binary

Change to the directory and move the node_exporter binary to /usr/local/bin:

```yaml
cd node_exporter-1.7.0.linux-amd64
```

```yaml
sudo cp node_exporter /usr/local/bin
```

Then, clean up by removing the downloaded tar file and its directory:

```yaml
rm -rf ./node_exporter-1.7.0.linux-amd64
```

## Create a Node Exporter User

Create a dedicated user for running Node Exporter:

```yaml
sudo useradd --no-create-home --shell /bin/false node_exporter
```

Assign ownership permissions of the node_exporter binary to this user:

```yaml
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
```

## Configure the Service

To ensure Node Exporter automatically starts on server reboot, configure the systemd service:

```yaml
sudo nano /etc/systemd/system/node_exporter.service
```

Then, paste the following configuration:

```yaml
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target
[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
```

Save and exit the editor.

## Enable and Start the Service

Reload the systemd daemon:

```yaml
sudo systemctl daemon-reload
```

Enable the Node Exporter service:

```yaml
sudo systemctl enable node_exporter
```

Start the service:

```yaml
sudo systemctl start node_exporter
```

To confirm the service is running properly, check its status:

```yaml
sudo systemctl status node_exporter.service
```

 ​
n8natscaleofficehoursforumbannermarch19v3

Can’t set up Whisper or Python locally
Questions
Feb 2
17d

LeRiVal

1
Feb 2
Problem:
I need to create a workflow in N8N (self-hosted in Docker) that transcribes audio files and sends the transcriptions to a vector store. I want it to be done locally, without the OpenAI nodes.
But I can’t figure out how to install Whisper or Python anywhere. Dockerfiles are too complicated, and all attempts to install it in Docker’s “exec” thing doesn’t work, either because of these two errors:

~ $  apk update && sudo apk install python3 -y
ERROR: Unable to lock database: Permission denied
ERROR: Failed to open apk database: Permission denied

~ $ exec -it n888n bash
/bin/sh: exec: illegal option -i
This would’ve been much easier if N8N already comes with Whisper pre-installed without the need for OpenAI, as in locally.

Workflow (if it helps):

💡 Double-click a node to see its settings, or paste this workflow's code into n8n to import it
Information on your n8n setup
n8n version: 1.76.1 (Self-Hosted)
Database (default: SQLite): SQLite
n8n EXECUTIONS_PROCESS setting (default: own, main): default
Running n8n via (Docker, npm, n8n cloud, desktop app): Docker
Operating system: Windows 10 (Alpine in Docker itself)

I would not reomend doing this without knowing what you are doing, To add Whisper and Python to your n8n Docker setup: Create a custom Dockerfile: FROM n8nio/n8n:latest USER root RUN apk add --no-cache python3 py3-pip RUN pip3 install openai-whisper USER node Build and run your custom image: d…


Yo_its_prakash
17d
I would not reomend doing this without knowing what you are doing,
To add Whisper and Python to your n8n Docker setup:

Create a custom Dockerfile:
FROM n8nio/n8n:latest
USER root
RUN apk add --no-cache python3 py3-pip
RUN pip3 install openai-whisper
USER node
Build and run your custom image:
docker build -t custom-n8n .
docker run -it --rm --name n8n -p 5678:5678 custom-n8n
Use the Python3 node in n8n to run Whisper:
import whisper

model = whisper.load_model("base")
result = model.transcribe("path/to/audio.mp3")
print(result["text"])
This approach keeps Whisper local and avoids OpenAI API usage.

If my solution helps solve your problem, please consider marking it as the answer! A like would make my day if you found it helpful! :blush::whale:






