# Kwintes.cloud Dashboard and Docker Image Tools

This directory contains the necessary files for setting up the Kwintes.cloud dashboard and Docker image extraction tools.

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

## Troubleshooting

If the dashboard isn't accessible:
1. Check if Caddy is running: `docker ps | grep caddy`
2. View Caddy logs: `docker logs caddy`
3. Verify the DNS records for your root domain

If Docker image extraction fails:
1. Ensure Docker is running
2. Check for network connectivity
3. Verify Docker Hub credentials if needed

Created and maintained by Z4Y 