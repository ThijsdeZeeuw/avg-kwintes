#!/usr/bin/env python3
"""
start_services.py

This script starts the Supabase stack first, waits for it to initialize, and then starts
the local AI stack. Both stacks use the same Docker Compose project name ("localai")
so they appear together in Docker Desktop.
"""

import os
import subprocess
import shutil
import time
import argparse
import platform
import sys
import secrets
import string

def generate_random_string(length=32):
    """Generate a random string of specified length."""
    alphabet = string.ascii_letters + string.digits
    return ''.join(secrets.choice(alphabet) for _ in range(length))

def save_secrets_to_file(env_vars):
    """Save all secrets and sensitive information to secrets.txt."""
    secrets_file = 'secrets.txt'
    sensitive_keys = [
        'N8N_ENCRYPTION_KEY',
        'N8N_USER_MANAGEMENT_JWT_SECRET',
        'POSTGRES_PASSWORD',
        'JWT_SECRET',
        'ANON_KEY',
        'SERVICE_ROLE_KEY',
        'DASHBOARD_PASSWORD',
        'FLOWISE_PASSWORD',
        'GRAFANA_ADMIN_PASS'
    ]
    
    with open(secrets_file, 'w') as f:
        f.write("=== Local AI Stack Secrets ===\n")
        f.write("Generated on: " + time.strftime("%Y-%m-%d %H:%M:%S") + "\n\n")
        
        for key in sensitive_keys:
            if key in env_vars:
                f.write(f"{key}={env_vars[key]}\n")
        
        f.write("\n=== Service URLs ===\n")
        domain = env_vars.get('DOMAIN_NAME', 'kwintes.cloud')
        f.write(f"n8n: https://{env_vars.get('N8N_HOSTNAME', f'n8n.{domain}')}\n")
        f.write(f"Supabase: https://{env_vars.get('SUPABASE_HOSTNAME', f'supabase.{domain}')}\n")
        f.write(f"Flowise: https://{env_vars.get('FLOWISE_HOSTNAME', f'flowise.{domain}')}\n")
        f.write(f"Grafana: https://grafana.{domain}\n")
        f.write(f"Prometheus: https://prometheus.{domain}\n")
        f.write(f"Whisper API: https://whisper.{domain}\n")
        f.write(f"Qdrant API: https://qdrant.{domain}\n")
        
        f.write("\n=== Default Credentials ===\n")
        f.write(f"Grafana: {env_vars.get('GRAFANA_ADMIN_USER', 'admin')} / {env_vars.get('GRAFANA_ADMIN_PASS', '')}\n")
        f.write(f"Flowise: {env_vars.get('FLOWISE_USERNAME', 'admin')} / {env_vars.get('FLOWISE_PASSWORD', '')}\n")
        f.write(f"Supabase Dashboard: {env_vars.get('DASHBOARD_USERNAME', 'supabase')} / {env_vars.get('DASHBOARD_PASSWORD', '')}\n")
    
    print(f"\nSecrets have been saved to {secrets_file}")
    print("IMPORTANT: Keep this file secure and do not commit it to version control!")

def create_env_from_example():
    """Create .env file from .env.example with user instructions."""
    env_example_path = '.env.example'
    env_path = '.env'
    
    if not os.path.exists(env_example_path):
        print(f"Error: {env_example_path} not found. Please create it first.")
        return False
    
    if os.path.exists(env_path):
        overwrite = input(f"\n{env_path} already exists. Overwrite? (y/n): ").lower()
        if overwrite != 'y':
            print(f"Using existing {env_path} file.")
            return True
    
    # Copy the example file
    shutil.copyfile(env_example_path, env_path)
    
    print(f"\n=== Environment Setup ===")
    print(f"A copy of {env_example_path} has been made as {env_path}")
    print("IMPORTANT: Please edit this file and update the following values:")
    print("  1. N8N_ENCRYPTION_KEY and N8N_USER_MANAGEMENT_JWT_SECRET with secure random strings")
    print("  2. All Supabase configuration values (POSTGRES_PASSWORD, JWT_SECRET, etc.)")
    print("  3. Set your domain in *_HOSTNAME variables and LETSENCRYPT_EMAIL")
    print("\nAfter updating these values, run this script again.")
    
    # Ask user if they want to edit the file now
    edit_now = input("\nWould you like to edit .env file now? (y/n): ").lower()
    if edit_now == 'y':
        # Try to open with default editor
        try:
            if platform.system() == 'Windows':
                os.system(f"notepad {env_path}")
            elif platform.system() == 'Darwin':  # macOS
                os.system(f"open {env_path}")
            else:  # Linux and others
                editor = os.environ.get('EDITOR', 'nano')
                os.system(f"{editor} {env_path}")
        except Exception as e:
            print(f"Error opening editor: {e}")
            print(f"Please edit {env_path} manually.")
    
    return True

