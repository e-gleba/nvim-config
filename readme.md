# nvim-config

[![Neovim](https://img.shields.io/badge/Neovim-0.10%2B-57A143?logo=neovim&logoColor=white)](https://neovim.io)
[![Lua](https://img.shields.io/badge/Lua-5.1-2C2D72?logo=lua&logoColor=white)](https://www.lua.org)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](license.md)

Cross-platform C++ IDE in Neovim. CMake-first. Targets Android, iOS, Linux, Windows, macOS.

## Install

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

> Do not install Neovim nightly on macOS — it causes file-reload freezes. See [LazyVim #1581](https://github.com/LazyVim/LazyVim/issues/1581).

## First run
```bash
nvim --headless -V1 -c 'checkhealth' -c 'qa'   # verify
nvim --headless "+Lazy! sync" +qa                # force sync
```

## Structure

```
~/.config/nvim
├── init.lua
├── lazy-lock.json
├── lazyvim.json
├── stylua.toml
├── .luarc.json
├── .gitattributes
├── license.md
├── readme.md
└── lua/
    ├── config/
    │   ├── autocmds.lua
    │   ├── keymaps.lua
    │   ├── lazy.lua
    │   └── options.lua
    └── plugins/
        ├── android.lua
        ├── clangd.lua
        ├── cmake.lua
        ├── colortheme.lua
        ├── dap_ui.lua
        ├── format.lua
        ├── godbolt.lua
        ├── jira.lua
        ├── mason_tools.lua
        ├── neogen.lua
        ├── neotest.lua
        ├── overseer.lua
        ├── snacks.lua
        ├── treesj.lua
        └── web_search.lua
```

## Keymaps

| Action | Key |
|--------|-----|
| Build (CMake) | `<leader>cb` |
| Run | `<leader>cr` |
| Debug breakpoint | `<leader>db` |
| Debug continue | `<leader>dc` |
| Format | `<leader>cf` |
| Hover | `K` |
| Rename | `<leader>cr` |
| Test nearest | `<leader>tt` |
| AI search (Scira) | `<leader>ss` |
| GitHub search | `<leader>sH` |
| StackOverflow | `<leader>sO` |
| cppreference | `<leader>sR` |
| Web search picker | `<leader>sW` |
| Jira board (if configured) | `<leader>jj` |
| Jira issue info (if configured) | `<leader>ji` |

## Jira workflow

### Zero-auth commit prefix (always active)

On `git commit`, if your branch name contains a Jira-style key (e.g. `feature/PROJ-123-fix`), the commit buffer is auto-prepended with `PROJ-123: `. Cursor lands right after the colon — no auth, no API, works offline.

### Full Jira integration (optional, requires auth)

Set env vars to activate the plugin:
```bash
export JIRA_DOMAIN=yourcompany.atlassian.net
export JIRA_USER=your-email@company.com
export JIRA_API_TOKEN=your-api-token
```

Then inside Neovim:
```vim
:Jira auth login
:Jira <PROJECT_KEY>          -- open board
:Jira info <ISSUE_KEY>       -- view issue
```

Plugin only loads when `JIRA_DOMAIN` is present; otherwise it stays invisible.

## C++ workflow

`clangd` needs `compile_commands.json` at project root:
```bash
ln -s build/compile_commands.json compile_commands.json
```
Or in `CMakeLists.txt`:
```cmake
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
```

This config uses `cmake-tools.nvim` with native [CMake Presets](https://cmake.org/cmake/help/latest/manual/cmake-presets.7.html) support.

## License

[MIT](license.md)
