# devenv todo

Create a portable developer environment in a Dockerfile / docker compose configuration. The end result should be a configration from which a docker image can be built in which sufficient tools are present to easily develope with Claude Code or Codex.

- [ ] Choose Ubuntu Server latest LTS tag and pin it
- [ ] Set non-interactive package installs (DEBIAN_FRONTEND=noninteractive)
- [ ] Install CA certificates and tzdata

- [ ] Install core CLI tools:
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

- [ ] Install runtimes:
  - Node.js latest LTS
  - Python latest LTS + uv
  - Rust via rustup (official installer)
  - Go via official tarball (official installer)

- [ ] Install agent CLIs:
  - Codex CLI
  - Claude Code CLI
- [ ] Record installed versions at build time

- [ ] Add Docker-in-Docker support (dockerd in container; requires privileged mode)
- [ ] Document dind runtime flags (e.g., DOCKER_TLS_CERTDIR=) and usage
- [ ] Consider mounting /var/lib/docker for persistence

- [ ] Create non-root user vincentb:vincentb
- [ ] Set default workdir to /home/vincentb
- [ ] Ensure home directory is writable by vincentb

- [ ] Credentials handling:
  - [ ] Do not bake API keys into image layers
  - [ ] Support Docker secrets and env vars at runtime
  - [ ] Read /run/secrets/OPENAI_API_KEY and /run/secrets/ANTHROPIC_API_KEY when present
  - [ ] Fall back to OPENAI_API_KEY and ANTHROPIC_API_KEY env vars
  - [ ] Provide entrypoint hook to write agent config files
  - [ ] chmod 600 on any written key files
  - [ ] Log only presence of credentials, never values

- [ ] No shell customization
- [ ] No build-essential/make/gcc for now
- [ ] Clean apt caches to keep image size down
- [ ] Prefer deterministic installs (pin LTS versions where possible)
