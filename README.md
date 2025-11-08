# iPad as Second Monitor on Linux

Use your iPad as a wireless second monitor on Manjaro Linux with i3 window manager.

## Quick Start

1. **Make sure both devices are on the same WiFi network**

2. **Add virtual monitor and start Deskreen**:
   ```bash
   ./toggle-monitor.sh
   ```
   The script will:
   - Automatically download Deskreen if needed (saved to `~/.config/ipad_monitor/`)
   - Create a virtual display
   - Offer to start Deskreen for you

3. **On iPad**:
   - Open Chrome or Safari
   - Go to the URL shown by Deskreen (e.g., `http://192.168.1.100:3131`)
   - Connect and share the virtual monitor

4. **Done!** Move windows to your iPad with window manager keybindings

## What's Inside

- **toggle-monitor.sh** - Manages virtual monitor and Deskreen (auto-downloads on first run)
- **config.sh** - Configuration file for virtual display settings
- **TROUBLESHOOTING.md** - Solutions for common issues

**Note:** Deskreen is automatically downloaded to `~/.config/ipad_monitor/deskreen.AppImage` on first run.

## Virtual Monitor

The `toggle-monitor.sh` script creates a true virtual display that:
- Appears as a real second monitor in i3
- Can be positioned left/right/above/below your main display
- Works independently from your primary display
- Integrates perfectly with i3 window manager

### Usage

```bash
# Add virtual monitor
./toggle-monitor.sh

# Remove virtual monitor (run the same command again)
./toggle-monitor.sh
```

### Configuration

Edit `config.sh` to customize:

```bash
VIRTUAL_OUTPUT="HDMI-A-0"       # Your disconnected output
VIRTUAL_RESOLUTION="1920x1080"  # Match your iPad
VIRTUAL_POSITION="right-of"     # Position relative to main display
REFRESH_RATE="60"               # Hz
```

**Find your disconnected output:**
```bash
xrandr | grep disconnected
```

### Using with i3

Once the virtual monitor is active:

```bash
# Move window to virtual display
$mod+Shift+Right  # If positioned right-of
$mod+Shift+Left   # If positioned left-of

# Focus virtual display
$mod+Right  # If positioned right-of
```

**Configure i3 workspaces** (add to `~/.i3/config`):
```bash
# Assign workspaces to virtual monitor
workspace 9 output HDMI-A-0
workspace 10 output HDMI-A-0

# Keybinding to move to iPad workspace
bindsym $mod+i workspace 9
```

## Using Deskreen

1. **Start Deskreen**:
   ```bash
   # Automatically prompted by toggle-monitor.sh
   # Or run manually:
   ~/.config/ipad_monitor/deskreen.AppImage
   ```

2. **Share content**:
   - Share the virtual monitor (HDMI-A-0) - recommended
   - Or share specific application windows
   - **Don't share "Entire Screen"** - causes black screen

3. **Connect from iPad**:
   - Use Chrome (recommended) or Safari
   - Go to the URL shown
   - Follow pairing instructions

## Common iPad Resolutions

- **iPad Pro 12.9"**: 2732x2048 (native) or 1920x1080 (practical)
- **iPad Pro 11"**: 2388x1668 (native) or 1920x1080 (practical)
- **iPad Air**: 1920x1080
- **iPad Mini**: 1920x1080 or 1366x768

## Troubleshooting

### Black screen on iPad
**Solution**: Share the virtual monitor or a specific window, NOT "Entire Screen"

### Can't find disconnected output
**Check available outputs:**
```bash
xrandr
```
Look for disconnected HDMI, DP, or VGA outputs. Update `VIRTUAL_OUTPUT` in config.sh.

### Virtual monitor not appearing
```bash
# Verify X11 (not Wayland)
echo $XDG_SESSION_TYPE  # Should say: x11

# Check displays
xrandr --query

# Try toggling
./toggle-monitor.sh  # Remove if active
./toggle-monitor.sh  # Add again
```

### Mode errors
If you get "cannot find mode" errors, the toggle script automatically cleans up old modes and recreates them.

### Browser compatibility
- **Best**: Chrome on iPad
- **Good**: Safari on iPad (may have issues with some features)
- **Avoid**: Very old iPad browsers (iOS 9 or earlier)

## Performance

**Expected latency:**
- WiFi (5GHz): ~50-100ms - Good for productivity
- WiFi (2.4GHz): ~80-150ms - Usable for documents

**Tips for best performance:**
- Use 5GHz WiFi if available
- Close unnecessary apps on both devices
- Share virtual monitor instead of entire screen
- Use 1920x1080 resolution (not higher)

## Workflow Example

```bash
# Morning setup
./toggle-monitor.sh              # Add virtual monitor and start Deskreen
# Script will prompt to download Deskreen (first time only)
# Script will prompt to start Deskreen
# Connect from iPad

# Use window manager keybindings to move windows to virtual display
# Example for i3: $mod+Shift+Right

# Work with dual monitors all day

# Evening cleanup
./toggle-monitor.sh              # Remove virtual monitor
```

## Advanced i3 Configuration

Add to `~/.i3/config`:

```bash
# Define virtual monitor
set $monitor_ipad HDMI-A-0

# Workspaces for iPad
workspace 9 output $monitor_ipad
workspace 10 output $monitor_ipad

# Quick access to iPad workspaces
bindsym $mod+i workspace 9

# Move window to iPad and follow
bindsym $mod+Shift+i move container to workspace 9; workspace 9

# Scratchpad on iPad (useful for reference docs)
for_window [class="Firefox" title="Documentation"] move to workspace 9
```

## Files

- `toggle-monitor.sh` - Virtual monitor management and Deskreen launcher
- `config.sh` - Configuration for virtual display
- `README.md` - This file
- `QUICK_START.md` - Quick reference
- `TROUBLESHOOTING.md` - Detailed troubleshooting

**Auto-downloaded:**
- `~/.config/ipad_monitor/deskreen.AppImage` - Screen sharing app (~147 MB, downloaded on first run)

## Uninstalling

```bash
# Remove virtual monitor if active
./toggle-monitor.sh

# Delete the repository
cd ..
rm -rf ipad-monitor

# Optional: Remove Deskreen and config
rm -rf ~/.config/ipad_monitor
```

## Credits

- **Deskreen**: https://github.com/pavlobu/deskreen
- **xrandr**: X.Org Foundation
