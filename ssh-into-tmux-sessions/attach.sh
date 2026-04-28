#!/usr/bin/env bash

SESSION="main"

if ! tmux has-session -t "$SESSION" 2>/dev/null; then
    tmux new-session -d -s "$SESSION" -n test
fi

named_exists=false
for win in tmux_claude tmux_codex tmux_gemini; do
    if tmux list-windows -t "$SESSION" -F '#{window_name}' | grep -qx "$win"; then
        named_exists=true
        break
    fi
done

if ! $named_exists; then
    if ! tmux list-windows -t "$SESSION" -F '#{window_name}' | grep -qx "test"; then
        tmux new-window -t "$SESSION" -n test
    fi
    tmux select-window -t "$SESSION:test"
fi

exec tmux attach-session -t "$SESSION"
