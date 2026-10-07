---
description: Guided SSH + tmux remote-dev setup for an OS pair
agent: build
---

Local OS (detected, do not re-ask): !`uname -s`
Requested pair: $ARGUMENTS — `<local> <remote>`, e.g. `/remote-setup wsl win`.
Tokens: win, wsl, mac, linux (aliases: windows, wsl2, macos, ubuntu, debian).

Full procedure: @docs/remote_development_master_guide.md

Rules:

- If the pair is empty or ambiguous, use the `question` tool with options
  (win-wsl, wsl-win, mac-win, win-mac, wsl-mac, mac-wsl, win-linux,
  linux-win, mac-linux, linux-mac). At most 2 questions total: the pair,
  then remote IP/user if still unknown. Never paste the whole guide.
- Walk Phase 0-5 for the resolved pair only: prerequisites, IP discovery,
  sshd, key auth, SSH config alias, tmux session. Run each phase's
  verification command before moving on.
- Check before creating: existing keys, existing SSH config entry,
  reachable sshd. Only add what is missing.
- End with the guide's 10-point checklist, each item pass/fail.
