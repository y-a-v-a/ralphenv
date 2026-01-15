#!/usr/bin/env bash
set -euo pipefail

log() {
  echo "[devenv] $*"
}

# Log Bedrock configuration status
if [ "${CLAUDE_CODE_USE_BEDROCK:-0}" = "1" ]; then
  log "Bedrock mode enabled"
  if [ -n "${AWS_REGION:-}" ]; then
    log "AWS_REGION: ${AWS_REGION}"
  else
    log "WARNING: AWS_REGION not set (required for Bedrock)"
  fi
  if [ -n "${AWS_BEARER_TOKEN_BEDROCK:-}" ]; then
    log "AWS_BEARER_TOKEN_BEDROCK present"
  else
    log "WARNING: AWS_BEARER_TOKEN_BEDROCK not set"
  fi
else
  log "Bedrock mode not enabled (set CLAUDE_CODE_USE_BEDROCK=1 to enable)"
fi

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
  log "Generating SSH key for GitHub access"
  mkdir -p "$SSH_DIR"
  chmod 700 "$SSH_DIR"
  ssh-keygen -t ed25519 -f "$SSH_KEY" -N "" -C "devenv@local"
  chmod 600 "$SSH_KEY"
  chmod 644 "$SSH_KEY.pub"
  log "SSH key generated at $SSH_KEY"
  log "Public key:"
  cat "$SSH_KEY.pub"
  log "Add this key to GitHub: https://github.com/settings/keys"
else
  log "SSH key already exists at $SSH_KEY"
fi

exec "$@"
