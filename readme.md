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
- **AI-agent friendly** — self-contained, heavily documented, minimal wrapper surface.
- **Fast** — zero animation, lazy-loaded everything, native LSP via `clangd`.
- **Stable** — upstream defaults first, explicit over clever.
- **Cross-platform** — identical experience on every OS.

## 📦 Prerequisites

| Tool | Purpose | Install |
|------|---------|---------|
| [Neovim](https://neovim.io) 0.10+ | Editor | `brew install neovim` / `winget install Neovim.Neovim` |
| [Git](https://git-scm.com) | Plugin manager | Usually pre-installed |
| [CMake](https://cmake.org) 3.20+ | Build system | `brew install cmake` / `winget install Kitware.CMake` |
| [Ninja](https://ninja-build.org) | Fast generator | `brew install ninja` / `choco install ninja` |
| C++ toolchain | Compiler + debugger | Xcode / MSVC / GCC / Clang |

> **Windows Note:** `clangd` and `codelldb` are installed automatically via [Mason](https://github.com/williamboman/mason.nvim). If you see PDB errors during native debugging, enable **Edit and Continue** in Visual Studio or set the environment variable `MSVC_ENABLE_PDB=1` before launching Neovim.

> **Line endings:** This repository enforces LF via [`.gitattributes`](.gitattributes). If you still see CRLF warnings from `cmake-language-server`, ensure Git is not overriding with `core.autocrlf=true`:
> ```bash
> git config --global core.autocrlf false
> ```

## 🚀 Quick Start

```bash
# 1. Back up your existing config
mv ~/.config/nvim ~/.config/nvim.bak.$(date +%s)

# 2. Clone
git clone https://github.com/e-gleba/nvim-config.git ~/.config/nvim

# 3. Launch — plugins install automatically on first start
nvim
```

## 🏗️ Structure

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

## 🔌 Features

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

## 🛠️ C++ Workflow Tips

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

## 📜 License

[Apache 2.0](LICENSE)
