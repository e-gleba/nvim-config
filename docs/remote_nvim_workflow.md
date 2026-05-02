# Remote Neovim Workflow

Work on one machine, build on another. Two approaches. Pick one.

---

## Approach 1: Simple (recommended)

SSH into the remote machine, run Neovim there. Your local laptop is just a terminal.

**Why this wins:** Zero plugins. Zero configuration. Works on every OS. Survives wifi drops (tmux keeps your session). clangd runs natively on the target, so macOS SDK headers and Xcode generators just work.

### macOS target (build machine)

Step 1 — connect:
```bash
ssh devbox
```

Step 2 — tmux (survives disconnects):
```bash
tmux new -s cpp
```

Step 3 — open project:
```bash
nvim .
```

Step 4 — generate Xcode project (runs ON the Mac):
```vim
:!cmake --preset macos -G Xcode
```

Or from nvim terminal:
```vim
:term
$ cmake --preset macos -G Xcode
```

Step 5 — build:
```vim
:!xcodebuild -project MyProject.xcodeproj -scheme MyScheme
```

Or use the CMake preset if you prefer Ninja:
```vim
:!cmake --build build-macos
```

Detach tmux (`ctrl+b d`) and close the laptop. Later:
```bash
ssh devbox
tmux attach -t cpp
```

### WSL target (Linux-on-Windows)

Identical to the macOS flow. SSH into the WSL instance:
```bash
ssh wsl-box
tmux new -s cpp
nvim .
```

clangd sees the Linux headers natively. No Windows path translation issues.

### Windows native target (not recommended for C++)

Possible but fragile. clangd on Windows struggles with MSVC header paths over remote sessions. If you must:

```bash
ssh windows-box
# Install neovim via scoop on the Windows side
nvim .
# Use clang-cl or MinGW toolchain, not MSVC
```

For MSVC projects, prefer WSL2 or a native Windows IDE.

---

## Approach 2: VS Code-style (local UI, remote server)

Your local Neovim window connects to a headless Neovim server on the remote machine. Editing feels local. Builds run remotely. Clipboard, fonts, and keymaps stay local.

Plugin: `amitds1997/remote-nvim.nvim` — 850+ stars, actively maintained [text](https://github.com/amitds1997/remote-nvim.nvim).

### Install (optional)

Add this to your local `lua/plugins/remote.lua`:

```lua
return {
    {
        "amitds1997/remote-nvim.nvim",
        version = "*",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-telescope/telescope.nvim",
        },
        config = true,
    },
}
```

### Usage

```vim
:RemoteStart              -- connect to remote host (pick from SSH config)
:RemoteStop               -- disconnect and stop remote server
:RemoteCleanup            -- remove remote neovim setup entirely
```

What happens under the hood:
1. Plugin SSHes into the target
2. Downloads Neovim release if not present
3. Copies your local `~/.config/nvim` to the remote
4. Starts headless Neovim server on the remote
5. Connects your local UI to it

Build commands (`:!cmake ...`, terminal) execute on the remote automatically.

---

## FAQ

**Q: Can I generate an Xcode project from my Linux laptop?**

No. Xcode generator requires macOS. You must run CMake on the Mac. SSH into the Mac and run `cmake -G Xcode` there.

**Q: Does clangd index the project locally or remotely?**

- Approach 1 (SSH + tmux): clangd runs on the Mac, indexes on the Mac. Perfect.
- Approach 2 (remote-nvim.nvim): clangd runs on the Mac, indexes on the Mac. Perfect.

**Q: What if the Mac and my laptop are not on the same WiFi?**

Use Tailscale. Install on both machines:
```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

Then SSH to the Tailscale IP (`100.x.x.x`). Stable across networks, no port forwarding [text](https://tailscale.com/kb/1017/install).

**Q: Do I need to install Neovim and all tools on both machines?**

- Approach 1: Only on the remote (build) machine.
- Approach 2: On both. The plugin auto-installs Neovim on the remote, but Mason tools (clangd, codelldb) must already be there or the plugin must run Mason sync on first connect.

**Q: Which approach should I pick?**

| Situation | Pick |
|-----------|------|
| Same room, same network, fast WiFi | Approach 1 (tmux). Bulletproof. |
| Slow / unreliable network | Approach 1 (tmux). Survives drops. |
| Different city / Tailscale only | Approach 2 (remote-nvim.nvim). Latency hurts tmux redraw less, but local UI feels better over high latency. |
| Want local fonts and GUI nvim | Approach 2. |
| Want zero maintenance | Approach 1. |

---

## Quick start checklist

```bash
# 1. SSH works?
ssh devbox echo ok

# 2. Neovim on remote?
ssh devbox nvim --version

# 3. tmux on remote?
ssh devbox tmux -V

# 4. CMake + Xcode generator on remote?
ssh devbox cmake --version
ssh devbox xcodebuild -version

# 5. clangd on remote?
ssh devbox clangd --version

# 6. Open project
tmux new -s cpp
nvim .
```

All green? You are ready.
