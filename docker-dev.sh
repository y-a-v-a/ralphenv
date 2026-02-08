#!/usr/bin/env bash
set -euo pipefail

# Build and run development environment using docker directly
# This approach sources the .env file for configuration

# Parse command line arguments
usage() {
  cat <<EOF
Usage: $0 [OPTIONS]

Options:
  --backend <type>    Backend type to use: bedrock, api-key, or subscription
                      (default: bedrock)
  -h, --help          Show this help message

Backend Types:
  bedrock             AWS Bedrock (requires AWS_BEARER_TOKEN_BEDROCK and AWS_REGION)
  api-key             Claude API key (requires ANTHROPIC_API_KEY)
  subscription        Subscription-based Claude Code (uses your Claude account)

Examples:
  $0 --backend bedrock
  $0 --backend api-key
  $0 --backend subscription

Environment variables can be set in .env file or exported before running this script.
EOF
  exit 0
}

# Default backend
CLAUDE_BACKEND=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --backend)
      CLAUDE_BACKEND="$2"
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "Unknown option: $1"
      usage
      ;;
  esac
done

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
CLAUDE_BACKEND="${CLAUDE_BACKEND:-${CLAUDE_BACKEND:-bedrock}}"
CLAUDE_CODE_USE_BEDROCK="${CLAUDE_CODE_USE_BEDROCK:-1}"
AWS_REGION="${AWS_REGION:-eu-central-1}"
AWS_BEARER_TOKEN_BEDROCK="${AWS_BEARER_TOKEN_BEDROCK:-}"
ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-}"
ANTHROPIC_MODEL="${ANTHROPIC_MODEL:-}"
ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION="${ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION:-}"
CLAUDE_CODE_MAX_OUTPUT_TOKENS="${CLAUDE_CODE_MAX_OUTPUT_TOKENS:-}"
MAX_THINKING_TOKENS="${MAX_THINKING_TOKENS:-}"

# Validate backend choice
if [[ "$CLAUDE_BACKEND" != "bedrock" && "$CLAUDE_BACKEND" != "api-key" && "$CLAUDE_BACKEND" != "subscription" ]]; then
  echo "Error: Invalid backend '$CLAUDE_BACKEND'. Must be: bedrock, api-key, or subscription"
  exit 1
fi

echo ""
echo "Building devenv image..."
echo "  DEV_USER: ${DEV_USER}"
docker build --progress=plain --no-cache --build-arg DEV_USER="${DEV_USER}" -t devenv:local .

echo ""
echo "Starting interactive session..."
echo "  Backend: ${CLAUDE_BACKEND}"
if [ "$CLAUDE_BACKEND" = "bedrock" ]; then
  echo "  AWS_REGION: ${AWS_REGION}"
fi
echo ""

# Run container with all environment variables
docker run --privileged \
  -e DOCKER_TLS_CERTDIR= \
  -e START_DOCKERD=1 \
  -e CLAUDE_BACKEND="${CLAUDE_BACKEND}" \
  -e CLAUDE_CODE_USE_BEDROCK="${CLAUDE_CODE_USE_BEDROCK}" \
  -e AWS_REGION="${AWS_REGION}" \
  -e AWS_BEARER_TOKEN_BEDROCK="${AWS_BEARER_TOKEN_BEDROCK}" \
  -e ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY}" \
  -e ANTHROPIC_MODEL="${ANTHROPIC_MODEL}" \
  -e ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION="${ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION}" \
  -e CLAUDE_CODE_MAX_OUTPUT_TOKENS="${CLAUDE_CODE_MAX_OUTPUT_TOKENS}" \
  -e MAX_THINKING_TOKENS="${MAX_THINKING_TOKENS}" \
  -v /var/lib/docker \
  --rm \
  -it devenv:local
