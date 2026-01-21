#!/usr/bin/env bash
set -euo pipefail

# Build and run development environment using docker-compose
# This approach uses the .env file for configuration

# Default backend
CLAUDE_BACKEND="${CLAUDE_BACKEND:-bedrock}"

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

# Validate backend choice
if [[ "$CLAUDE_BACKEND" != "bedrock" && "$CLAUDE_BACKEND" != "api-key" && "$CLAUDE_BACKEND" != "subscription" ]]; then
  echo "Error: Invalid backend '$CLAUDE_BACKEND'. Must be: bedrock, api-key, or subscription"
  exit 1
fi

# Export backend choice for docker-compose
export CLAUDE_BACKEND

echo "Building devenv image..."
docker compose build

echo ""
echo "Starting interactive session..."
echo "Backend: ${CLAUDE_BACKEND}"
echo "Configuration loaded from .env file"
echo ""

# Run interactive session (--rm removes container on exit)
docker compose run --rm devenv
