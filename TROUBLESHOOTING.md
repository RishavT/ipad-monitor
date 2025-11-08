# Deskreen iPad Black Screen Troubleshooting

## Problem: Black screen on iPad after connecting to Deskreen

### Most Common Causes & Fixes:

#### 1. Full Screen Sharing (MOST LIKELY CAUSE)
**Problem**: Sharing the entire desktop shows black screen
**Solution**: Share individual application windows instead

**Steps:**
1. In Deskreen, when prompted "What would you like to share?"
2. Select "Application Window" instead of "Entire Screen"
3. Choose a specific application (e.g., Firefox, Terminal, etc.)
4. The selected window should now appear on iPad

#### 2. Browser Compatibility
**Problem**: Safari on iPad may not render Deskreen properly
**Solution**: Try different browsers

**Steps:**
1. Install Chrome or Edge on your iPad
2. Open the Deskreen URL in Chrome/Edge instead of Safari
3. Try connecting again

#### 3. Screen Permissions on Linux
**Problem**: i3 WM may need explicit screen sharing permissions
**Solution**: Grant screen capture permissions

**Steps:**
```bash
# Check if you can capture screen
xdpyinfo | grep dimensions

# If Deskreen can't capture, try running with:
ELECTRON_OZONE_PLATFORM_HINT=auto ./deskreen.AppImage
```

#### 4. iPad iOS Version
**Problem**: Very old iPads (iOS 9 or earlier) have compatibility issues
**Solution**: Update iPad or use newer device

**Check your iOS version:**
- Settings → General → About → Software Version
- iOS 13+ recommended
- iOS 9 or earlier known to have issues

### Step-by-Step Debug Process:

1. **Verify Connection:**
   - Does Deskreen show the iPad as connected?
   - Can you see the connection in Deskreen's UI?

2. **Test with Different Content:**
   ```
   First try: Share a single application window (e.g., Terminal)
   If that works: Try other windows
   Last resort: Try entire screen (often doesn't work)
   ```

3. **Check Network:**
   ```bash
   # Verify iPad can reach the laptop
   # On iPad in Safari, go to: http://<your-laptop-ip>:3131
   # You should see the Deskreen connection page
   ```

4. **Check Firewall:**
   ```bash
   # Verify port 3131 is open
   sudo firewall-cmd --list-ports
   # Should show: 3131/tcp
   ```

### Known Working Configuration:

- **Linux**: X11 (not Wayland) ✓
- **Share mode**: Individual application windows ✓
- **iPad browser**: Chrome or Firefox (not Safari)
- **iPad iOS**: 13+ recommended
- **Network**: Same WiFi network

### Still Not Working?

Try these alternatives:

#### Alternative 1: Use VNC instead
```bash
# Install x11vnc
sudo pacman -S x11vnc

# Start VNC server
x11vnc -display :0 -auth ~/.Xauthority

# On iPad, use VNC Viewer app
# Connect to: <laptop-ip>:5900
```

#### Alternative 2: Use spacedesk (Windows/Linux)
- More reliable for full screen sharing
- Available for iPad

#### Alternative 3: Use weylus
```bash
# Weylus is specifically designed for tablets as second monitors
# Check: https://github.com/H-M-H/Weylus
```

### Reporting Issues:

If none of these work, gather this info:
- iPad model and iOS version
- Browser used on iPad
- What you selected to share in Deskreen
- Whether iPad shows connected in Deskreen
- Any error messages

Report at: https://github.com/pavlobu/deskreen/issues
