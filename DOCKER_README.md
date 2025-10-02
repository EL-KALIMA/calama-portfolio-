# Docker Setup for AQ Portfolio

This repository has been dockerized with a multi-stage build process and runtime environment variable injection.

## Features

- **Multi-stage Docker build**: Build with Node.js 18, serve with Nginx
- **Runtime environment injection**: Pass environment variables at container runtime
- **Hot reload development mode**: Volume-mounted development container
- **GitHub Actions CI/CD**: Automatic builds and pushes to GitHub Container Registry
- **Production-ready**: Optimized static assets with caching and gzip compression

## Quick Start

### Production Build and Run

```bash
# Build the Docker image
docker-compose build

# Run the container
docker-compose up -d

# Or run with custom environment variables
docker-compose up -d -e VITE_API_URL=https://api.example.com -e RUNTIME_FEATURE_FLAG=enabled
```

### Development Mode

```bash
# Run with hot reload
docker-compose -f docker-compose.dev.yml up
```

The development server will be available at `http://localhost:5173` with hot module replacement enabled.

## Runtime Environment Variables

The application supports runtime environment variable injection. Any environment variable with the prefix `VITE_` or `RUNTIME_` will be:
1. Injected into `/env-config.js` at container startup
2. Available in the browser via `window.__RUNTIME_CONFIG__`

### Using Runtime Config in Your Code

```javascript
// Access runtime configuration in your React components
const apiUrl = window.__RUNTIME_CONFIG__?.VITE_API_URL || 'https://default.api.com';
const featureFlag = window.__RUNTIME_CONFIG__?.RUNTIME_FEATURE_FLAG || 'disabled';

console.log('API URL:', apiUrl);
console.log('Feature Flag:', featureFlag);
```

### Setting Environment Variables

**Docker Compose:**
```yaml
environment:
  - VITE_API_URL=https://api.example.com
  - RUNTIME_FEATURE_FLAG=enabled
```

**Docker Run:**
```bash
docker run -p 80:80 \
  -e VITE_API_URL=https://api.example.com \
  -e RUNTIME_FEATURE_FLAG=enabled \
  ghcr.io/el-kalima/aq-portfolio:latest
```

**Kubernetes:**
```yaml
env:
  - name: VITE_API_URL
    value: "https://api.example.com"
  - name: RUNTIME_FEATURE_FLAG
    value: "enabled"
```

## Files Added

- **Dockerfile**: Multi-stage build configuration
- **docker-entrypoint.sh**: Runtime environment variable injection script
- **.dockerignore**: Exclude unnecessary files from Docker context
- **nginx/default.conf**: Nginx configuration for SPA routing and caching
- **docker-compose.yml**: Production deployment configuration
- **docker-compose.dev.yml**: Development environment with hot reload
- **.github/workflows/docker-image.yml**: CI/CD workflow for GitHub Actions

## CI/CD

The GitHub Actions workflow automatically builds and pushes the Docker image to GitHub Container Registry on every push to the `main` branch.

**Image Location**: `ghcr.io/el-kalima/aq-portfolio:latest`

### Pulling the Published Image

```bash
# Login to GitHub Container Registry (requires a personal access token)
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# Pull the image
docker pull ghcr.io/el-kalima/aq-portfolio:latest

# Run it
docker run -p 80:80 ghcr.io/el-kalima/aq-portfolio:latest
```

## Architecture

### Build Stage
1. Uses `node:18-alpine` as the base image
2. Installs dependencies with `npm ci`
3. Builds the Vite application with `npm run build`
4. Outputs static files to `/app/dist`

### Production Stage
1. Uses `nginx:stable-alpine` as the base image
2. Copies built files from the build stage
3. Copies custom Nginx configuration
4. Sets up the entrypoint script for runtime environment injection
5. Serves the application on port 80

### Nginx Configuration
- **SPA Routing**: All routes fall back to `index.html`
- **Static Asset Caching**: JavaScript, CSS, and images cached for 1 year
- **Gzip Compression**: Enabled for text-based assets
- **Health Check**: `/health` endpoint available

## Troubleshooting

### Container fails to start
```bash
# Check container logs
docker logs <container-id>

# Verify nginx configuration
docker exec <container-id> nginx -t
```

### Environment variables not appearing
```bash
# Check the generated env-config.js file
docker exec <container-id> cat /usr/share/nginx/html/env-config.js

# Verify entrypoint script is executable
docker exec <container-id> ls -la /docker-entrypoint.sh
```

### Build fails during npm ci
The Dockerfile includes `npm config set strict-ssl false` to handle SSL certificate issues in certain environments. For production, you may want to remove this and ensure proper SSL certificates are configured.

## Development

### Local Development without Docker
```bash
npm install
npm run dev
```

### Building Locally
```bash
npm install
npm run build
npm run preview
```

## License

Same as the main project.