def create_interactive_env():
    """Create .env file interactively with user input."""
    print("\n=== Interactive Environment Setup ===")
    
    # Default values
    env_vars = {
        # n8n Configuration
        'N8N_ENCRYPTION_KEY': generate_random_string(32),
        'N8N_USER_MANAGEMENT_JWT_SECRET': generate_random_string(32),
        
        # n8n domain settings
        'N8N_HOST': 'n8n.kwintes.cloud',
        'N8N_PROTOCOL': 'https',
        'N8N_PORT': '8000',
        'N8N_EDITOR_BASE_URL': 'https://n8n.kwintes.cloud',
        
        # Supabase Configuration
        'POSTGRES_PASSWORD': generate_random_string(16),
        'JWT_SECRET': generate_random_string(32),
        'ANON_KEY': generate_random_string(32),
        'SERVICE_ROLE_KEY': generate_random_string(32),
        'DASHBOARD_USERNAME': 'supabase',
        'DASHBOARD_PASSWORD': generate_random_string(16),
        'POOLER_TENANT_ID': '1001',
        'POSTGRES_HOST': 'db',
        'POSTGRES_DB': 'postgres',
        'POSTGRES_PORT': '5432',
        
        # URL Settings
        'DOMAIN_NAME': 'kwintes.cloud',
        'SUBDOMAIN': 'n8n',
        'N8N_HOSTNAME': 'n8n.kwintes.cloud',
        'WEBUI_HOSTNAME': 'openwebui.kwintes.cloud',
        'FLOWISE_HOSTNAME': 'flowise.kwintes.cloud',
        'SUPABASE_HOSTNAME': 'supabase.kwintes.cloud',
        'OLLAMA_HOSTNAME': 'ollama.kwintes.cloud',
        'SEARXNG_HOSTNAME': 'searxng.kwintes.cloud',
        'LETSENCRYPT_EMAIL': 'admin@kwintes.cloud',
        
        # Flowise Configuration
        'FLOWISE_USERNAME': 'admin',
        'FLOWISE_PASSWORD': generate_random_string(12),
        'ENABLE_METRICS': 'true',
        'METRICS_PROVIDER': 'prometheus',
        'METRICS_INCLUDE_NODE_METRICS': 'true',
        
        # Qdrant Configuration
        'QDRANT_HOST': 'qdrant',
        'QDRANT_PORT': '6333',
        
        # Monitoring Configuration
        'PROMETHEUS_PORT': '9090',
        'GRAFANA_PORT': '3000',
        'GRAFANA_ADMIN_USER': 'admin',
        'GRAFANA_ADMIN_PASS': generate_random_string(16),
        'DATA_FOLDER': './data',
        
        # System Configuration
        'TZ': 'Germany/Berlin',
        'LANG': 'en_US.UTF-8',
        'LC_ALL': 'en_US.UTF-8',
        
        # Whisper Configuration
        'WHISPER_MODEL': 'base',
        'WHISPER_DEVICE': 'cpu',
        
        # Python Configuration
        'PYTHON_PATH': '/usr/bin/python3'
    }
    
    # Interactive prompts for critical values
    print("\nPlease enter the following values (press Enter to use defaults):")
    
    critical_vars = [
        'DOMAIN_NAME',
        'SUBDOMAIN',
        'N8N_HOST',
        'N8N_HOSTNAME',
        'SUPABASE_HOSTNAME',
        'LETSENCRYPT_EMAIL',
        'FLOWISE_USERNAME',
        'FLOWISE_PASSWORD',
        'GRAFANA_ADMIN_USER',
        'GRAFANA_ADMIN_PASS',
        'TZ',
        'DASHBOARD_PASSWORD'
    ]
    
    for var in critical_vars:
        default = env_vars[var]
        value = input(f"{var} [{default}]: ").strip()
        if value:
            env_vars[var] = value
    
    # Write to .env file
    with open('.env', 'w') as f:
        f.write("# This file was generated by start_services.py\n")
        f.write("# Please review and update all values as needed\n\n")
        for key, value in env_vars.items():
            f.write(f"{key}={value}\n")
    
    # Save secrets to secrets.txt
    save_secrets_to_file(env_vars)
    
    print("\n.env file created successfully!")
    print("IMPORTANT: Check secrets.txt for all sensitive information!")
    return True

