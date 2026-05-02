# nvim-config

> **Cross-platform C++ IDE in Neovim.** CMake-first. Targets Android, iOS, Linux, Windows, macOS.

[![Neovim](https://img.shields.io/badge/Neovim-0.10%2B-57A143?logo=neovim&logoColor=white)](https://neovim.io)
[![Lua](https://img.shields.io/badge/Lua-5.1-2C2D72?logo=lua&logoColor=white)](https://www.lua.org)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Last Commit](https://img.shields.io/github/last-commit/e-gleba/nvim-config)](https://github.com/e-gleba/nvim-config/commits/main)

---

## Philosophy

- **Upstream defaults first.** Prefer `import = 'lazyvim.plugins.extras.*'` over hand-rolled plugin specs.
- **Minimal custom Lua.** No wrappers, no glue. When a plugin is needed, use its upstream defaults with `opts = {}` or the smallest possible override.
- **snake_case everywhere.** All file names, module names, and variable names use `snake_case` for consistency and clean GitHub linguist parsing.
- **Auto-provision tooling.** `mason-tool-installer.nvim` ensures `clangd`, `codelldb`, `clang-format`, and `cmake-language-server` install themselves.
- **Fast and reliable.** Zero animation bloat, no crashes on large C++ translation units.

---

## Quick Install

### macOS
```bash
brew install neovim git cmake ninja fzf fd ripgrep lazygit
```

### Linux (apt)
```bash
sudo apt update && sudo apt install -y neovim git cmake ninja-build fzf fd-find ripgrep
# lazygit: https://github.com/jesseduffield/lazygit#ubuntu
```

### Windows (Scoop)
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
scoop install neovim git cmake ninja llvm fzf fd ripgrep lazygit
```

### Deploy config
```bash
# macOS / Linux
mv ~/.config/nvim ~/.config/nvim.bak.$(date +%s)
git clone https://github.com/e-gleba/nvim-config.git ~/.config/nvim
nvim
```
```powershell
# Windows
$ts = Get-Date -Format "yyyyMMddHHmmss"
Rename-Item -Path $env:LOCALAPPDATA\nvim -NewName "nvim.bak.$ts" -ErrorAction SilentlyContinue
git clone https://github.com/e-gleba/nvim-config.git $env:LOCALAPPDATA\nvim
nvim
```

---

## Features at a Glance

### C++ / CMake IDE

| Feature | Plugin / Source | Keymap |
|---------|----------------|--------|
| LSP (C/C++) | `clangd` + `clangd_extensions.nvim` | `K` hover, `<leader>cr` rename |
| CMake build | `cmake-tools.nvim` | `<leader>cb` build, `<leader>cr` run |
| Debug | `nvim-dap` + `codelldb` + `nvim-dap-ui` | `<leader>db` breakpoint, `<leader>dc` continue |
| Test (GTest) | `neotest` + `neotest-gtest` | `<leader>tt` nearest, `<leader>tS` summary |
| Format | `conform.nvim` (`clang-format`, `cmake_format`) | `<leader>cf` |
| Assembly view | `vim-godbolt` | `<leader>caa` asm, `<leader>cap` pipeline |
| Doxygen docs | `neogen` | `<leader>cn` generate |
| Symbol outline | `aerial.nvim` (LazyVim extra) | `<leader>cs` toggle |

### Search & Navigation

| Feature | Plugin / Source | Keymap |
|---------|----------------|--------|
| AI search (Scira) | `browse.nvim` | `<leader>ss` normal + visual |
| Google | `browse.nvim` | `<leader>sG` normal + visual |
| GitHub Code | `browse.nvim` | `<leader>sH` normal + visual |
| StackOverflow | `browse.nvim` | `<leader>sO` normal + visual |
| cppreference | `browse.nvim` | `<leader>sR` normal + visual |
| Pick any engine | `browse.nvim` | `<leader>sW` picker |
| Git diff | `diffview.nvim` (LazyVim extra) | `<leader>gd` |
| Rename preview | `inc-rename.nvim` (LazyVim extra) | `<leader>cr` |
| File tree | `snacks.nvim` explorer | `<leader>e` |
| Fuzzy find | `snacks.nvim` picker | `<leader><space>` |

### Platform Tooling

| Platform | Native IDE | Notes |
|----------|-----------|-------|
| Android | Android Studio | Neovim edits; Studio builds APK |
| iOS | Xcode | Neovim edits; Xcode deploys |
| Windows | Visual Studio / CLion | Neovim edits; MSVC handles PDB |
| Linux | Any | Terminal deploy |

---

## Directory Structure

All files use `snake_case` for consistency and clean GitHub linguist parsing.

```
~/.config/nvim
├── init.lua              -- bootstrap entry point
├── lazy-lock.json        -- pinned plugin versions
├── lazyvim.json          -- LazyVim extras registry
├── stylua.toml           -- Lua formatter config (snake_case enforced)
├── .luarc.json           -- Lua LSP workspace settings
├── .gitattributes        -- LF enforcement + linguist hints
├── LICENSE               -- MIT
├── readme.md             -- this file
├── lua/
│   ├── config/
│   │   ├── autocmds.lua  -- user autocommands
│   │   ├── keymaps.lua   -- user keymaps ( minimal )
│   │   ├── lazy.lua      -- plugin loader + extras
│   │   └── options.lua   -- vim.opt overrides
│   └── plugins/          -- one file per domain, snake_case names
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
│       ├── web_search.lua
│       └── …
```

---

## First Launch

```bash
# Headless health check
nvim --headless -V1 -c 'checkhealth' -c 'qa'

# Force-sync plugins and exit
nvim --headless "+Lazy! sync" +qa
```

---

## C++ Workflow

### compile_commands.json
`clangd` needs this at project root:
```bash
ln -s build/compile_commands.json compile_commands.json
```
Or in `CMakeLists.txt`:
```cmake
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
```

### CMake Presets
Place `CMakePresets.json` at project root. `cmake-tools.nvim` discovers it automatically.

---

## Windows Notes

- **Line endings:** `git config --global core.autocrlf false` and `git config --global core.eol lf`
- **PDB debug:** `[Environment]::SetEnvironmentVariable("LLDB_USE_NATIVE_PDB_READER", "1", "User")`
- **Shell:** PowerShell is auto-configured in `options.lua`

> **Do NOT install Neovim nightly on macOS.** It causes file-reload freezes. See [LazyVim #1581](https://github.com/LazyVim/LazyVim/issues/1581).

---

## License

[MIT](LICENSE) — free to reuse, modify, and redistribute.
