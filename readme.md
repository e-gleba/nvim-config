<div align="center">

# nvim-config

**Professional cross-platform C++ IDE inside Neovim.**
**CMake-first. Targets: Android, iOS, Linux, Windows, macOS.**

[![Neovim](https://img.shields.io/badge/Neovim-0.10%2B-57A143?logo=neovim&logoColor=white)](https://neovim.io)
[![Lua](https://img.shields.io/badge/Lua-5.1-2C2D72?logo=lua&logoColor=white)](https://www.lua.org)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Stars](https://img.shields.io/github/stars/e-gleba/nvim-config?style=social)](https://github.com/e-gleba/nvim-config)

</div>

---

## Target Audience

This configuration is built for **professional cross-platform C++ developers** who work across **Android, iOS, Linux, Windows, and macOS** using **CMake** as the universal build system.

It is designed to be:
- **AI-agent friendly** -- self-contained, heavily documented, minimal wrapper surface.
- **Fast** -- zero animation, lazy-loaded everything, native LSP via `clangd`.
- **Stable** -- upstream defaults first, explicit over clever.
- **Cross-platform** -- identical experience on every OS.

## Prerequisites

### macOS

```bash
brew install neovim git cmake ninja fzf fd ripgrep lazygit
```

### Linux (apt)

```bash
sudo apt update && sudo apt install -y neovim git cmake ninja-build fzf fd-find ripgrep
# lazygit: follow https://github.com/jesseduffield/lazygit?tab=readme-ov-file#ubuntu
```

### Windows -- Scoop (recommended)

```powershell
# Install scoop (run once)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

# Install everything in one shot
scoop install neovim git cmake ninja llvm fzf fd ripgrep lazygit
```

> **If you prefer winget / chocolatey:**
> ```powershell
> winget install Neovim.Neovim Kitware.CMake JernejSimoncic.Fzf sharkdp.Fd BurntSushi.Ripgrep.MSVC JesseDuffield.lazygit
> choco install neovim cmake ninja fzf fd ripgrep lazygit
> ```

### All platforms

| Requirement | Purpose | Check command |
|-------------|---------|---------------|
| [Neovim](https://neovim.io) 0.10+ stable | Editor | `nvim --version` |
| [Git](https://git-scm.com) | Plugin manager | `git --version` |
| [CMake](https://cmake.org) 3.20+ | Build system | `cmake --version` |
| [Ninja](https://ninja-build.org) | Fast generator | `ninja --version` |
| C++ toolchain | Compiler + debugger | `clang++ --version` / `cl` / `g++` |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder | `fzf --version` |
| [fd](https://github.com/sharkdp/fd) | Fast file finder | `fd --version` |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Fast grep | `rg --version` |
| [lazygit](https://github.com/jesseduffield/lazygit) | TUI Git client | `lazygit --version` |
| Nerd Font | Icons in terminal | [JetBrainsMono Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip) |

> **Nightly warning (macOS):** Do NOT install Neovim nightly. It causes file-reload freezes. See [LazyVim #1581](https://github.com/LazyVim/LazyVim/issues/1581).
> ```bash
> brew install neovim        # OK
> brew install --HEAD neovim # NOT OK
> ```

## Windows Environment Variables

Some Windows-specific environment variables are required for debugging and line-ending sanity.

### LLDB / CodeLLDB PDB support

CodeLLDB on Windows needs the native PDB reader to debug MSVC binaries. Set this **permanently** (recommended) or per-session.

```powershell
# Permanent -- persists across reboots
[Environment]::SetEnvironmentVariable("LLDB_USE_NATIVE_PDB_READER", "1", "User")

# Current session only
$env:LLDB_USE_NATIVE_PDB_READER = "1"
```

### Line endings -- force LF in Git

Neovim and LSPs require LF. Prevent Git from converting to CRLF on checkout:

```powershell
# Global -- affects all repositories
git config --global core.autocrlf false
git config --global core.eol lf
```

> If you already cloned a repo with CRLF, force-reset line endings:
> ```bash
> git rm --cached -r .
> git reset --hard
> ```

## Quick Start

### macOS / Linux

```bash
# 1. Back up existing config
mv ~/.config/nvim ~/.config/nvim.bak.$(date +%s)
mv ~/.local/share/nvim ~/.local/share/nvim.bak.$(date +%s)
mv ~/.local/state/nvim ~/.local/state/nvim.bak.$(date +%s)
mv ~/.cache/nvim ~/.cache/nvim.bak.$(date +%s)

# 2. Clone
git clone https://github.com/e-gleba/nvim-config.git ~/.config/nvim

# 3. Launch -- plugins install automatically
nvim
```

### Windows (PowerShell)

```powershell
# 1. Back up existing config
$ts = Get-Date -Format "yyyyMMddHHmmss"
Rename-Item -Path $env:LOCALAPPDATA\nvim -NewName "nvim.bak.$ts" -ErrorAction SilentlyContinue
Rename-Item -Path $env:LOCALAPPDATA\nvim-data -NewName "nvim-data.bak.$ts" -ErrorAction SilentlyContinue
Rename-Item -Path $env:LOCALAPPDATA\nvim-state -NewName "nvim-state.bak.$ts" -ErrorAction SilentlyContinue
Rename-Item -Path $env:LOCALAPPDATA\nvim-cache -NewName "nvim-cache.bak.$ts" -ErrorAction SilentlyContinue

# 2. Clone
git clone https://github.com/e-gleba/nvim-config.git $env:LOCALAPPDATA\nvim

# 3. Launch
nvim
```

## First Launch Diagnostics

After cloning, run this headless check to verify all tools are discoverable, plugins load cleanly, and health checks pass. Catches missing binaries, network issues, or permission problems before your first interactive session.

```bash
# Headless health check with verbose logging (output includes full diagnostics)
nvim --headless -V1 -c 'checkhealth' -c 'qa'

# Or force-sync all plugins and exit (catches download / lockfile drift)
nvim --headless "+Lazy! sync" +qa
```

Verbose logs are written to:
- **Linux / macOS:** `~/.local/state/nvim/log`
- **Windows:** `~/AppData/Local/nvim-data/log`

## Working with Native IDEs

This config is designed to coexist with platform-native IDEs. You edit C++ in Neovim; you package and deploy in the native IDE.

| Platform | Native IDE | Workflow |
|----------|-----------|----------|
| Android | [Android Studio](https://developer.android.com/studio) | Neovim edits `CMakeLists.txt` / `.cpp`; Android Studio builds APK via Gradle. |
| iOS | [Xcode](https://developer.apple.com/xcode/) | Neovim edits sources; Xcode builds/deploys to device via generated `.xcodeproj`. |
| Windows | [Visual Studio](https://visualstudio.microsoft.com/) / [CLion](https://www.jetbrains.com/clion/) | Neovim edits; IDE handles MSVC toolchain / PDB symbols. |
| Linux | Any (Qt Creator, CLion, VS Code) | Neovim is the editor; use native debugger or terminal for deploy. |

**Windows PowerShell tip -- open current file in Android Studio or CLion:**

```powershell
# From inside Neovim terminal (:terminal)
# Open Android Studio at current project root
& "C:\Program Files\Android\Android Studio\bin\studio64.exe" $(git rev-parse --show-toplevel)

# Or open CLion at current file
& "C:\Program Files\JetBrains\CLion Nova\bin\clion64.exe" --line $(nvim --headless -c 'echo line(".")' -c 'q!' 2>$null) $env:NVIM_FILE
```

**macOS tip -- open Xcode from Neovim terminal:**

```bash
# Open generated Xcode project
open build/MyProject.xcodeproj
```

## Structure

```
~/.config/nvim
├── init.lua              -- Entry point
├── lazy-lock.json        -- Pin exact plugin versions
├── LICENSE               -- Apache 2.0
├── lua
│   ├── config            -- Core: keymaps, options, autocmds, lazy
│   │   ├── autocmds.lua
│   │   ├── keymaps.lua
│   │   ├── lazy.lua      -- Plugin loader + extras
│   │   └── options.lua   -- Line endings, indentation, shell
│   └── plugins           -- Plugin specs (one file per domain)
│       ├── android.lua
│       ├── clangd.lua
│       ├── cmake.lua
│       ├── colortheme.lua
│       ├── dap_ui.lua
│       ├── format.lua
│       ├── gitignore.lua
│       ├── godbolt.lua
│       ├── mason_tools.lua
│       ├── neogen.lua
│       ├── neotest.lua
│       ├── overseer.lua
│       ├── snacks.lua
│       ├── treesj.lua
│       ├── user.lua
│       └── web_search.lua
```

## Features

| Feature | Plugin / Extra | Keymap |
|---------|---------------|--------|
| LSP (C/C++) | `clangd` + `clangd_extensions.nvim` | Hover `K`, Rename `<leader>cr` |
| CMake | `cmake-tools.nvim` + `neocmake` | Build `<leader>cb`, Run `<leader>cr` |
| Debug | `nvim-dap` + `codelldb` + `nvim-dap-ui` | Toggle breakpoint `<leader>db`, Continue `<leader>dc` |
| Test (GTest) | `neotest` + `neotest-gtest` | Run nearest `<leader>tt`, Summary `<leader>tS` |
| Format | `conform.nvim` (`clang-format`, `cmake_format`) | Format `<leader>cf` |
| Assembly view | `vim-godbolt` | Show asm `<leader>caa`, Pipeline `<leader>cap` |
| Tasks / Presets | `overseer.nvim` | Task runner `<leader>or` |
| Doxygen | `neogen` | Generate doc `<leader>cn` |
| Symbol outline | `aerial.nvim` (LazyVim extra) | Toggle `<leader>cs` |
| Git diff | `diffview.nvim` (LazyVim extra) | Open `<leader>gd` |
| Rename preview | `inc-rename.nvim` (LazyVim extra) | `<leader>cr` (live preview) |
| Web search | `browse.nvim` (Google, cppreference, StackOverflow, Perplexity…) | `:Browse input` |

## C++ Workflow Tips

### compile_commands.json

`clangd` needs this file in the project root or build directory.

```bash
# Symlink it so clangd finds it regardless of cwd
ln -s build/compile_commands.json compile_commands.json
```

Or configure CMake:

```cmake
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
```

### CMake Presets

This config uses `cmake-tools.nvim` with native CMake Presets support. Ensure your repository has `CMakePresets.json` at the project root.

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `cmake-language-server` reports "invalid line endings" | CRLF on disk (Git `core.autocrlf=true`) | See [Windows Environment Variables](#windows-environment-variables) above; re-clone with `core.autocrlf=false` |
| Neovim freezes on file reload | Neovim 0.10.x nightly bug | Use stable 0.10.x release, not HEAD. See [LazyVim #1581](https://github.com/LazyVim/LazyVim/issues/1581) |
| Debug symbols load slowly on Windows | LLDB using old DIA reader | Run `[Environment]::SetEnvironmentVariable("LLDB_USE_NATIVE_PDB_READER", "1", "User")` and restart Neovim |
| `nvim-dap-python` fails on Windows | Virtual environment not activated | Activate venv before launching Neovim. See [nvim-dap-python #118](https://github.com/mfussenegger/nvim-dap-python/issues/118) |
| Missing icons / garbled glyphs | Terminal lacks Nerd Font | Install [JetBrainsMono Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip) and set terminal font |
| `fzf` / `fd` / `rg` not found | Tools not in PATH | Add scoop / brew / apt bin directory to PATH, or reinstall |

## License

[Apache 2.0](LICENSE)
