# ssh-into-tmux-sessions history

## 2026-04-28

- Created `attach.sh` — attaches to tmux session `main`, creating it if absent
- Session has three windows: `run1`, `run2`, `run3` (created if missing on attach)
- Defaults to `run1` on every attach
- Wired up phone SSH key in `~/.ssh/authorized_keys` with `command=` directive pointing to `attach.sh`, restricting port forwarding, X11, and agent forwarding
- Added F1/F2/F3 bindings in `~/.tmux.conf` to switch windows without prefix
- Pinned tmux status bar to green, silenced bells
