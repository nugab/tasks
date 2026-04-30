# sleep-timer-schedule History

## 2026-04-29

### Requirement
Implement a dynamic idle sleep timer for the Ubuntu GNOME desktop that changes based on the day of the week and time of day.

### Implementation Details

#### 1. Configuration (`schedule.json`)
A JSON file was created to store the schedule. It supports a default timeout and an array of overrides.
- **Default**: 1800 seconds (30 minutes).
- **Overrides**: Monday, Wednesday, Friday between 07:00 and 17:00 set to 7200 seconds (2 hours).

#### 2. Logic Script (`set_sleep_timeout.py`)
A Python 3 script was implemented to manage the state:
- **Schedule Parsing**: Reads `schedule.json` and determines the target timeout based on `datetime.now()`.
- **System Integration**: Uses `gsettings` to get/set `org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout`.
- **Optimization**: Reads the current value first and only executes a `set` command if the value needs to change, reducing unnecessary DBUS calls.
- **Permissions**: Marked as executable (`chmod +x`).

#### 3. Automation (Systemd User Units)
Since `gsettings` requires a user session DBUS, implementation uses Systemd User units:
- **Service (`~/.config/systemd/user/sleep-timer.service`)**: A `oneshot` service that executes the Python script.
- **Timer (`~/.config/systemd/user/sleep-timer.timer`)**: Runs every 15 minutes (`OnCalendar=*:0/15`) and is `Persistent=true` to ensure it runs even if the system was suspended during a scheduled slot.

### Verification Steps
- **Manual Execution**: Confirmed script correctly calculated 1800s for Wednesday evening.
- **Simulation**: Temporarily modified `schedule.json` to 1801s, ran the service via `systemctl --user start`, and verified the change in `journalctl` and `gsettings get`.
- **Status Check**: Verified `sleep-timer.timer` is enabled and active.

### Maintenance
To change the schedule, edit `~/tasks/sleep-timer-schedule/schedule.json`. The timer will pick up changes on its next 15-minute interval.
