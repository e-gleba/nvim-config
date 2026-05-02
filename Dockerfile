# Neovim C++ IDE container — Linux x86_64
# Usage:
#   docker run -it --rm -v $(pwd):/workspace ghcr.io/e-gleba/nvim-config/nvim-ci
# Contains: nvim, git, cmake, ninja, fzf, fd, ripgrep, lazygit, stylua

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/usr/local/bin:${PATH}"

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
    && ln -sf $(which fdfind) /usr/local/bin/fd \
    && rm -rf /var/lib/apt/lists/*

# lazygit — Ubuntu 24.04 does not ship this in apt; use upstream official install
RUN LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*') \
    && LAZYGIT_ARCH=$(uname -m | sed -e 's/aarch64/arm64/') \
    && curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${LAZYGIT_ARCH}.tar.gz" -o /tmp/lazygit.tar.gz \
    && tar xf /tmp/lazygit.tar.gz -C /tmp lazygit \
    && install /tmp/lazygit -D -t /usr/local/bin/ \
    && rm /tmp/lazygit /tmp/lazygit.tar.gz

# Neovim stable
RUN curl -fsSL https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz \
    | tar -xz -C /opt \
    && ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

# StyLua
RUN curl -fsSL https://github.com/JohnnyMorganz/StyLua/releases/download/v2.0.2/stylua-linux-x86_64.zip -o /tmp/stylua.zip \
    && unzip /tmp/stylua.zip -d /usr/local/bin \
    && rm /tmp/stylua.zip

WORKDIR /workspace
ENTRYPOINT ["nvim"]
