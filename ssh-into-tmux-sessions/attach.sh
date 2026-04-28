#!/usr/bin/env bash

DESKTOP="desktop"
PHONE="phone"

if ! tmux has-session -t "$DESKTOP" 2>/dev/null; then
    tmux new-session -d -s "$DESKTOP" -n test
fi

if ! tmux has-session -t "$PHONE" 2>/dev/null; then
    tmux new-session -d -s "$PHONE" -t "$DESKTOP"
fi

tmux set-option -t "$PHONE" remain-on-exit on
trap 'tmux set-option -t "$PHONE" remain-on-exit off' EXIT

selected=""
for win in tmux_claude tmux_codex tmux_gemini; do
    if tmux list-windows -t "$DESKTOP" -F '#{window_name}' | grep -qx "$win"; then
        selected="$win"
        break
    fi
done

if [ -z "$selected" ]; then
    if ! tmux list-windows -t "$DESKTOP" -F '#{window_name}' | grep -qx "test"; then
        tmux new-window -t "$DESKTOP:" -n test
    fi
    selected="test"
fi

tmux select-window -t "$PHONE:$selected"
tmux attach-session -t "$PHONE"
