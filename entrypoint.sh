#!/usr/bin/env bash
set -euo pipefail

log() {
  echo "[devenv] $*"
}

# Determine backend and validate credentials
CLAUDE_BACKEND="${CLAUDE_BACKEND:-bedrock}"
log "Claude Backend: ${CLAUDE_BACKEND}"

case "${CLAUDE_BACKEND}" in
  bedrock)
    log "Using AWS Bedrock backend"
    if [ -n "${AWS_REGION:-}" ]; then
      log "AWS_REGION: ${AWS_REGION}"
    else
      log "WARNING: AWS_REGION not set (required for Bedrock)"
    fi
    if [ -n "${AWS_BEARER_TOKEN_BEDROCK:-}" ]; then
      log "AWS_BEARER_TOKEN_BEDROCK present"
    else
      log "WARNING: AWS_BEARER_TOKEN_BEDROCK not set (required for Bedrock)"
    fi
    # Ensure Bedrock mode is enabled
    export CLAUDE_CODE_USE_BEDROCK=1
    ;;
  api-key)
    log "Using Claude API key backend"
    if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
      log "ANTHROPIC_API_KEY present"
    else
      log "WARNING: ANTHROPIC_API_KEY not set (required for API key mode)"
    fi
    # Disable Bedrock mode
    export CLAUDE_CODE_USE_BEDROCK=0
    ;;
  subscription)
    log "Using subscription-based Claude Code"
    log "You will need to authenticate with your Claude account"
    # Disable Bedrock mode
    export CLAUDE_CODE_USE_BEDROCK=0
    ;;
  *)
    log "ERROR: Unknown backend '${CLAUDE_BACKEND}'. Must be: bedrock, api-key, or subscription"
    exit 1
    ;;
esac

if [ "${START_DOCKERD:-0}" = "1" ]; then
  log "starting dockerd"
  DOCKERD_LOG="/tmp/dockerd.log"
  dockerd >"$DOCKERD_LOG" 2>&1 &
  sleep 1
fi

# SSH key auto-generation
SSH_DIR="$HOME/.ssh"
SSH_KEY="$SSH_DIR/id_ed25519"

if [ ! -f "$SSH_KEY" ]; then
  # Create unique key comment: username@hostname
  SSH_COMMENT="$(whoami)@${HOSTNAME}"

  log "Generating SSH key for GitHub access"
  mkdir -p "$SSH_DIR"
  chmod 700 "$SSH_DIR"
  ssh-keygen -t ed25519 -f "$SSH_KEY" -N "" -C "${SSH_COMMENT}"
  chmod 600 "$SSH_KEY"
  chmod 644 "$SSH_KEY.pub"
  log "SSH key generated at $SSH_KEY"
  log "Key identifier: ${SSH_COMMENT}"
  log "Public key:"
  cat "$SSH_KEY.pub"
  log "Add this key to GitHub: https://github.com/settings/keys"
else
  log "SSH key already exists at $SSH_KEY"
fi

exec "$@"
