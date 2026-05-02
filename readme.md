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

| Tool | Purpose | Install |
|------|---------|---------|
| [Neovim](https://neovim.io) 0.10+ | Editor | `brew install neovim` / `winget install Neovim.Neovim` |
| [Git](https://git-scm.com) | Plugin manager | Usually pre-installed |
| [CMake](https://cmake.org) 3.20+ | Build system | `brew install cmake` / `winget install Kitware.CMake` |
| [Ninja](https://ninja-build.org) | Fast generator | `brew install ninja` / `choco install ninja` |
| C++ toolchain | Compiler + debugger | Xcode / MSVC / GCC / Clang |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder | `brew install fzf` / `winget install fzf` |
| [fd](https://github.com/sharkdp/fd) | Fast file finder | `brew install fd` / `choco install fd` |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Fast grep | `brew install ripgrep` / `winget install BurntSushi.ripgrep.MSVC` |
| [lazygit](https://github.com/jesseduffield/lazygit) | TUI Git client | `brew install lazygit` / `winget install JesseDuffield.lazygit` |
| Nerd Font | Icons in terminal | [JetBrainsMono Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip) |

> **Windows Note:** `clangd` and `codelldb` are installed automatically via [Mason](https://github.com/williamboman/mason.nvim). If you see PDB errors during native debugging, enable **Edit and Continue** in Visual Studio or set the environment variable `LLDB_USE_NATIVE_PDB_READER=1` before launching Neovim.

> **Line endings:** This repository enforces LF via [`.gitattributes`](.gitattributes). If you still see CRLF warnings from `cmake-language-server`, ensure Git is not overriding with `core.autocrlf=true`:
> ```bash
> git config --global core.autocrlf false
> ```

## Quick Start

### Linux / macOS

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

### macOS Warning: Do NOT install nightly

```bash
# AVOID -- causes file-reload freezes documented in LazyVim issue #1581
brew install --HEAD neovim   # NOT RECOMMENDED
```

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
│   │   ├── options.lua   -- Line endings, indentation, shell
│   │   └── web_search.lua
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
│       └── user.lua
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
| `cmake-language-server` reports "invalid line endings" | CRLF on disk (Git `core.autocrlf=true`) | `git config --global core.autocrlf false`, re-clone repo |
| Neovim freezes on file reload | Neovim 0.10.x nightly bug | Use stable 0.10.x release, not HEAD. See [LazyVim #1581](https://github.com/LazyVim/LazyVim/issues/1581) |
| Debug symbols load slowly on Windows | LLDB using old DIA reader | Set `$env:LLDB_USE_NATIVE_PDB_READER=1` permanently |
| `nvim-dap-python` fails on Windows | Virtual environment not activated | Activate venv before launching Neovim. See [nvim-dap-python #118](https://github.com/mfussenegger/nvim-dap-python/issues/118) |
| Missing icons / garbled glyphs | Terminal lacks Nerd Font | Install [JetBrainsMono Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip) and set terminal font |
| `fzf` / `fd` / `rg` not found | Tools not in PATH | Install via package manager (see Prerequisites table) |

## License

[Apache 2.0](LICENSE)
