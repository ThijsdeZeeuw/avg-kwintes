#!/bin/bash
# Docker Image Extraction Script for Kwintes.cloud
# Created and maintained by Z4Y

# Check if running as root
if [ "$EUID" -ne 0 ] && [ -z "$SUDO_USER" ]; then
  echo "Please run as root or with sudo"
  exit 1
fi

# Set working directory
if [ -d "/root/avg-kwintes" ]; then
  cd /root/avg-kwintes
elif [ -d "$(dirname "$0")/.." ]; then
  cd $(dirname "$0")/..
else
  echo "Error: Cannot find avg-kwintes directory. Run this script from the project directory."
  echo "For example: sudo ./dashboard/docker_extract.sh"
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

echo "Working directory: $(pwd)"
echo "Starting Docker image extraction for ${DOMAIN_NAME}..."

# Check if docker is installed
if ! command -v docker &> /dev/null; then
  echo "Docker is not installed. Please install Docker first."
  exit 1
fi

# Check if docker compose is installed
if ! docker compose version &> /dev/null; then
  echo "Docker Compose is not installed. Please install Docker Compose first."
  exit 1
fi

# Create directory for extracted images
EXTRACT_DIR="docker_images"
mkdir -p $EXTRACT_DIR
echo "Created directory: $EXTRACT_DIR"

# Get list of all Docker images used in docker-compose.yml
echo "Extracting Docker images from docker-compose.yml..."
IMAGES=$(grep -E '^\s+image:' docker-compose.yml | awk '{print $2}' | tr -d '"' | tr -d "'")

if [ -z "$IMAGES" ]; then
  echo "No Docker images found in docker-compose.yml"
  exit 1
fi

# Pull and save each image
for IMAGE in $IMAGES; do
  echo "Processing image: $IMAGE"
  
  # Extract image name without tag
  IMAGE_NAME=$(echo $IMAGE | cut -d':' -f1 | tr '/' '_')
  IMAGE_TAG=$(echo $IMAGE | cut -d':' -f2)
  FILENAME="${EXTRACT_DIR}/${IMAGE_NAME}_${IMAGE_TAG}.tar"
  
  echo "Pulling image: $IMAGE"
  docker pull $IMAGE
  
  echo "Saving image to: $FILENAME"
  docker save $IMAGE -o $FILENAME
  
  # Create checksum file
  echo "Creating checksum for: $FILENAME"
  sha256sum $FILENAME > "${FILENAME}.sha256"
  
  echo "Done processing: $IMAGE"
  echo "---"
done

# Create readme file
cat > ${EXTRACT_DIR}/README.md << EOL
# Docker Images for ${DOMAIN_NAME}

This directory contains Docker images extracted for offline installation of ${DOMAIN_NAME} services.

## Images Included

$(for IMAGE in $IMAGES; do echo "- \`$IMAGE\`"; done)

## Installation Instructions

1. Copy all .tar files to your target server
2. Verify the integrity of each file using:
   \`\`\`
   sha256sum -c filename.tar.sha256
   \`\`\`
3. Load each image using:
   \`\`\`
   docker load -i filename.tar
   \`\`\`
4. Continue with the normal ${DOMAIN_NAME} setup process

## Extraction Date

$(date)

Created and maintained by Z4Y
EOL

# Create load script for convenience
cat > ${EXTRACT_DIR}/load_images.sh << 'EOL'
#!/bin/bash
# Docker Image Loading Script

echo "Starting Docker image loading process..."

# Check if docker is installed
if ! command -v docker &> /dev/null; then
  echo "Docker is not installed. Please install Docker first."
  exit 1
fi

# Load each image
for TAR_FILE in *.tar; do
  if [ -f "$TAR_FILE" ]; then
    echo "Loading image from: $TAR_FILE"
    docker load -i "$TAR_FILE"
    echo "Done loading: $TAR_FILE"
    echo "---"
  fi
done

echo "All Docker images have been loaded successfully!"
EOL

# Make the load script executable
chmod +x ${EXTRACT_DIR}/load_images.sh

# Create archive of all images
echo "Creating archive of all Docker images..."
TAR_FILENAME="docker_images_${DOMAIN_NAME}_$(date +%Y%m%d).tar.gz"
tar -czf $TAR_FILENAME $EXTRACT_DIR
echo "Archive created: $TAR_FILENAME"

# Set appropriate permissions if running with sudo
if [ -n "$SUDO_USER" ]; then
  echo "Setting proper ownership of extracted files..."
  chown -R $SUDO_USER:$SUDO_USER $EXTRACT_DIR
  chown $SUDO_USER:$SUDO_USER $TAR_FILENAME
fi

echo "Docker image extraction completed successfully!"
echo "Total images extracted: $(echo "$IMAGES" | wc -l)"
echo "Images saved to: $EXTRACT_DIR"
echo "Archive created: $TAR_FILENAME" 