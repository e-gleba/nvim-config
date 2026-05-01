# LazyVim — C++ & Python IDE

A fast, minimal Neovim configuration built on [LazyVim](https://lazyvim.github.io/) and [lazy.nvim](https://github.com/folke/lazy.nvim). Optimised for cross-platform C++ (CMake, `clangd`, `codelldb`) and Python (`debugpy`) development.

---

## Prerequisites

| Tool | Minimum | Purpose |
|------|---------|---------|
| Neovim | 0.9.x stable | Editor |
| Git | — | Plugin management |
| C compiler | — | Treesitter parsers |
| LLDB or GDB | — | C++ debugging |
| Python | 3.8+ | Python + `debugpy` |

> **Important:** Use Neovim 0.9.x stable. Nightly builds cause freezes on file reload — see [LazyVim #1581](https://github.com/LazyVim/LazyVim/issues/1581).

---

## Installation

### 1. Back up an existing config

**Linux / macOS**
```bash
mkdir -p ~/.config/nvim.bak ~/.local/share/nvim.bak \
  ~/.local/state/nvim.bak ~/.cache/nvim.bak
mv ~/.config/nvim ~/.config/nvim.bak/
mv ~/.local/share/nvim ~/.local/share/nvim.bak/
mv ~/.local/state/nvim ~/.local/state/nvim.bak/
mv ~/.cache/nvim ~/.cache/nvim.bak/
```

**Windows (PowerShell)**
```powershell
Rename-Item -Path "$env:LOCALAPPDATA\nvim"     -NewName "$env:LOCALAPPDATA\nvim.bak"     -ErrorAction SilentlyContinue
Rename-Item -Path "$env:LOCALAPPDATA\nvim-data" -NewName "$env:LOCALAPPDATA\nvim-data.bak" -ErrorAction SilentlyContinue
```

### 2. Clone this repository

**Linux / macOS**
```bash
git clone https://github.com/e-gleba/nvim-config.git ~/.config/nvim
```

**Windows (PowerShell)**
```powershell
git clone https://github.com/e-gleba/nvim-config.git "$env:LOCALAPPDATA\nvim"
```

### 3. Launch Neovim

```bash
nvim
```

`lazy.nvim` bootstraps itself and installs all plugins on first start.

---

## Platform Notes

### Linux

```bash
# Fedora
sudo dnf install neovim

# Ubuntu / Debian
sudo apt install neovim
```

### macOS

```bash
brew install neovim
# Do NOT use: brew install --HEAD neovim
```

### Windows

Recommended: **WSL2 + Ubuntu**.

For native Windows install the MSI from [Neovim Releases](https://github.com/neovim/neovim/releases), or use Scoop:

```powershell
scoop install neovim
```

You also need a C compiler for Treesitter — follow the [nvim-treesitter Windows guide](https://github.com/nvim-treesitter/nvim-treesitter#windows-installation).

---

## C++ Development

### CMake + `clangd`

- Enable `lang.clangd` and `lang.cmake` via `:LazyExtras`
- Ensure your project generates `compile_commands.json`:
  ```cmake
  set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
  ```
- Symlink it to the repo root so `clangd` sees it instantly:
  ```bash
  ln -s build/compile_commands.json compile_commands.json
  ```

### Debugging

Install `codelldb` via `:Mason` and configure `nvim-dap` for your target.

#### Windows LLDB / PDB Performance

Neovim can freeze while LLDB loads native PDB symbols. Set this environment variable **before** launching:

```powershell
# Current session
$env:LLDB_USE_NATIVE_PDB_READER = 1

# Permanent (run as Administrator)
[System.Environment]::SetEnvironmentVariable("LLDB_USE_NATIVE_PDB_READER", "1", "Machine")
```

Also ensure `msdia140.dll` from `[VisualStudioFolder]\DIA SDK\bin\` is on your `PATH` or copied next to your LLDB binary.

---

## Python Development

- Language server, linting, and formatting via LazyVim’s built-in Python extra
- Debugging via `debugpy` (installed through Mason)
- Activate your virtual environment before starting the debug session

> **Note:** `nvim-dap-python` requires the correct virtual environment on Windows — see [mfussenegger/nvim-dap-python #118](https://github.com/mfussenegger/nvim-dap-python/issues/118) if breakpoints fail to bind.

---

## Design Principles

- **Minimal surface area** — only plugins that earn their keep
- **Maximum reuse** — lean on LazyVim extras (`lang.clangd`, `lang.cmake`, `dap.core`) rather than reinventing defaults
- **Snake_case / laconic style** — readable Lua, no unnecessary abstraction
- **Fail-visible** — errors and diagnostics are surfaced, never hidden

---

## Resources

| Resource | Link |
|----------|------|
| LazyVim docs | [lazyvim.github.io](https://lazyvim.github.io/) |
| LazyVim installation | [lazyvim.github.io/installation](https://lazyvim.github.io/installation) |
| lazy.nvim docs | [lazy.folke.io/installation](https://lazy.folke.io/installation) |
| lazy.nvim repo | [github.com/folke/lazy.nvim](https://github.com/folke/lazy.nvim) |
| Neovim releases | [github.com/neovim/neovim/releases](https://github.com/neovim/neovim/releases) |
| nvim-treesitter Windows | [github.com/nvim-treesitter/nvim-treesitter#windows-installation](https://github.com/nvim-treesitter/nvim-treesitter#windows-installation) |
| nvim-dap-python #118 | [github.com/mfussenegger/nvim-dap-python/issues/118](https://github.com/mfussenegger/nvim-dap-python/issues/118) |
| LazyVim #1581 (freeze) | [github.com/LazyVim/LazyVim/issues/1581](https://github.com/LazyVim/LazyVim/issues/1581) |

---

## License

See [license](license).
