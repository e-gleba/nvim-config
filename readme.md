<div align="center">

<img src=".github/logo.svg" alt="nvim-config logo" width="180"/>

# nvim-config

**Cross-platform C++ IDE in Neovim. CMake-first.**
Android · iOS · Linux · Windows · macOS

[![CI](https://github.com/e-gleba/nvim-config/actions/workflows/ci.yml/badge.svg)](https://github.com/e-gleba/nvim-config/actions/workflows/ci.yml)
[![Neovim](https://img.shields.io/badge/Neovim-0.10%2B-57A143?logo=neovim&logoColor=white)](https://neovim.io)
[![Last Commit](https://img.shields.io/github/last-commit/e-gleba/nvim-config)](https://github.com/e-gleba/nvim-config/commits/main)

<p>
  <a href="https://www.lazyvim.org">LazyVim Docs</a> ·
  <a href="https://neovim.io/doc/">Neovim Docs</a> ·
  <a href="docs/remote_development_master_guide.md">Remote Dev Guide</a>
</p>

</div>

## ✨ Features

- **CMake-first C++ workflow** — configure, build, run, and test through native [CMake Presets](https://cmake.org/cmake/help/latest/manual/cmake-presets.7.html)
- **Full IDE stack** — clangd LSP, DAP debugging, Neotest, and Compiler Explorer integration
- **Commit prefixes** — Jira-style issue keys auto-prepended from branch names, zero auth
- **In-editor reference search** — cppreference, StackOverflow, GitHub, and AI search one keypress away
- **Remote-ready** — persistent tmux + Neovim sessions over SSH ([master guide](docs/remote_development_master_guide.md))
- **Reproducible** — locked plugins, stylua CI, and a prebuilt Docker image

## 🚀 Install

### macOS

```bash
brew install neovim git cmake ninja fzf fd ripgrep lazygit
git clone https://github.com/e-gleba/nvim-config.git ~/.config/nvim
nvim
```

### Linux

```bash
sudo apt update && sudo apt install -y neovim git cmake ninja-build fzf fd-find ripgrep
# lazygit: https://github.com/jesseduffield/lazygit#ubuntu
git clone https://github.com/e-gleba/nvim-config.git ~/.config/nvim
nvim
```

### Windows (PowerShell)

```powershell
# tools
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
scoop install neovim git cmake ninja llvm fzf fd ripgrep lazygit

# env (run once)
[Environment]::SetEnvironmentVariable("LLDB_USE_NATIVE_PDB_READER", "1", "User")
git config --global core.autocrlf false
git config --global core.eol lf

# config
git clone https://github.com/e-gleba/nvim-config.git $env:LOCALAPPDATA\nvim
nvim
```

> [!WARNING]
> Do not install Neovim nightly on macOS — it causes file-reload freezes. See [LazyVim #1581](https://github.com/LazyVim/LazyVim/issues/1581).

### Docker (Linux x86_64)

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.config/nvim:/root/.config/nvim \
  ghcr.io/e-gleba/nvim-config/nvim-ci:latest
```

## ✅ First run

```bash
nvim --headless -V1 -c 'checkhealth' -c 'qa'   # verify
nvim --headless "+Lazy! sync" +qa              # force sync
```

## 🔧 C++ workflow

`clangd` needs `compile_commands.json` at project root:

```bash
ln -s build/compile_commands.json compile_commands.json
```

Or in `CMakeLists.txt`:

```cmake
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
```

This config uses `cmake-tools.nvim` with native [CMake Presets](https://cmake.org/cmake/help/latest/manual/cmake-presets.7.html) support.

## 🎫 Commit prefixes

On `git commit`, if your branch name contains a Jira-style key (e.g. `feature/PROJ-123-fix`), the commit buffer is auto-prepended with `PROJ-123: `. Cursor lands right after the colon — no auth, no API, works offline.

Supported branch patterns:

```text
feature/PROJ-123-description
bugfix/PROJ-456-fix
PROJ-789-quick-patch
```

## ⌨️ Keymaps

Keymaps are declared in `lua/config/keymaps.lua` and individual plugin specs. Discover them in-editor via which-key — press `<leader>` and follow the groups. The code is the source of truth; this file intentionally does not duplicate it.

## 🗂️ Layout

Stock LazyVim conventions: `init.lua` bootstraps, `lua/config/` holds options/keymaps/autocmds, `lua/plugins/` holds one spec per plugin. The repository tree is the source of truth.

## 🔁 CI & Release

| Workflow | Trigger | Result |
|----------|---------|--------|
| **Lint** | Push / PR on `lua/**`, `init.lua`, lockfiles | Pulls `ghcr.io/.../nvim-ci:latest` and runs `stylua --check`. Falls back to local build if image is absent. |
| **Publish Docker** | Manual dispatch, or push to `main` with `Dockerfile` changes | Builds and pushes `ghcr.io/.../nvim-ci:latest`. |
| **Release** | Manual dispatch with version tag | Creates GitHub Release with auto-generated notes, then builds and pushes a tagged Docker image (`v1.2.3`). |

- [Run publish-docker](https://github.com/e-gleba/nvim-config/actions/workflows/publish-docker.yml)
- [Run release](https://github.com/e-gleba/nvim-config/actions/workflows/release.yml)

## 📄 License

[MIT](license.md)

<div align="center">

<sub>shaken at golden hour 🍸</sub>

</div>