def initialize_monitoring():
    """Initialize monitoring services and create necessary configurations."""
    print("\n=== Initializing Monitoring Services ===")
    
    # Create Prometheus configuration if it doesn't exist
    if not os.path.exists('prometheus.yml'):
        with open('prometheus.yml', 'w') as f:
            f.write('''global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'n8n'
    static_configs:
      - targets: ['n8n:8000']
    metrics_path: '/metrics'
  - job_name: 'qdrant'
    static_configs:
      - targets: ['qdrant:6333']
    metrics_path: '/metrics'
  - job_name: 'whisper'
    static_configs:
      - targets: ['whisper:9000']
    metrics_path: '/metrics'
  - job_name: 'ollama'
    static_configs:
      - targets: ['ollama:11434']
    metrics_path: '/metrics'
''')
        print("Created prometheus.yml")

def run_command(cmd, cwd=None):
    """Run a shell command and print it."""
    print("Running:", " ".join(cmd))
    subprocess.run(cmd, cwd=cwd, check=True)

def clone_supabase_repo():
    """Clone the Supabase repository using sparse checkout if not already present."""
    if not os.path.exists("supabase"):
        print("Cloning the Supabase repository...")
        run_command([
            "git", "clone", "--filter=blob:none", "--no-checkout",
            "https://github.com/supabase/supabase.git"
        ])
        os.chdir("supabase")
        run_command(["git", "sparse-checkout", "init", "--cone"])
        run_command(["git", "sparse-checkout", "set", "docker"])
        run_command(["git", "checkout", "master"])
        os.chdir("..")
    else:
        print("Supabase repository already exists, updating...")
        os.chdir("supabase")
        run_command(["git", "pull"])
        os.chdir("..")

def prepare_supabase_env():
    """Copy .env to .env in supabase/docker."""
    if not os.path.exists('.env'):
        print("Error: .env file not found. Please create it first.")
        return False
        
    env_path = os.path.join("supabase", "docker", ".env")
    env_example_path = os.path.join(".env")
    print("Copying .env in root to .env in supabase/docker...")
    shutil.copyfile(env_example_path, env_path)
    return True

