# ssh remote development

Zero-gui ssh workflow for wsl, macos and linux hosts on the same lan or across the internet.

---

## 1. prerequisites (run on the **target** host)

| platform | command | what it checks |
|----------|---------|--------------|
| linux | `sudo systemctl status sshd` | openssh server running |
| wsl | `sudo apt install openssh-server && sudo service ssh start` | install & start |
| macos | `sudo systemsetup -setremotelogin on && sudo launchctl load -w /System/Library/LaunchDaemons/ssh.plist` | enable remote login |

verify port 22 is listening:

```bash
ss -tlnp | grep ':22'
```

if the line shows `0.0.0.0:22` or `:::22`, the server is reachable.

---

## 2. local discovery (same network)

### option a: mdns / bonjour (zero config, recommended)

modern linux, wsl2 and macos advertise `hostname.local` automatically.

```bash
# from any client on the same lan
ping dev-box.local
ssh dev-box.local
```

if `.local` fails, install `avahi-daemon` on the linux/wsl host:

```bash
sudo apt install avahi-daemon
```

### option b: nmap sweep (guaranteed, no dns needed)

```bash
# discover every ssh server on 192.168.1.x
sudo nmap -p 22 --open 192.168.1.0/24
```

cross-reference the mac address with `ip link` on the target to be 100%% certain.

### option c: static dhcp lease (enterprise approach)

pin the target mac to a fixed ip in your router. add to client `~/.ssh/config`:

```
host dev-box
    hostname 192.168.1.50
    user your_name
    identityfile ~/.ssh/id_ed25519_dev
```

---

## 3. key-based auth (no passwords ever)

### generate a dedicated key per target

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_dev -c "dev-box $(date +%%F)"
```

### copy public key to target

```bash
ssh-copy-id -i ~/.ssh/id_ed25519_dev.pub dev-box.local
```

verify passwordless login works:

```bash
ssh dev-box.local
```

### client `~/.ssh/config` template

```
host dev-box
    hostname dev-box.local
    user your_name
    identityfile ~/.ssh/id_ed25519_dev
    identitiesonly yes
    serveraliveinterval 30
    serveralivecountmax 3
    stricthostkeychecking acceptnew
```

- `identitiesonly yes` — prevents ssh from offering every key in the agent and triggering rate limits [text](https://man.openbsd.org/ssh_config.5#IdentitiesOnly)
- `serveraliveinterval 30` — keeps nat sessions alive
- `stricthostkeychecking acceptnew` — safe default for new hosts without prompting interactively

---

## 4. guarantee you are on the right host

before any destructive operation (`rm -rf /workspace`, `cmake --build --clean-first`, `docker system prune -a`):

### automatic host banner

add this to target `/etc/update-motd.d/99-id` (executable):

```bash
#!/bin/sh
printf '\n=== host: %s | ip: %s | user: %s ===\n\n' \
    "$(hostname)" "$(hostname -i | awk '{print $1}')" "$(whoami)"
```

### client-side alias with verification

add to `~/.bashrc` / `~/.zshrc`:

```bash
sshw() {
    ssh "$1" 'hostname; whoami; pwd; uname -a'
    printf '\n\e[1;33mexecute ssh %s? [y/n] \e[0m' "$1"
    read -r confirm
    [ "$confirm" = "y" ] && ssh "$1"
}
```

usage: `sshw dev-box` — prints facts, asks for confirmation, then connects.

---

## 5. cross-network (not on the same lan)

### option a: tailscale (zero config vpn, recommended)

```bash
# install on both client and target
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
# authenticate via browser link once
```

after auth, every machine gets a stable ip like `100.x.y.z`. ssh to it from anywhere:

```
host dev-box-tail
    hostname 100.64.23.10
    user your_name
    identityfile ~/.ssh/id_ed25519_dev
