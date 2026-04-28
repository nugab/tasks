#!/usr/bin/env bash

SESSION="main"

if ! tmux has-session -t "$SESSION" 2>/dev/null; then
    tmux new-session -d -s "$SESSION" -n test
fi

selected=""
for win in tmux_claude tmux_codex tmux_gemini; do
    if tmux list-windows -t "$SESSION" -F '#{window_name}' | grep -qx "$win"; then
        selected="$win"
        break
    fi
done

if [ -z "$selected" ]; then
    if ! tmux list-windows -t "$SESSION" -F '#{window_name}' | grep -qx "test"; then
        tmux new-window -t "$SESSION" -n test
    fi
    selected="test"
fi

tmux select-window -t "$SESSION:$selected"
exec tmux attach-session -t "$SESSION"
