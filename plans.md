# devenv todo

Create a portable developer environment in a Dockerfile / docker compose configuration. The end result should be a configration from which a docker image can be built in which sufficient tools are present to easily develope with Claude Code or Codex.

- [x] Choose Ubuntu Server latest LTS tag and pin it
- [x] Set non-interactive package installs (DEBIAN_FRONTEND=noninteractive)
- [x] Install CA certificates and tzdata

- [x] Install core CLI tools:
  - git
  - curl
  - jq
  - fzf
  - ripgrep
  - vim
  - tmux
  - zip
  - unzip
  - gh (GitHub CLI)

- [x] Install runtimes:
  - Node.js latest LTS
  - Python latest LTS + uv
  - Rust via rustup (official installer)
  - Go via official tarball (official installer)

- [x] Install agent CLIs:
  - Codex CLI
  - Claude Code CLI
- [x] Record installed versions at build time

- [x] Add Docker-in-Docker support (dockerd in container; requires privileged mode)
- [x] Document dind runtime flags (e.g., DOCKER_TLS_CERTDIR=) and usage
- [x] Consider mounting /var/lib/docker for persistence

- [x] Create non-root user vincentb:vincentb
- [x] Set default workdir to /home/vincentb
- [x] Ensure home directory is writable by vincentb

- [x] Credentials handling:
  - [x] Do not bake API keys into image layers
  - [x] Support Docker secrets and env vars at runtime
  - [x] Read /run/secrets/OPENAI_API_KEY and /run/secrets/ANTHROPIC_API_KEY when present
  - [x] Fall back to OPENAI_API_KEY and ANTHROPIC_API_KEY env vars
  - [x] Provide entrypoint hook to write agent config files
  - [x] chmod 600 on any written key files
  - [x] Log only presence of credentials, never values

- [x] No shell customization
- [x] No build-essential/make/gcc for now
- [x] Clean apt caches to keep image size down
- [x] Prefer deterministic installs (pin LTS versions where possible)