def check_docker_compose():
    """Check if 'docker compose' or 'docker-compose' should be used."""
    # Special handling for Ubuntu 24.04
    try:
        # Check if this is Ubuntu 24.04
        with open('/etc/os-release', 'r') as f:
            os_info = f.read()
            if 'VERSION="24.04"' in os_info and 'Ubuntu' in os_info:
                print("Detected Ubuntu 24.04 - using docker-compose...")
                # For Ubuntu 24.04, directly use docker-compose if it exists
                if os.path.exists('/usr/local/bin/docker-compose'):
                    return ['/usr/local/bin/docker-compose']
                elif subprocess.run(["which", "docker-compose"], capture_output=True, text=True).returncode == 0:
                    return ["docker-compose"]
                else:
                    # Try to install docker-compose automatically
                    try:
                        print("Attempting to install docker-compose...")
                        install_cmd = [
                            "curl", "-L", 
                            "https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-linux-x86_64", 
                            "-o", "/usr/local/bin/docker-compose"
                        ]
                        subprocess.run(install_cmd, check=True)
                        subprocess.run(["chmod", "+x", "/usr/local/bin/docker-compose"], check=True)
                        print("Successfully installed docker-compose")
                        return ["/usr/local/bin/docker-compose"]
                    except subprocess.CalledProcessError as e:
                        print(f"Error installing docker-compose: {e}")
                        print("Please install docker-compose manually")
                        sys.exit(1)
    except FileNotFoundError:
        # Not a Linux system or /etc/os-release doesn't exist
        pass
    except Exception as e:
        print(f"Warning: Error checking OS version: {e}")
    
    # Regular detection process for other systems
    try:
        # Check if 'docker compose' is available (Docker CLI plugin)
        subprocess.run(["docker", "compose", "version"], 
                       capture_output=True, check=True)
        return ["docker", "compose"]
    except subprocess.CalledProcessError:
        # Fall back to 'docker-compose' command
        try:
            subprocess.run(["docker-compose", "--version"], 
                           capture_output=True, check=True)
            return ["docker-compose"]
        except (subprocess.CalledProcessError, FileNotFoundError):
            print("Error: Neither 'docker compose' nor 'docker-compose' is available.")
            print("Please install Docker Compose: https://docs.docker.com/compose/install/")
            sys.exit(1)

def stop_existing_containers():
    """Stop and remove existing containers for our unified project ('localai')."""
    print("Stopping and removing existing containers for the unified project 'localai'...")
    docker_compose_cmd = check_docker_compose()
    cmd = docker_compose_cmd + [
        "-p", "localai",
        "-f", "docker-compose.yml",
        "-f", "supabase/docker/docker-compose.yml",
        "down"
    ]
    run_command(cmd)

def start_supabase():
    """Start the Supabase services (using its compose file)."""
    print("Starting Supabase services...")
    docker_compose_cmd = check_docker_compose()
    cmd = docker_compose_cmd + [
        "-p", "localai", 
        "-f", "supabase/docker/docker-compose.yml", 
        "up", "-d"
    ]
    run_command(cmd)

def start_local_ai(profile=None):
    """Start the local AI services (using its compose file)."""
    print("Starting local AI services...")
    docker_compose_cmd = check_docker_compose()
    cmd = docker_compose_cmd.copy()
    cmd.extend(["-p", "localai"])
    if profile and profile != "none":
        cmd.extend(["--profile", profile])
    cmd.extend(["-f", "docker-compose.yml", "up", "-d"])
    run_command(cmd)

