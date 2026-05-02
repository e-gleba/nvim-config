# ssh remote development — simple setup

connect from any machine (mac, linux, wsl) to your dev box with minimal steps.

---

## step 1 — find the target ip

run this **on the machine you want to ssh into** (the target):

**macos:**
```bash
ipconfig getifaddr en0
```

**windows (powershell):**
```powershell
(Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -match "192\.168" }).IPAddress
```

**wsl / linux:**
```bash
hostname -I | awk '{print $1}'
```

**you should see something like** `192.168.1.42`.

> **verification:** `ping 192.168.1.42` from the client machine. if packets reply, you are on the same network.

---

## step 2 — turn on ssh server on the target

**macos:**
```bash
sudo systemsetup -setremotelogin on
```

**wsl / ubuntu:**
```bash
sudo apt update && sudo apt install -y openssh-server
sudo service ssh start
```

> **verification:** `sudo ss -tlnp | grep :22` should show `0.0.0.0:22` or `:::22`.

**wsl fix:** if it shows `127.0.0.1:22` only, run:
```bash
echo "ListenAddress 0.0.0.0" | sudo tee -a /etc/ssh/sshd_config
sudo service ssh restart
```

---

## step 3 — first ssh connection

from the **client** (the machine with your keyboard):

```bash
ssh your_username@192.168.1.42
```

- `your_username` on mac/wsl is your login name (`whoami` on the target shows it).
- type `yes` when asked about host key fingerprint.
- enter the target's password.

> **verification:** you see the target's shell prompt. run `hostname` to confirm.

---

## step 4 — key auth (no more passwords)

on the **client**, generate a key once:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_devbox -N ""
```

copy it to the target:

```bash
ssh-copy-id -i ~/.ssh/id_devbox.pub your_username@192.168.1.42
```

> **verification:** `ssh -i ~/.ssh/id_devbox your_username@192.168.1.42` logs in without asking for a password.

---

## step 5 — make it easy with ssh config

on the **client**, edit `~/.ssh/config` (create if missing):

```
Host devbox
    HostName 192.168.1.42
    User your_username
    IdentityFile ~/.ssh/id_devbox
    IdentitiesOnly yes
    ServerAliveInterval 30
```

> **verification:** `ssh devbox` connects instantly, no ip to remember, no password.

---

## step 6 — don't know the ip? scan your network

if the target moved or you forgot the ip, from any machine on the same wifi:

```bash
# macos — install nmap first: brew install nmap
sudo nmap -p 22 --open 192.168.1.0/24

# linux / wsl
sudo nmap -p 22 --open 192.168.1.0/24
```

every line with `22/tcp open ssh` is a machine you can try.

> **verification:** match the mac address from `ip link` on the target with the nmap output.

---

## step 7 — not on the same wifi? use tailscale (2 minutes)

on **both** client and target:

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

authenticate the link from your browser once. then the target gets a stable ip like `100.x.y.z`. replace the ip in `~/.ssh/config` with that tailscale ip. works from anywhere, no port forwarding needed [text](https://tailscale.com/kb/1017/install).

> **verification:** `tailscale ip -4` on the target shows the ip. `ssh devbox` works from a coffee shop.

---

## step 8 — neovim remote workflow

connect and start a persistent session:

```bash
ssh devbox
cd ~/your-project
tmux new -s cpp
nvim .
```

detach: `ctrl+b d`. re-attach later: `tmux attach -t cpp`.

> **verification:** clangd, cmake, and the build all run natively on the target. zero lag because lsp is local to the source.

---

## quick troubleshoot

| problem | fix |
|---------|-----|
| `connection refused` | ssh server not running — re-run step 2 |
| `permission denied (publickey)` | re-run step 4, or use password once: `ssh -o PreferredAuthentications=password devbox` |
| `no route to host` | wrong ip or different network — re-run step 1 or use step 7 (tailscale) |
| forgot target username | run `whoami` on the target |
