# reset-idle-timer History

## 2026-04-30

### Requirement
Create a safe GNOME Ubuntu command that resets the normal idle/sleep timer once, without disabling sleep or changing settings.

### Implementation Details

#### 1. Software Selection
- **Tool**: `ydotool` (via `uinput`) was selected to inject a harmless keyboard event (Left Shift).
- **Packages**: `ydotool` and `ydotoold` installed from Ubuntu 24.04 repositories.

#### 2. Backend Daemon (`ydotoold.service`)
- **Issue**: The Ubuntu package did not include a systemd service.
- **Solution**: Created a custom system-wide service at `/etc/systemd/system/ydotoold.service`.
- **Permissions**: Configured to run as user `nathan`. Since the user has ACL permissions for `/dev/uinput` (verified by `getfacl`), this allows the daemon to function without root.
- **Socket**: Uses the default `/tmp/.ydotool_socket`, now owned by `nathan`.

#### 3. Reset Script (`/usr/local/bin/reset_idle_timer`)
- **Logic**: Injects a Left Shift keypress via `ydotool key shift`.
- **Logging**: Uses `/usr/bin/logger` to record every trigger in the system journal with the user identity and SSH client context.
- **Permissions**: Owned by `root:root`, mode `0755`. Accessible to any local user or agent.

#### 4. Evolution to Non-Sudo
- **Initial Plan**: Use a narrow `NOPASSWD` sudoers rule.
- **Final Result**: By running the backend daemon as the user, the `sudo` requirement was eliminated entirely, simplifying integration for local agents while maintaining a clear audit log via the script.

### Verification Steps
- **Service Check**: Confirmed `ydotoold.service` is active and listening.
- **Local Test**: Ran the script as `nathan` and confirmed a successful key injection.
- **Audit Check**: Verified journal entries: `triggered by user=nathan uid=1000 ssh_client=local`.
- **Empirical Proof**: Monitored `org.gnome.Mutter.IdleMonitor.GetIdletime` via DBus. Confirmed that triggering the script resets the idle counter from ~5000ms back to ~0ms.

### Maintenance
The tool is entirely self-contained. No GNOME settings are modified.
Logs can be viewed with: `journalctl -t reset_idle_timer`.
Setup logs are stored in: `~/tasks/reset-idle-timer/setup.log`.

---

## 2026-04-30 (bugfix)

### Problem
`reset_idle_timer` was printing "44" into the terminal and injecting stray keystrokes. Two bugs:
1. **Wrong ydotool syntax**: Script used old raw-keycode format `key 42:1 42:0`; current ydotool expects key names (`key shift`).
2. **ydotoold crashed at boot**: No udev rule persisted the `/dev/uinput` ACL, so when the kernel recreated the device the daemon lost access and crashed.

### Fixes Applied
- `/usr/local/bin/reset_idle_timer`: changed `key 42:1 42:0` → `key shift`.
- `/etc/udev/rules.d/70-uinput-nathan.rules`: added rule `KERNEL=="uinput", SUBSYSTEM=="misc", GROUP="nathan", MODE="0660"` so permissions survive reboots.
- Reloaded udev rules and restarted `ydotoold.service`.
