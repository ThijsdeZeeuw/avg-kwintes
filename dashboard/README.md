# Kwintes.cloud Dashboard and Docker Image Tools

This directory contains the necessary files for setting up the Kwintes.cloud dashboard and Docker image extraction tools.

> **Note:** This project is based on work from [coleam00/local-ai-packaged](https://github.com/coleam00/local-ai-packaged) and [Digitl-Alchemyst/Automation-Stack](https://github.com/Digitl-Alchemyst/Automation-Stack) with customizations and improvements.

## Dashboard Setup

The dashboard provides a centralized overview of all the AI services running in your Kwintes.cloud infrastructure.

### Implementation Instructions

1. **Run the automated setup script:**
   ```bash
   # Make the script executable (Linux/Mac)
   chmod +x dashboard/setup_dashboard.sh
   
   # Run the script
   sudo ./dashboard/setup_dashboard.sh
   ```

2. **Manual setup (if the script fails):**
   - Create the dashboard directory: `mkdir -p dashboard`
   - Copy the `index.html` and `status.js` files to the dashboard directory
   - Update the Caddyfile to add the root domain entry
   - Update docker-compose.yml to mount the dashboard directory
   - Restart Caddy: `docker restart caddy`

## Docker Image Extraction

The Docker image extraction tools allow you to pull and save Docker images for use in offline environments.

### Using the Python Script (Windows/Linux/Mac)

1. **Run the Python script:**
   ```bash
   # Windows
   python dashboard/extract_images.py
   
   # Linux/Mac
   python3 dashboard/extract_images.py
   ```

   This script will:
   - Extract images from docker-compose.yml
   - Pull and save specific images needed for the project
   - Save all images to a `docker-images` directory

2. **Transfer images to offline systems:**
   - Copy the `docker-images` directory to the target system
   - Load each image with: `docker load -i [image-file].tar`

### Using the Shell Script (Linux/Mac only)

1. **Run the shell script:**
   ```bash
   # Make the script executable
   chmod +x dashboard/docker_extract.sh
   
   # Run the script
   sudo ./dashboard/docker_extract.sh
   ```

## Fix for Port Conflicts

There is a known port conflict between n8n and Supabase, as both services want to use port 8000 internally. To resolve this, we've created a fix script that:

1. Changes n8n to use port 5678 instead of 8000/8008
2. Updates the Caddyfile and proxy settings
3. Creates necessary overrides in docker-compose

To apply the fix:

```bash
# Make the script executable
chmod +x dashboard/fix_caddy.sh

# Run the fix script
sudo ./dashboard/fix_caddy.sh
```

## Troubleshooting

If the dashboard isn't accessible:
1. Check if Caddy is running: `docker ps | grep caddy`
2. View Caddy logs: `docker logs caddy`
3. Verify the DNS records for your root domain

If Docker image extraction fails:
1. Ensure Docker is running
2. Check for network connectivity
3. Verify Docker Hub credentials if needed

If n8n is not accessible:
1. Make sure port 5678 is allowed in your firewall: `sudo ufw allow 5678`
2. Verify that n8n is running: `docker ps | grep n8n`
3. Check n8n logs: `docker logs n8n`
4. Run the fix script: `sudo ./dashboard/fix_caddy.sh`

---

Adapted and customized from the original projects:
- [coleam00/local-ai-packaged](https://github.com/coleam00/local-ai-packaged)
- [Digitl-Alchemyst/Automation-Stack](https://github.com/Digitl-Alchemyst/Automation-Stack)

Created and maintained by Z4Y 