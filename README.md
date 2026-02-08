# devenv

Portable developer environment for Claude Code with flexible backend support.

## Quick Start

Use the provided convenience scripts with your preferred backend:

```bash
# Docker Compose approach (recommended)
# Default: AWS Bedrock
./compose-dev.sh

# With specific backend
./compose-dev.sh --backend bedrock      # AWS Bedrock
./compose-dev.sh --backend api-key      # Claude API key
./compose-dev.sh --backend subscription # Subscription-based Claude Code

# Docker direct approach
./docker-dev.sh --backend bedrock
./docker-dev.sh --backend api-key
./docker-dev.sh --backend subscription
```

Once inside the container, try the Ralph Wiggum method:

```bash
# Copy the template and edit it
cp ~/PROMPT.md.template ~/PROMPT.md
vim ~/PROMPT.md

# Run Ralph
ralph
```

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

Claude Code supports multiple backends. Choose the one that fits your needs and create a `.env` file:

### Backend Selection

You can select the backend in three ways:
1. Command line argument: `./compose-dev.sh --backend api-key`
2. Environment variable in `.env`: `export CLAUDE_BACKEND=api-key`
3. Default: If not specified, defaults to `bedrock`

**Quick Start:** Copy the appropriate example file and customize it:
```bash
# For AWS Bedrock
cp .env.example.bedrock .env

# For Claude API Key
cp .env.example.api-key .env

# For Subscription
cp .env.example.subscription .env

# Then edit .env with your credentials
vim .env
```

### Option 1: AWS Bedrock (Default)

Best for: AWS-integrated workflows, cost-effectiveness, and enterprise deployments.

```bash
# Container user (defaults to ralphw if not set)
# Reference: https://ghuntley.com/ralph/
export DEV_USER=vincentb

# Backend selection (optional, defaults to bedrock)
export CLAUDE_BACKEND=bedrock

# Bedrock configuration
export AWS_REGION=eu-central-1  # or your preferred region

# Bedrock authentication (bearer token approach)
export AWS_BEARER_TOKEN_BEDROCK=your_bedrock_bearer_token_here

# Optional: Override model settings
# Note: Use inference profile IDs, not direct model IDs
export ANTHROPIC_MODEL=eu.anthropic.claude-opus-4-5-20251101-v1:0
export ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION=eu-central-1
export CLAUDE_CODE_MAX_OUTPUT_TOKENS=4096
export MAX_THINKING_TOKENS=1024
```

**Alternative AWS authentication methods:**
- AWS Access Keys: Set `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and optionally `AWS_SESSION_TOKEN`
- AWS SSO: Claude Code supports automatic credential refresh for SSO

### Option 2: Claude API Key

Best for: Direct API access, simplicity, and non-AWS environments.

```bash
# Container user
export DEV_USER=vincentb

# Backend selection
export CLAUDE_BACKEND=api-key

# Claude API key authentication
export ANTHROPIC_API_KEY=sk-ant-your-api-key-here

# Optional: Override model settings
export ANTHROPIC_MODEL=claude-opus-4-5-20251101
export CLAUDE_CODE_MAX_OUTPUT_TOKENS=4096
export MAX_THINKING_TOKENS=1024
```

Get your API key from: https://console.anthropic.com/settings/keys

### Option 3: Subscription-Based

Best for: Developers with Claude subscription who want to use their existing account.

```bash
# Container user
export DEV_USER=vincentb

# Backend selection
export CLAUDE_BACKEND=subscription

# Optional: Override model settings
export CLAUDE_CODE_MAX_OUTPUT_TOKENS=4096
export MAX_THINKING_TOKENS=1024
```

You'll need to authenticate with your Claude account when starting the container.

### Switching Between Backends

You can easily switch between backends without modifying your `.env` file:

```bash
# Override backend via command line
./compose-dev.sh --backend api-key        # Use API key instead of .env setting
./compose-dev.sh --backend subscription   # Use subscription instead of .env setting

# Or export before running
export CLAUDE_BACKEND=api-key
./compose-dev.sh
```

This allows you to keep multiple credential sets in your `.env` and choose at runtime.

### Portability Notes

- Environment variables work seamlessly on local macOS (via docker-compose or docker run) and in AWS environments (ECS, EC2, etc.)
- The `.env` file is for local development only and is not committed to git
- In AWS, set these as environment variables in your service configuration
- Backend selection makes this environment flexible for different deployment scenarios

## GitHub Authentication

### Option 1: SSH Keys (Automatic)

SSH keys are automatically generated on first run if they don't exist. Each container gets a unique key identifier based on username and container hostname (e.g., `vincentb@a3f2d9e8c1b4`), making it easy to track which key belongs to which container in GitHub.

1. Start the container:
   ```bash
   docker compose run --rm devenv
   ```

2. Copy the public key displayed in the logs (note the unique identifier)

3. Add it to GitHub: https://github.com/settings/keys

4. Test the connection:
   ```bash
   ssh -T git@github.com
   ```

**Persistence**: To persist SSH keys across container restarts, mount `~/.ssh`:
```yaml
volumes:
  - ~/.ssh:/home/${DEV_USER}/.ssh:ro  # Read-only for security
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

## The Ralph Wiggum Method

This container's default username (`ralphw`) references the [Ralph Wiggum method](https://ghuntley.com/ralph/) - a technique for AI-assisted development using a continuous feedback loop.

### What is Ralph?

Ralph is a simple but effective approach: put your requirements in a `PROMPT.md` file and run:

```bash
while :; do cat PROMPT.md | claude --print ; done
```

This creates an infinite loop where Claude Code:
1. Reads your requirements from PROMPT.md
2. Generates/modifies code
3. Repeats until you interrupt (Ctrl+C)

### Why "Ralph Wiggum"?

Named after the bumbling Simpsons character who accidentally succeeds. The method appears crude but can effectively produce working software through iteration. As the author notes: **"Ralph is deterministically bad in an undeterministic world"** - it produces predictable failure patterns that you refine through prompt engineering.

### Using Ralph in this Container

The container includes a `ralph` command that runs the loop for you:

```bash
# 1. Use the template as a starting point
cp ~/PROMPT.md.template ~/PROMPT.md

# 2. Edit your prompt file with your requirements
vim PROMPT.md

# 3. Run Ralph
ralph

# Or specify a custom prompt file
ralph my-custom-prompt.md

# 4. When things go wrong, refine PROMPT.md and let it continue
# 5. Press Ctrl+C when done
```

**Manual approach** (if you prefer):
```bash
# Create your prompt file
cat > PROMPT.md <<'EOF'
Build a REST API in Python using FastAPI that:
- Has endpoints for user CRUD operations
- Uses SQLite for storage
- Includes input validation
- Has comprehensive error handling
EOF

# Run the Ralph loop manually
while :; do cat PROMPT.md | claude --print ; done
```

### Tips

- Start with clear, specific requirements in PROMPT.md
- Let it run and observe patterns
- When it fails predictably, refine your prompt
- The container's isolation ensures Ralph can't damage your host system
- One reported case: $50k contract completed for $297 using this method

### Why This Container Supports Ralph

- **Isolated environment**: Ralph's mistakes stay contained
- **Git-based workflow**: All work stays in container, push when ready
- **Reproducible**: Rebuild from scratch anytime
- **Cost-effective**: AWS Bedrock billing vs. direct API

## Versions

Installed versions are recorded at `/opt/devenv/versions.txt` during build.
