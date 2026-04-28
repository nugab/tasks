#!/usr/bin/env bash

SESSION="main"

if ! tmux has-session -t "$SESSION" 2>/dev/null; then
    tmux new-session -d -s "$SESSION" -n run1
fi

for win in run1 run2 run3; do
    if ! tmux list-windows -t "$SESSION" -F '#{window_name}' | grep -qx "$win"; then
        tmux new-window -t "$SESSION" -n "$win"
    fi
done

exec tmux attach-session -t "$SESSION"
