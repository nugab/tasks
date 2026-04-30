#!/usr/bin/env python3
import json
import subprocess
import datetime
import sys
from pathlib import Path

CONFIG_FILE = Path(__file__).parent / "schedule.json"

def load_schedule():
    with open(CONFIG_FILE, "r") as f:
        return json.load(f)

def is_currently_in_range(override, now):
    day_name = now.strftime("%a").lower()
    if day_name not in override["days"]:
        return False
    
    start_time = datetime.datetime.strptime(override["start_time"], "%H:%M").time()
    end_time = datetime.datetime.strptime(override["end_time"], "%H:%M").time()
    current_time = now.time()
    
    return start_time <= current_time <= end_time

def get_target_timeout(schedule):
    now = datetime.datetime.now()
    
    for override in schedule.get("overrides", []):
        if is_currently_in_range(override, now):
            return override["timeout_seconds"]
            
    return schedule["default_timeout_seconds"]

def set_gnome_timeout(seconds):
    try:
        # Check current value to avoid unnecessary writes
        current = subprocess.check_output([
            "gsettings", "get", "org.gnome.settings-daemon.plugins.power", "sleep-inactive-ac-timeout"
        ]).decode().strip()
        
        if current == str(seconds):
            return

        subprocess.run([
            "gsettings", "set", "org.gnome.settings-daemon.plugins.power", "sleep-inactive-ac-timeout", str(seconds)
        ], check=True)
        print(f"[{datetime.datetime.now()}] Updated idle sleep timeout to {seconds}s")
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)

if __name__ == "__main__":
    schedule = load_schedule()
    timeout = get_target_timeout(schedule)
    set_gnome_timeout(timeout)
