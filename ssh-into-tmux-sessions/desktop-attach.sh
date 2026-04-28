#!/usr/bin/env bash

DESKTOP="desktop"

if ! tmux has-session -t "$DESKTOP" 2>/dev/null; then
    tmux new-session -d -s "$DESKTOP" -n test
fi

exec tmux attach-session -t "$DESKTOP"
