# syntax=docker/dockerfile:1
ARG UBUNTU_VERSION=24.04
FROM ubuntu:${UBUNTU_VERSION}
ARG UBUNTU_VERSION

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

ARG NODE_MAJOR=20
ARG GO_VERSION=1.22.4
ARG RUSTUP_TOOLCHAIN=stable
ARG DEV_USER=ralphw

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    tzdata \
    curl \
    gnupg \
    dirmngr \
    lsb-release \
  && rm -rf /var/lib/apt/lists/*

# GitHub CLI
RUN mkdir -p /etc/apt/keyrings \
  && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | gpg --dearmor -o /etc/apt/keyrings/githubcli.gpg \
  && chmod go+r /etc/apt/keyrings/githubcli.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli.gpg] https://cli.github.com/packages stable main" \
    > /etc/apt/sources.list.d/github-cli.list

# Node.js LTS
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
    | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
  && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" \
    > /etc/apt/sources.list.d/nodesource.list

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    git \
    curl \
    jq \
    fzf \
    ripgrep \
    vim \
    tmux \
    zip \
    unzip \
    gh \
    openssh-client \
    sudo \
    nodejs \
    python3 \
    python3-venv \
    python3-pip \
    docker.io \
    less \
    lynx \
  && rm -rf /var/lib/apt/lists/*

# uv (Python tooling)
ENV UV_INSTALL_DIR=/usr/local/bin
RUN curl -fsSL https://astral.sh/uv/install.sh | sh

# Rust via rustup
ENV CARGO_HOME=/usr/local/cargo
ENV RUSTUP_HOME=/usr/local/rustup
ENV PATH="${CARGO_HOME}/bin:${PATH}"
RUN curl -fsSL https://sh.rustup.rs | sh -s -- -y --no-modify-path --profile minimal --default-toolchain "${RUSTUP_TOOLCHAIN}"

# Go via official tarball
RUN curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-$(dpkg --print-architecture).tar.gz" -o /tmp/go.tgz \
  && rm -rf /usr/local/go \
  && tar -C /usr/local -xzf /tmp/go.tgz \
  && rm -f /tmp/go.tgz
ENV PATH="/usr/local/go/bin:${PATH}"

# Claude Code CLI will be installed as user ${DEV_USER} below
RUN useradd -m -s /bin/bash ${DEV_USER} \
  && usermod -aG sudo ${DEV_USER} \
  && echo '%sudo ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/sudo-nopasswd \
  && chmod 0440 /etc/sudoers.d/sudo-nopasswd

USER ${DEV_USER}
WORKDIR /home/${DEV_USER}

RUN curl -fsSL https://claude.ai/install.sh | bash \
  && echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

USER root

# Versions record
RUN mkdir -p /opt/devenv \
  && { \
    echo "ubuntu=${UBUNTU_VERSION}"; \
    echo "node=$(node --version)"; \
    echo "npm=$(npm --version)"; \
    echo "python=$(python3 --version | awk '{print $2}')"; \
    echo "uv=$(uv --version | awk '{print $2}')"; \
    echo "rustc=$(rustc --version | awk '{print $2}')"; \
    echo "cargo=$(cargo --version | awk '{print $2}')"; \
    echo "go=$(go version | awk '{print $3}')"; \
    echo "git=$(git --version | awk '{print $3}')"; \
    echo "gh=$(gh --version | head -n1 | awk '{print $3}')"; \
    echo "claude=$(claude --version 2>/dev/null || true)"; \
  } > /opt/devenv/versions.txt

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 755 /usr/local/bin/entrypoint.sh

USER ${DEV_USER}
WORKDIR /home/${DEV_USER}

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash"]
