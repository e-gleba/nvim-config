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

# Neovim stable
RUN curl -fsSL https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz \
    | tar -xz -C /opt \
    && ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

# lazygit
RUN curl -fsSL https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_Linux_x86_64.tar.gz \
    | tar -xz -C /usr/local/bin lazygit

# StyLua
RUN curl -fsSL https://github.com/JohnnyMorganz/StyLua/releases/download/v2.0.2/stylua-linux-x86_64.zip -o /tmp/stylua.zip \
    && unzip /tmp/stylua.zip -d /usr/local/bin \
    && rm /tmp/stylua.zip

WORKDIR /workspace
ENTRYPOINT ["nvim"]
