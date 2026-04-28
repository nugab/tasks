# ssh-into-tmux-sessions history

## 2026-04-28

### Final design

**Desktop**: each agent gets its own tmux session (`tmux_claude`, `tmux_codex`, `tmux_gemini`).
- `nclaude`/`ncodex`/`ngemini` create+attach to their named session, or run the command
  directly if the session already exists
- Each terminal looks like a plain terminal with a green bar — sessions are visually unrelated

**Phone**: `attach.sh` finds whichever agent sessions are running, sets `remain-on-exit on`
on all of them (so accidental `exit` doesn't close anything), attaches to the first found
(claude > codex > gemini), falls back to a `test` session if none exist.
- F1/F2/F3 switch between sessions (`switch-client`)
- `remain-on-exit` is restored to `off` when phone disconnects (trap on EXIT)

**Phone SSH key** in `~/.ssh/authorized_keys` uses `command=` to run `attach.sh`,
with `no-port-forwarding,no-X11-forwarding,no-agent-forwarding`.

**`~/.tmux.conf`** additions:
- `status-style bg=green,fg=black` — locked green bar
- `bell-action none` / `visual-bell off` — silenced bells
- F1/F2/F3 bound to `switch-client -t tmux_claude/codex/gemini`
