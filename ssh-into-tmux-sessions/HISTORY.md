# ssh-into-tmux-sessions history

## 2026-04-28

- Created `attach.sh` — attaches to tmux session `main`, creating it if absent
- Session has three windows: `tmux_claude`, `tmux_codex`, `tmux_gemini`
- Windows are not auto-created; if none exist, falls back to `test` window (created if needed)
- Desktop and phone both attach to the same session `main` — each client tracks its own active window independently, but they share the same PTYs so commands from either end are visible to both
- Phone uses F1/F2/F3 to switch between windows (no prefix needed)
- Wired up phone SSH key in `~/.ssh/authorized_keys` with `command=` directive pointing to `attach.sh`, restricting port forwarding, X11, and agent forwarding
- Pinned tmux status bar to green, silenced bells
