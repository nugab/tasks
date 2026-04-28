#!/usr/bin/env bash

AGENTS=(tmux_claude tmux_codex tmux_gemini)

running=()
for s in "${AGENTS[@]}"; do
    tmux has-session -t "$s" 2>/dev/null && running+=("$s")
done

if [ ${#running[@]} -eq 0 ]; then
    if ! tmux has-session -t test 2>/dev/null; then
        tmux new-session -d -s test -n test
    fi
    tmux set-option -t test remain-on-exit on
    trap 'tmux set-option -t test remain-on-exit off 2>/dev/null' EXIT
    tmux attach-session -t test
    exit
fi

for s in "${running[@]}"; do
    tmux set-option -t "$s" remain-on-exit on
done
trap 'for s in "${running[@]}"; do tmux set-option -t "$s" remain-on-exit off 2>/dev/null; done' EXIT

tmux attach-session -t "${running[0]}"
