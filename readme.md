# LazyVim Configuration for C++/Python Development

A meticulously crafted Neovim configuration optimized for C++ and Python development. This setup provides a clean, efficient editing experience while maintaining excellent performance - designed specifically for developers who value minimal, high-quality tooling.

## Installation Guide

### Prerequisites

- Neovim 0.9.x (stable version only, avoid pre-release versions)
- Git
- C compiler (required for Treesitter functionality)
- For C++ development: LLDB or GDB
- For Python development: Python 3.8+ with debugpy

### Installing Neovim

#### Linux (Fedora recommended)

```bash
# Fedora
sudo dnf install neovim

# Ubuntu/Debian
sudo apt install neovim
```

#### macOS

```bash
# Using Homebrew (recommended)
brew install neovim

# AVOID nightly builds which cause stability issues:
# brew install --HEAD neovim  # NOT RECOMMENDED
```

#### Windows

**Recommended approach**: Use Windows Subsystem for Linux (WSL2) with Ubuntu.

For native Windows:

- Download the MSI installer from [Neovim Releases](https://github.com/neovim/neovim/releases)
- Or use a package manager:

  ```powershell
  # Scoop
  scoop install neovim
  ```

**Important**: On Windows, you'll need to install a C compiler for Treesitter support following the [nvim-treesitter documentation](https://github.com/nvim-treesitter/nvim-treesitter#windows-installation).

### Setting Up This Configuration

1. First, backup any existing Neovim configuration:

```bash
# Linux/macOS
mkdir -p ~/.config/nvim.bak
mv ~/.config/nvim ~/.config/nvim.bak/
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak

# Windows (PowerShell)
Rename-Item -Path $env:LOCALAPPDATA\nvim -NewName $env:LOCALAPPDATA\nvim.bak -ErrorAction SilentlyContinue
Rename-Item -Path $env:LOCALAPPDATA\nvim-data -NewName $env:LOCALAPPDATA\nvim-data.bak -ErrorAction SilentlyContinue
```

2. Clone this repository:

```bash
# Linux/macOS
git clone https://github.com/geugenm/nvim-config.git ~/.config/nvim

# Windows (PowerShell)
git clone https://github.com/geugenm/nvim-config.git $env:LOCALAPPDATA\nvim
```

3. Launch Neovim to automatically install plugins:

```bash
nvim
```

The configuration will automatically install [lazy.nvim](https://github.com/folke/lazy.nvim) plugin manager and all required plugins on first launch.

## C++ Development Environment

### Debugging Setup

#### Windows-Specific Debugging Configuration

To avoid freezes when loading native debug symbols on Windows:

1. Set the `LLDB_USE_NATIVE_PDB_READER` environment variable to prevent the extremely slow symbol loading issue:

```powershell
# For current session
$env:LLDB_USE_NATIVE_PDB_READER=1

# Set permanently (run as Administrator)
[System.Environment]::SetEnvironmentVariable("LLDB_USE_NATIVE_PDB_READER", "1", "Machine")
```

2. Ensure proper DIA SDK configuration:
   - Locate `msdia140.dll` in your Visual Studio installation (typically at `[VisualStudioFolder]\DIA SDK\bin\msdia140.dll`)
   - Add this location to your PATH or copy the DLL to your LLDB installation directory

This addresses the common issue where Neovim freezes when loading debug symbols on Windows, significantly improving debugging performance.

## Python Development Environment

The configuration includes:

- Python language server integration
- debugpy for debugging Python applications (with proper virtual environment activation)
- Advanced code completion and refactoring tools

## Key Features

- Snake_case naming convention emphasis in code
- Minimal, laconic code style with maximum library reuse
- Fast startup and responsive editing experience
- Optimized for both C++ and Python development workflows
- Git integration with staging, diffing, and history visualization
- Error handling that doesn't hide problems

## Documentation and Resources

- Built upon [LazyVim](https://lazyvim.github.io/) - see their [installation guide](https://lazyvim.github.io/installation)
- Uses [lazy.nvim](https://github.com/folke/lazy.nvim) for plugin management - see their [documentation](https://lazy.folke.io/installation)
- Documentation formatted in proper markdown following industry best practices

## Troubleshooting

### Known Issues

- **nvim-dap debugpy issues on Windows**: Requires proper virtual environment activation before debugging. See [this issue](https://github.com/mfussenegger/nvim-dap-python/issues/118) for details.
- **Neovim freezes on file reload**: This issue affects Neovim 0.10.x, use stable 0.9.x instead. See [LazyVim issue #1581](https://github.com/LazyVim/LazyVim/issues/1581).
- **LLDB symbol loading performance**: Set `LLDB_USE_NATIVE_PDB_READER=1` as described above to dramatically improve performance.
