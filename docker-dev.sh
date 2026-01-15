#!/usr/bin/env bash
set -euo pipefail

# Build and run development environment using docker directly
# This approach sources the .env file for configuration

echo "Loading configuration from .env file..."

# Source .env file if it exists
if [ -f .env ]; then
  # shellcheck disable=SC1091
  source .env
else
  echo "WARNING: .env file not found. Using default values."
fi

# Set defaults if not provided
DEV_USER="${DEV_USER:-ralphw}"
CLAUDE_CODE_USE_BEDROCK="${CLAUDE_CODE_USE_BEDROCK:-1}"
AWS_REGION="${AWS_REGION:-eu-central-1}"
AWS_BEARER_TOKEN_BEDROCK="${AWS_BEARER_TOKEN_BEDROCK:-}"
ANTHROPIC_MODEL="${ANTHROPIC_MODEL:-}"
ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION="${ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION:-}"
CLAUDE_CODE_MAX_OUTPUT_TOKENS="${CLAUDE_CODE_MAX_OUTPUT_TOKENS:-}"
MAX_THINKING_TOKENS="${MAX_THINKING_TOKENS:-}"

echo ""
echo "Building devenv image..."
echo "  DEV_USER: ${DEV_USER}"
docker build --progress=plain --no-cache --build-arg DEV_USER="${DEV_USER}" -t devenv:local .

echo ""
echo "Starting interactive session..."
echo "  AWS_REGION: ${AWS_REGION}"
echo "  CLAUDE_CODE_USE_BEDROCK: ${CLAUDE_CODE_USE_BEDROCK}"
echo ""

# Run container with all environment variables
docker run --privileged \
  -e DOCKER_TLS_CERTDIR= \
  -e START_DOCKERD=1 \
  -e CLAUDE_CODE_USE_BEDROCK="${CLAUDE_CODE_USE_BEDROCK}" \
  -e AWS_REGION="${AWS_REGION}" \
  -e AWS_BEARER_TOKEN_BEDROCK="${AWS_BEARER_TOKEN_BEDROCK}" \
  -e ANTHROPIC_MODEL="${ANTHROPIC_MODEL}" \
  -e ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION="${ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION}" \
  -e CLAUDE_CODE_MAX_OUTPUT_TOKENS="${CLAUDE_CODE_MAX_OUTPUT_TOKENS}" \
  -e MAX_THINKING_TOKENS="${MAX_THINKING_TOKENS}" \
  -v /var/lib/docker \
  --rm \
  -it devenv:local
