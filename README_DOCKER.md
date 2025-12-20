# Docker Compose Setup for GlucoGuard

## What is Docker Compose?

**Docker Compose** is a tool that allows you to define and run multi-container Docker applications using a simple YAML file. Instead of running multiple `docker run` commands manually, you can use `docker-compose` to start all your services with a single command.

### Benefits:
- **Easy Setup**: One command starts everything
- **Consistent Environment**: Same setup on any machine
- **Isolated Services**: Each service runs in its own container
- **Easy Scaling**: Can easily add more services (databases, Redis, etc.)

## Prerequisites

1. **Install Docker Desktop** (includes Docker Compose):
   - Windows: Download from [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)
   - Mac: Download from [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)
   - Linux: Install Docker and Docker Compose separately

2. **Verify Installation**:
   ```bash
   docker --version
   docker compose version
   # OR (older versions)
   docker-compose --version
   ```

## Quick Start

### 1. Start the Backend Service

**Newer Docker (recommended):**
```bash
docker compose up
```

**Older Docker versions:**
```bash
docker-compose up
```

*Note: Docker Desktop includes Docker Compose. Use `docker compose` (no hyphen) for newer versions.*

This will:
- Build the Docker image (first time only)
- Start the Flask backend container
- Expose it on `http://localhost:5000`

### 2. Start in Background (Detached Mode)

```bash
docker compose up -d
# OR: docker-compose up -d
```

### 3. View Logs

```bash
docker compose logs -f backend
# OR: docker-compose logs -f backend
```

### 4. Stop the Service

```bash
docker compose down
# OR: docker-compose down
```

### 5. Rebuild After Code Changes

```bash
docker compose up --build
# OR: docker-compose up --build
```

## Testing the Backend

Once running, test the backend:

```bash
# Test ping endpoint
curl http://localhost:5000/ping

# Or in PowerShell:
Invoke-WebRequest -Uri http://localhost:5000/ping
```

## Docker Compose File Structure

The `docker-compose.yml` file defines:

- **Service**: `backend` - Your Flask application
- **Ports**: Maps port 5000 from container to host
- **Environment Variables**: Model path and port configuration
- **Volumes**: Mounts model files (read-only) for easy updates
- **Networks**: Creates an isolated network for services
- **Healthcheck**: Monitors if the service is running properly

## Common Commands

```bash
# Start services (use 'docker compose' for newer Docker, 'docker-compose' for older)
docker compose up
# OR: docker-compose up

# Start in background
docker compose up -d

# Stop services
docker compose down

# View logs
docker compose logs -f

# Rebuild images
docker compose build

# Restart a service
docker compose restart backend

# Execute command in running container
docker compose exec backend python -c "print('Hello')"

# View running containers
docker compose ps

# Remove everything (containers, networks, volumes)
docker compose down -v
```

## Development Tips

1. **Code Changes**: The `backend.py` file is mounted as read-only. For code changes to take effect, restart the container:
   ```bash
   docker compose restart backend
   ```

2. **Model Updates**: Model files are mounted, so you can update them without rebuilding:
   ```bash
   docker compose restart backend
   ```

3. **View Container Logs**: 
   ```bash
   docker compose logs -f backend
   ```

4. **Access Container Shell**:
   ```bash
   docker compose exec backend /bin/bash
   ```

## Troubleshooting

### Port Already in Use
If port 5000 is already in use, change it in `docker-compose.yml`:
```yaml
ports:
  - "5001:5000"  # Use port 5001 on host instead
```

### Container Won't Start
Check logs:
```bash
docker compose logs backend
```

### Rebuild Everything
```bash
docker compose down
docker compose build --no-cache
docker compose up
```

## Next Steps

You can extend `docker-compose.yml` to add:
- **Database** (PostgreSQL, MongoDB)
- **Redis** (for caching)
- **Nginx** (reverse proxy)
- **Monitoring** (Prometheus, Grafana)

Example:
```yaml
services:
  backend:
    # ... existing config ...
  
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: glucoguard
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```
