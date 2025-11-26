# Bytenex Infrastructure Stack

This project contains a robust, production-ready Docker Compose setup for hosting n8n and Evolution API on a single AWS Lightsail Ubuntu instance, using an external AWS RDS PostgreSQL database.

## Services Included

1.  **Traefik v3**: Reverse Proxy and Dashboard.
2.  **Redis**: Shared cache/queue for Evolution API.
3.  **n8n**: Workflow automation.
4.  **Evolution API**: WhatsApp API.
5.  **Init DB**: A transient service that automatically checks and creates the required databases (`n8n`, `evolution`) in your RDS instance on startup.

**Note**: All services connect to a shared AWS RDS PostgreSQL instance.

## Domain Configuration

**IMPORTANT**: Since you are using Cloudflare for DNS and SSL:
1.  Ensure all A records in Cloudflare are **Proxied** (Orange Cloud icon).
2.  In Cloudflare SSL/TLS settings, set the encryption mode to **Full** (NOT Full Strict, unless you install Origin Certificates).
3.  Traefik is configured to use a self-signed certificate on the backend, which Cloudflare will trust in "Full" mode.

Ensure the following DNS records point to your Lightsail Static IP:

*   `n8n.bytenex.io` (A Record)
*   `wa.bytenex.io` (A Record)
*   `net.bytenex.io` (A Record)

## Prerequisites on Lightsail (Ubuntu)

1.  **Update System**:
    ```bash
    sudo apt update && sudo apt upgrade -y
    ```

2.  **Install Docker & Docker Compose**:
    ```bash
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    # Log out and log back in for group changes to take effect
    exit
    # SSH back in
    ```

3.  **Install Git**:
    ```bash
    sudo apt install git -y
    ```

## Deployment Steps

1.  **Clone the Repository**:
    ```bash
    git clone <YOUR_GITHUB_REPO_URL> bytenex-stack
    cd bytenex-stack
    ```

2.  **Configure Environment**:
    Create your production environment file from the example.
    ```bash
    cp .env.example .env
    nano .env
    ```
    **CRITICAL**: Fill in the following variables in `.env`:
    *   `POSTGRES_HOST`, `POSTGRES_USER`, `POSTGRES_PASSWORD` (Use your RDS credentials)
    *   `REDIS_PASSWORD`
    *   `TRAEFIK_DASHBOARD_AUTH` (See comments in file for generation)
    *   `N8N_ENCRYPTION_KEY`
    *   `EVOLUTION_API_KEY`

3.  **Run Setup Script**:
    This creates the necessary data directories.
    ```bash
    chmod +x setup.sh
    ./setup.sh
    ```

4.  **Start the Stack**:
    ```bash
    docker compose up -d
    ```
    *Note: The `init-db` service will run first to ensure all databases exist in your RDS instance.*

5.  **Verify Deployment**:
    *   Check logs: `docker compose logs -f`
    *   Access Traefik Dashboard: `https://net.bytenex.io`
    *   Access Services:
        *   n8n: `https://n8n.bytenex.io`
        *   Evolution: `https://wa.bytenex.io`

## Maintenance

*   **Update Images**:
    ```bash
    docker compose pull
    docker compose up -d
    ```
*   **Backups**:
    Back up the `n8n-data` and `evolution-data` directories regularly. Your database is on RDS, so configure automated backups in AWS Console.

## Troubleshooting
*   **Database Connections**: Ensure all services are using the correct `POSTGRES_HOST`, `POSTGRES_USER` and `POSTGRES_PASSWORD`.
*   **Logs**: Check logs for specific services if they fail to start: `docker compose logs <service_name>`