def generate_searxng_secret_key():
    """Generate a secret key for SearXNG based on the current platform."""
    print("Checking SearXNG settings...")
    
    # Define paths for SearXNG settings files
    settings_path = os.path.join("searxng", "settings.yml")
    settings_base_path = os.path.join("searxng", "settings-base.yml")
    
    # Check if settings-base.yml exists
    if not os.path.exists(settings_base_path):
        print(f"Warning: SearXNG base settings file not found at {settings_base_path}")
        return
    
    # Check if settings.yml exists, if not create it from settings-base.yml
    if not os.path.exists(settings_path):
        print(f"SearXNG settings.yml not found. Creating from {settings_base_path}...")
        try:
            shutil.copyfile(settings_base_path, settings_path)
            print(f"Created {settings_path} from {settings_base_path}")
        except Exception as e:
            print(f"Error creating settings.yml: {e}")
            return
    else:
        print(f"SearXNG settings.yml already exists at {settings_path}")
    
    print("Generating SearXNG secret key...")
    
    # Detect the platform and run the appropriate command
    system = platform.system()
    
    try:
        if system == "Windows":
            print("Detected Windows platform, using PowerShell to generate secret key...")
            # PowerShell command to generate a random key and replace in the settings file
            ps_command = [
                "powershell", "-Command",
                "$randomBytes = New-Object byte[] 32; " +
                "(New-Object Security.Cryptography.RNGCryptoServiceProvider).GetBytes($randomBytes); " +
                "$secretKey = -join ($randomBytes | ForEach-Object { \"{0:x2}\" -f $_ }); " +
                "(Get-Content searxng/settings.yml) -replace 'ultrasecretkey', $secretKey | Set-Content searxng/settings.yml"
            ]
            subprocess.run(ps_command, check=True)
            
        elif system == "Darwin":  # macOS
            print("Detected macOS platform, using sed command with empty string parameter...")
            # macOS sed command requires an empty string for the -i parameter
            openssl_cmd = ["openssl", "rand", "-hex", "32"]
            random_key = subprocess.check_output(openssl_cmd).decode('utf-8').strip()
            sed_cmd = ["sed", "-i", "", f"s|ultrasecretkey|{random_key}|g", settings_path]
            subprocess.run(sed_cmd, check=True)
            
        else:  # Linux and other Unix-like systems
            print("Detected Linux/Unix platform, using standard sed command...")
            # Standard sed command for Linux
            openssl_cmd = ["openssl", "rand", "-hex", "32"]
            random_key = subprocess.check_output(openssl_cmd).decode('utf-8').strip()
            sed_cmd = ["sed", "-i", f"s|ultrasecretkey|{random_key}|g", settings_path]
            subprocess.run(sed_cmd, check=True)
            
        print("SearXNG secret key generated successfully.")
        
    except Exception as e:
        print(f"Error generating SearXNG secret key: {e}")
        print("You may need to manually generate the secret key using the commands:")
        print("  - Linux: sed -i \"s|ultrasecretkey|$(openssl rand -hex 32)|g\" searxng/settings.yml")
        print("  - macOS: sed -i '' \"s|ultrasecretkey|$(openssl rand -hex 32)|g\" searxng/settings.yml")
        print("  - Windows (PowerShell):")
        print("    $randomBytes = New-Object byte[] 32")
        print("    (New-Object Security.Cryptography.RNGCryptoServiceProvider).GetBytes($randomBytes)")
        print("    $secretKey = -join ($randomBytes | ForEach-Object { \"{0:x2}\" -f $_ })")
        print("    (Get-Content searxng/settings.yml) -replace 'ultrasecretkey', $secretKey | Set-Content searxng/settings.yml")

def check_and_fix_docker_compose_for_searxng():
    """Check and modify docker-compose.yml for SearXNG first run."""
    docker_compose_path = "docker-compose.yml"
    if not os.path.exists(docker_compose_path):
        print(f"Warning: Docker Compose file not found at {docker_compose_path}")
        return
    
    try:
        # Read the docker-compose.yml file
        with open(docker_compose_path, 'r') as file:
            content = file.read()
        
        # Default to first run
        is_first_run = True
        
        # Check if Docker is running and if the SearXNG container exists
        try:
            # Check if the SearXNG container is running
            container_check = subprocess.run(
                ["docker", "ps", "--filter", "name=searxng", "--format", "{{.Names}}"],
                capture_output=True, text=True, check=True
            )
            searxng_containers = container_check.stdout.strip().split('\n')
            
            # If SearXNG container is running, check inside for uwsgi.ini
            if any(container for container in searxng_containers if container):
                container_name = next(container for container in searxng_containers if container)
                print(f"Found running SearXNG container: {container_name}")
                
                # Check if uwsgi.ini exists inside the container
                container_check = subprocess.run(
                    ["docker", "exec", container_name, "sh", "-c", "[ -f /etc/searxng/uwsgi.ini ] && echo 'found' || echo 'not_found'"],
                    capture_output=True, text=True, check=True
                )
                
                if "found" in container_check.stdout:
                    print("Found uwsgi.ini inside the SearXNG container - not first run")
                    is_first_run = False
                else:
                    print("uwsgi.ini not found inside the SearXNG container - first run")
                    is_first_run = True
            else:
                print("No running SearXNG container found - assuming first run")
        except Exception as e:
            print(f"Error checking Docker container: {e} - assuming first run")
        
        if is_first_run and "cap_drop: - ALL" in content:
            print("First run detected for SearXNG. Temporarily removing 'cap_drop: - ALL' directive...")
            # Temporarily comment out the cap_drop line
            modified_content = content.replace("cap_drop: - ALL", "# cap_drop: - ALL  # Temporarily commented out for first run")
            
            # Write the modified content back
            with open(docker_compose_path, 'w') as file:
                file.write(modified_content)
                
            print("Note: After the first run completes successfully, you should re-add 'cap_drop: - ALL' to docker-compose.yml for security reasons.")
        elif not is_first_run and "# cap_drop: - ALL  # Temporarily commented out for first run" in content:
            print("SearXNG has been initialized. Re-enabling 'cap_drop: - ALL' directive for security...")
            # Uncomment the cap_drop line
            modified_content = content.replace("# cap_drop: - ALL  # Temporarily commented out for first run", "cap_drop: - ALL")
            
            # Write the modified content back
            with open(docker_compose_path, 'w') as file:
                file.write(modified_content)
    
    except Exception as e:
        print(f"Error checking/modifying docker-compose.yml for SearXNG: {e}")