```

tailscale does not require port forwarding or public ips [text](https://tailscale.com/kb/1017/install).

### option b: wireguard (manual, no third-party relay)

generate keys, exchange public keys, define `[peer]` endpoints. suitable when you control both routers and want zero external infrastructure.

### option c: cloudflare tunnel (corporate firewall friendly)

```bash
# on target only
curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared.deb
cloudflared tunnel login
cloudflared tunnel create dev-box
cloudflared tunnel route dns dev-box <uuid>.cfargotunnel.com
cloudflared tunnel run dev-box
```

client connects via:

```
host dev-box-cf
    hostname <uuid>.cfargotunnel.com
    user your_name
    identityfile ~/.ssh/id_ed25519_dev
```

no open ports, no public ip, works behind cg-nat and corporate firewalls [text](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/get-started/create-local-tunnel).

---

## 6. neovim remote workflow

### workflow a: ssh + terminal nvim (fastest, recommended)

```bash
ssh dev-box
cd /workspace/project
nvim .
```

- works with tmux persistence: `tmux new -s cpp` on target, re-attach later
- no local plugins needed, zero lag for lsp because clangd runs native on the target

### workflow b: sshfs (mount remote fs locally)

```bash
# macos / linux client
mkdir -p ~/mnt/dev-box
sshfs dev-box:/workspace ~/mnt/dev-box -o reconnect,volname=dev-box
# now open ~/mnt/dev-box in local nvim
# unmount: umount ~/mnt/dev-box
```

sshfs is acceptable for editing but too slow for `cmake --build` or `ninja`. keep the build on the target [text](https://github.com/libfuse/sshfs).

### workflow c: nvr / neovim remote (advanced)

on target, inside tmux, run headless nvim. from another ssh session:

```bash
nvr --remote-send ':e /workspace/project/src/main.cpp<cr>'
```

requires `pip install neovim-remote` on target. useful for ci/cd integration sending files to the already-opened editor [text](https://github.com/mhinz/neovim-remote).

---

## 7. diagnostic checklist

run this on the **client** when ssh fails:

```bash
#!/bin/bash
host="${1:-dev-box.local}"
port="${2:-22}"

echo "=== 1. dns resolution ==="
getent hosts "$host" || echo "fail: dns/mdns not resolving"

echo "=== 2. icmp ping ==="
ping -c 1 "$host" || echo "fail: host unreachable"

echo "=== 3. tcp port open ==="
timeout 3 bash -c "</dev/tcp/${host}/${port}" && echo "ok: port ${port} open" || echo "fail: port ${port} filtered"

echo "=== 4. ssh version / banner ==="
nc -zvw3 "$host" "$port" 2>&1

echo "=== 5. key auth test (verbose) ==="
ssh -o passwordauthentication=no -o batchmode=yes -v "$host" 'echo auth_ok' 2>&1 | grep -e 'auth_ok' -e 'failed' -e 'permission denied'
```

save as `ssh_diagnose.sh`, chmod +x, run `./ssh_diagnose.sh dev-box.local 22`.

---

## 8. firewall / port reference

| direction | protocol | port | action |
|-----------|----------|------|--------|
| target inbound | tcp | 22 | allow from client ip or tailnet |
| target inbound | udp | 41641 | tailscale direct (optional) |
| target inbound | udp | 3478 | tailscale stun (optional) |
| client outbound | tcp | 22 | usually allowed everywhere |

wsl2 specific: wsl2 has its own virtual nic. if `ss -tlnp` shows `127.0.0.1:22` only, edit `/etc/ssh/sshd_config`:

```
listenaddress 0.0.0.0
```

and restart `sudo service ssh restart`.

---

## 9. one-liner install script for target (ubuntu / debian)

paste into target terminal once:

```bash
curl -fsSL https://raw.githubusercontent.com/e-gleba/nvim-config/main/docs/ssh_target_setup.sh | bash
```

this installs openssh-server, avahi-daemon, hardens `sshd_config` (no root, no password, key only), enables the service, and prints the host key fingerprint. **not implemented yet** — create the script from the commands above if you need it.
