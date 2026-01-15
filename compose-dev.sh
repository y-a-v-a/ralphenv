#!/usr/bin/env bash
set -euo pipefail

# Build and run development environment using docker-compose
# This approach uses the .env file for configuration

echo "Building devenv image..."
docker compose build

echo ""
echo "Starting interactive session..."
echo "Configuration loaded from .env file"
echo ""

# Run interactive session (--rm removes container on exit)
docker compose run --rm devenv
