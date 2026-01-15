# devenv

Portable developer environment for Claude Code with Amazon Bedrock.

## Build

```bash
docker build --progress=plain --no-cache -t devenv:local .
```

## Run (Docker-in-Docker)

```bash
docker run --privileged \
  -e DOCKER_TLS_CERTDIR= \
  -e START_DOCKERD=1 \
  -e CLAUDE_CODE_USE_BEDROCK=1 \
  -e AWS_REGION=eu-central-1 \
  -e AWS_BEARER_TOKEN_BEDROCK=your_token_here \
  -v /var/lib/docker \
  -it devenv:local
```

Notes:
- Docker-in-Docker requires `--privileged`. You can mount `/var/lib/docker` for persistence.
- `DOCKER_TLS_CERTDIR=` disables TLS cert generation inside the container.
- Development happens fully isolated inside the container; use git to push/pull code.
- See "Configuration" section below for Bedrock environment variables.

## Compose

### Interactive Session (Recommended)

Run a one-off interactive session:

```bash
docker compose run --rm devenv
```

This starts the container, gives you a bash prompt, and removes the container when you exit.

### Background Mode

Alternatively, start in background and exec into it:

```bash
# Start container in background
docker compose up -d

# Connect to running container
docker compose exec devenv bash

# Stop when done
docker compose down
```

Configuration is read from environment variables. Create a `.env` file in the project root (see Configuration section below).

### Verify Configuration

Before starting containers, verify that environment variables are correctly loaded:

```bash
# View resolved configuration (sensitive values are masked)
docker compose config

# View specific service environment variables
docker compose config | grep -A 20 "environment:"

# Raw file contents (doesn't show docker-compose resolution)
cat .env
```

## Configuration

Claude Code with Bedrock uses environment variables for authentication. Create a `.env` file:

```bash
# Enable Bedrock integration
CLAUDE_CODE_USE_BEDROCK=1
AWS_REGION=eu-central-1  # or your preferred region

# Bedrock authentication (bearer token approach)
AWS_BEARER_TOKEN_BEDROCK=your_bedrock_bearer_token_here

# Optional: Override model settings
# Note: Use inference profile IDs, not direct model IDs
ANTHROPIC_MODEL=eu.anthropic.claude-opus-4-5-20251101-v1:0
ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION=eu-central-1
CLAUDE_CODE_MAX_OUTPUT_TOKENS=4096
MAX_THINKING_TOKENS=1024
```

**Alternative authentication methods:**
- AWS Access Keys: Set `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and optionally `AWS_SESSION_TOKEN`
- AWS SSO: Claude Code supports automatic credential refresh for SSO

**Portability notes:**
- Environment variables work seamlessly on local macOS (via docker-compose or docker run) and in AWS environments (ECS, EC2, etc.)
- The `.env` file is for local development only and is not committed to git
- In AWS, set these as environment variables in your service configuration

## GitHub Authentication

### Option 1: SSH Keys (Automatic)

SSH keys are automatically generated on first run if they don't exist.

1. Start the container:
   ```bash
   docker compose run --rm devenv
   ```

2. Copy the public key displayed in the logs

3. Add it to GitHub: https://github.com/settings/keys

4. Test the connection:
   ```bash
   ssh -T git@github.com
   ```

**Persistence**: To persist SSH keys across container restarts, mount `~/.ssh`:
```yaml
volumes:
  - ~/.ssh:/home/vincentb/.ssh:ro  # Read-only for security
```

### Option 2: GitHub CLI

Alternatively, use the GitHub CLI (already installed):

```bash
# Authenticate interactively
gh auth login

# Follow the prompts to authenticate via browser or token

# Verify authentication
gh auth status
```

The gh CLI stores credentials and handles authentication automatically for git operations.

## Versions

Installed versions are recorded at `/opt/devenv/versions.txt` during build.
