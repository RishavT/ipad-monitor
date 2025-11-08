# Quick Start Guide

## Setup (first time)

```bash
# 1. Add virtual monitor
./toggle-monitor.sh

# 2. Start Deskreen
./deskreen.AppImage

# 3. On iPad: Open browser and go to the URL shown
# 4. Select the virtual monitor (HDMI-A-0) to share
```

## Daily Use

```bash
# Start
./toggle-monitor.sh        # If monitor not already active
./deskreen.AppImage        # Start sharing

# Use
# - Move windows: $mod+Shift+Right (in i3)
# - Focus iPad: $mod+Right

# Stop
./toggle-monitor.sh        # Remove virtual monitor
```

## Configuration

Edit `config.sh`:
```bash
VIRTUAL_OUTPUT="HDMI-A-0"       # Your disconnected output
VIRTUAL_RESOLUTION="1920x1080"  # Match your iPad
VIRTUAL_POSITION="right-of"     # left-of, right-of, above, below
```

Find your output:
```bash
xrandr | grep disconnected
```

## Troubleshooting

**Black screen?**
- Share the virtual monitor, NOT "Entire Screen"
- Try Chrome instead of Safari on iPad

**No disconnected output?**
```bash
xrandr  # Check what's available
# Update VIRTUAL_OUTPUT in config.sh
```

**Toggle not working?**
```bash
./toggle-monitor.sh  # Run twice: removes then adds
```
