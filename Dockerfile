# syntax=docker/dockerfile:1
# Neovim C++ IDE container — Linux amd64 + arm64
# Usage:
#   docker run -it --rm -v $(pwd):/workspace ghcr.io/e-gleba/nvim-config/nvim-ci
# Contains: nvim, git, cmake, ninja, fzf, fd, ripgrep, lazygit, stylua

FROM ubuntu:24.04

# Fail fast: errexit + pipefail apply to every RUN, heredoc scripts included.
SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

# Build-time only — ARG (unlike ENV) does not leak into the runtime environment.
ARG DEBIAN_FRONTEND=noninteractive

# Cache mounts keep apt metadata out of the image and speed up rebuilds,
# so no manual /var/lib/apt/lists cleanup is needed.
# hadolint ignore=DL3008
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    <<EOF
apt-get update
apt-get install -y --no-install-recommends \
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
    pkg-config \
    xclip \
    wl-clipboard
ln -sf "$(command -v fdfind)" /usr/local/bin/fd
EOF

# Pinned for reproducibility — bump via renovate/dependabot.
ARG NEOVIM_VERSION=0.12.4
ARG LAZYGIT_VERSION=0.64.0
ARG STYLUA_VERSION=2.5.2

# TARGETARCH is injected by BuildKit (amd64/arm64) — no dpkg probing needed.
# Map it once to upstream release-asset naming, then fetch all tools in one layer.
ARG TARGETARCH
RUN <<EOF
case "${TARGETARCH}" in
    amd64) gh_arch='x86_64'; stylua_arch='x86_64' ;;
    arm64) gh_arch='arm64';  stylua_arch='aarch64' ;;
    *) echo "unsupported TARGETARCH: ${TARGETARCH}" >&2; exit 1 ;;
esac

cd /tmp

curl -fsSL "https://github.com/neovim/neovim/releases/download/v${NEOVIM_VERSION}/nvim-linux-${gh_arch}.tar.gz" \
    | tar -xz -C /opt
ln -sf "/opt/nvim-linux-${gh_arch}/bin/nvim" /usr/local/bin/nvim

curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_linux_${gh_arch}.tar.gz" \
    | tar -xz lazygit
install -Dm755 lazygit /usr/local/bin/lazygit

curl -fsSL "https://github.com/JohnnyMorganz/StyLua/releases/download/v${STYLUA_VERSION}/stylua-linux-${stylua_arch}.zip" -o stylua.zip
unzip -oq stylua.zip -d /usr/local/bin
chmod +x /usr/local/bin/stylua

rm -rf /tmp/*
EOF

# Build-time smoke test: core tools on PATH and functional.
RUN nvim --version \
    && git --version \
    && cmake --version \
    && ninja --version \
    && fzf --version \
    && fd --version \
    && rg --version \
    && lazygit --version \
    && stylua --version

# Runtime healthcheck: nvim launches and exits cleanly headless.
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD nvim --headless -c "qa!" || exit 1

WORKDIR /workspace
CMD ["nvim"]