def create_data_directories():
    """Create necessary data directories for mounted volumes."""
    print("Creating data directories...")
    
    # Create base data directory if it doesn't exist
    data_dir = os.environ.get('DATA_FOLDER', './data')
    if not os.path.exists(data_dir):
        os.makedirs(data_dir, exist_ok=True)
    
    # Create Grafana provisioning directories
    grafana_dir = os.path.join(data_dir, 'grafana', 'provisioning')
    for subdir in ['datasources', 'dashboards', 'notifiers', 'plugins']:
        full_path = os.path.join(grafana_dir, subdir)
        if not os.path.exists(full_path):
            os.makedirs(full_path, exist_ok=True)
    
    print(f"Created data directories in {data_dir}")

def main():
    parser = argparse.ArgumentParser(description='Start the local AI and Supabase services.')
    parser.add_argument('--profile', choices=['cpu', 'gpu-nvidia', 'gpu-amd', 'none'], default='cpu',
                      help='Profile to use for Docker Compose (default: cpu)')
    parser.add_argument('--interactive', action='store_true', default=False,
                      help='Create .env file interactively with generated values')
    parser.add_argument('--use-example', action='store_true', default=True,
                      help='Create .env file from .env.example (default)')
    args = parser.parse_args()

    # Create .env file
    env_created = False
    if args.interactive:
        env_created = create_interactive_env()
    elif args.use_example:
        env_created = create_env_from_example()
    
    # Check if we should continue
    if not env_created or not os.path.exists('.env'):
        print("Error: No .env file created. Exiting.")
        sys.exit(1)
        
    # Check if the user wants to proceed with starting services
    proceed = input("\nDo you want to start services now? (y/n): ").lower()
    if proceed != 'y':
        print("Exiting without starting services. Run this script again when ready.")
        sys.exit(0)
    
    # Initialize monitoring
    initialize_monitoring()
    
    # Create necessary data directories
    create_data_directories()
    
    # Clone Supabase repo and prepare environment
    clone_supabase_repo()
    if not prepare_supabase_env():
        print("Error preparing Supabase environment. Exiting.")
        sys.exit(1)
    
    # Generate SearXNG secret key and check docker-compose.yml
    generate_searxng_secret_key()
    check_and_fix_docker_compose_for_searxng()
    
    stop_existing_containers()
    
    # Start Supabase first
    start_supabase()
    
    # Give Supabase some time to initialize
    print("Waiting for Supabase to initialize...")
    time.sleep(10)
    
    # Then start the local AI services
    start_local_ai(args.profile)

if __name__ == "__main__":
    main()

# Created and maintained by Z4Y