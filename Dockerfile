# syntax=docker/dockerfile:1.8
# Neovim C++ IDE container — Linux x86_64
# Usage:
#   docker run -it --rm -v $(pwd):/workspace ghcr.io/e-gleba/nvim-config/nvim-ci
# Contains: nvim, git, cmake, ninja, fzf, fd, ripgrep, lazygit, stylua

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/usr/local/bin:${PATH}"

# Use bash for safer and more readable RUN instructions
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        cmake \
        ninja-build \
        fzf \
        fd-find \
        ripgrep \
        unzip \
        build-essential \
        gettext \
        libtool-bin \
        autoconf \
        automake \
        pkg-config \
        xclip \
        wl-clipboard \
    && ln -sf "$(command -v fdfind)" /usr/local/bin/fd \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Versions (pin for reproducibility; bump these via renovate/dependabot)
ARG LAZYGIT_VERSION=0.62.2
ARG NEOVIM_VERSION=0.12.3
ARG STYLUA_VERSION=2.5.2

# lazygit — Ubuntu 24.04 does not ship this in apt; use upstream official install
RUN dpkgArch="$(dpkg --print-architecture)" \
    && case "${dpkgArch}" in \
        amd64) lazygitArch='x86_64' ;; \
        arm64) lazygitArch='arm64' ;; \
        *) echo "Unsupported architecture: ${dpkgArch}"; exit 1 ;; \
    esac \
    && curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${lazygitArch}.tar.gz" -o /tmp/lazygit.tar.gz \
    && tar -xzf /tmp/lazygit.tar.gz -C /tmp lazygit \
    && install -Dm755 /tmp/lazygit /usr/local/bin/lazygit \
    && rm -f /tmp/lazygit /tmp/lazygit.tar.gz

# Neovim stable
RUN dpkgArch="$(dpkg --print-architecture)" \
    && case "${dpkgArch}" in \
        amd64) nvimArch='x86_64' ;; \
        arm64) nvimArch='arm64' ;; \
        *) echo "Unsupported architecture: ${dpkgArch}"; exit 1 ;; \
    esac \
    && curl -fsSL "https://github.com/neovim/neovim/releases/download/v${NEOVIM_VERSION}/nvim-linux-${nvimArch}.tar.gz" \
        | tar -xz -C /opt \
    && ln -sf "/opt/nvim-linux-${nvimArch}/bin/nvim" /usr/local/bin/nvim

# StyLua
RUN dpkgArch="$(dpkg --print-architecture)" \
    && case "${dpkgArch}" in \
        amd64) styluaArch='x86_64' ;; \
        aarch64|arm64) styluaArch='aarch64' ;; \
        *) echo "Unsupported architecture: ${dpkgArch}"; exit 1 ;; \
    esac \
    && curl -fsSL "https://github.com/JohnnyMorganz/StyLua/releases/download/v${STYLUA_VERSION}/stylua-linux-${styluaArch}.zip" -o /tmp/stylua.zip \
    && unzip -o /tmp/stylua.zip -d /usr/local/bin \
    && chmod +x /usr/local/bin/stylua \
    && rm -f /tmp/stylua.zip

# Build-time smoke test: ensure core tools are on PATH and functional
RUN nvim --version \
    && git --version \
    && cmake --version \
    && ninja --version \
    && fzf --version \
    && fd --version \
    && rg --version \
    && lazygit --version \
    && stylua --version

# Runtime healthcheck: verify nvim still launches and reports a clean --headless exit
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD nvim --headless -c "qa!" || exit 1

WORKDIR /workspace
CMD ["nvim"]

