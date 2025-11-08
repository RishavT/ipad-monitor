#!/bin/bash

# Toggle Virtual Monitor Script
# Adds or removes a virtual second monitor for use with iPad

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/.virtual-display-config"

# Configuration
VIRTUAL_OUTPUT="HDMI-A-0"  # Change this if your disconnected output is different
VIRTUAL_RESOLUTION="1920x1080"
VIRTUAL_POSITION="right-of"  # Options: right-of, left-of, above, below
REFRESH_RATE="60"

# Parse resolution
WIDTH=$(echo $VIRTUAL_RESOLUTION | cut -d'x' -f1)
HEIGHT=$(echo $VIRTUAL_RESOLUTION | cut -d'x' -f2)

# Deskreen configuration
DESKREEN_DIR="$HOME/.config/ipad_monitor"
DESKREEN_PATH="$DESKREEN_DIR/deskreen.AppImage"
DESKREEN_URL="https://github.com/pavlobu/deskreen/releases/download/v2.0.4/Deskreen-2.0.4.AppImage"

# Function to check and download Deskreen
check_deskreen() {
    if [ ! -f "$DESKREEN_PATH" ]; then
        echo ""
        echo "Deskreen not found at: $DESKREEN_PATH"
        echo ""
        read -p "Download Deskreen now? (y/n): " -n 1 -r
        echo ""

        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Downloading Deskreen..."
            mkdir -p "$DESKREEN_DIR"

            if command -v curl &> /dev/null; then
                curl -L "$DESKREEN_URL" -o "$DESKREEN_PATH"
            elif command -v wget &> /dev/null; then
                wget "$DESKREEN_URL" -O "$DESKREEN_PATH"
            else
                echo "Error: Neither curl nor wget found. Please install one to download Deskreen."
                echo "Or download manually from: https://github.com/pavlobu/deskreen/releases"
                return 1
            fi

            chmod +x "$DESKREEN_PATH"
            echo "✓ Deskreen downloaded successfully!"
            echo ""
        else
            echo "You can download Deskreen manually from:"
            echo "https://github.com/pavlobu/deskreen/releases"
            echo "Save it to: $DESKREEN_PATH"
            echo ""
        fi
    fi
}

echo "========================================="
echo "Virtual Monitor Toggle"
echo "========================================="

# Check for Deskreen
check_deskreen

# Check if running X11
if [ "$XDG_SESSION_TYPE" != "x11" ]; then
    echo "Error: This script requires X11 (not Wayland)"
    echo "Current session type: $XDG_SESSION_TYPE"
    exit 1
fi

# Check if xrandr is available
if ! command -v xrandr &> /dev/null; then
    echo "Error: xrandr not found. Install: sudo pacman -S xorg-xrandr"
    exit 1
fi

# Get primary display
PRIMARY_DISPLAY=$(xrandr --query | grep " connected primary" | cut -d" " -f1)
if [ -z "$PRIMARY_DISPLAY" ]; then
    PRIMARY_DISPLAY=$(xrandr --query | grep " connected" | head -n1 | cut -d" " -f1)
fi

# Check if virtual monitor is currently active
# Virtual monitors show as "disconnected" but with resolution like "1920x1080+1920+0"
if [ -f "$CONFIG_FILE" ] && xrandr --query | grep "^$VIRTUAL_OUTPUT" | grep -q "[0-9]x[0-9]"; then
    # Virtual monitor is active - remove it
    echo "Virtual monitor is currently ACTIVE"
    echo "Removing virtual monitor..."
    echo ""

    source "$CONFIG_FILE"

    # Disable the output
    xrandr --output $VIRTUAL_OUTPUT --off

    # Try to remove the mode
    xrandr --delmode $VIRTUAL_OUTPUT $MODE_NAME 2>/dev/null || true
    xrandr --rmmode $MODE_NAME 2>/dev/null || true

    # Remove config file
    rm -f "$CONFIG_FILE"

    echo "✓ Virtual monitor removed"
    echo ""
    echo "Current displays:"
    xrandr --query | grep -E "^(eDP|HDMI-A-0|DisplayPort)" | head -5

else
    # Virtual monitor is not active - add it
    echo "Virtual monitor is currently INACTIVE"
    echo "Adding virtual monitor..."
    echo ""

    # Check if the output exists
    if ! xrandr --query | grep -q "^$VIRTUAL_OUTPUT"; then
        echo "Error: Output $VIRTUAL_OUTPUT not found"
        echo ""
        echo "Available outputs:"
        xrandr --query | grep -E "^[A-Z]" | cut -d' ' -f1
        echo ""
        echo "Update VIRTUAL_OUTPUT in this script to match your disconnected output"
        exit 1
    fi

    # Generate modeline
    MODELINE=$(cvt $WIDTH $HEIGHT $REFRESH_RATE | grep "Modeline")
    MODE_PARAMS=$(echo "$MODELINE" | sed 's/.*Modeline //')
    MODE_NAME=$(echo "$MODE_PARAMS" | cut -d' ' -f1 | tr -d '"')

    echo "Settings:"
    echo "  Output: $VIRTUAL_OUTPUT"
    echo "  Resolution: ${WIDTH}x${HEIGHT}@${REFRESH_RATE}Hz"
    echo "  Position: $VIRTUAL_POSITION $PRIMARY_DISPLAY"
    echo "  Mode: $MODE_NAME"
    echo ""

    # Clean up mode from this output if it was previously associated
    xrandr --delmode $VIRTUAL_OUTPUT $MODE_NAME 2>/dev/null || true

    # Always try to create the mode (ignore error if it truly already exists)
    echo "Creating mode..."
    if eval "xrandr --newmode $MODE_PARAMS" 2>/dev/null; then
        echo "  Created new mode: $MODE_NAME"
    else
        echo "  Mode already exists, reusing it"
    fi

    # Add mode to output
    echo "Adding mode to output..."
    xrandr --addmode $VIRTUAL_OUTPUT $MODE_NAME

    # Enable the virtual display
    echo "Enabling virtual display..."
    case $VIRTUAL_POSITION in
        right-of)
            xrandr --output $VIRTUAL_OUTPUT --mode $MODE_NAME --right-of $PRIMARY_DISPLAY
            ;;
        left-of)
            xrandr --output $VIRTUAL_OUTPUT --mode $MODE_NAME --left-of $PRIMARY_DISPLAY
            ;;
        above)
            xrandr --output $VIRTUAL_OUTPUT --mode $MODE_NAME --above $PRIMARY_DISPLAY
            ;;
        below)
            xrandr --output $VIRTUAL_OUTPUT --mode $MODE_NAME --below $PRIMARY_DISPLAY
            ;;
        *)
            xrandr --output $VIRTUAL_OUTPUT --mode $MODE_NAME --right-of $PRIMARY_DISPLAY
            ;;
    esac

    # Save configuration
    cat > "$CONFIG_FILE" <<EOF
VIRTUAL_OUTPUT=$VIRTUAL_OUTPUT
MODE_NAME=$MODE_NAME
PRIMARY_DISPLAY=$PRIMARY_DISPLAY
EOF

    echo ""
    echo "✓ Virtual monitor added successfully!"
    echo ""
    echo "Current displays:"
    xrandr --query | grep -E "^(eDP|HDMI-A-0|DisplayPort)" | head -5
    echo ""
    echo "Usage with i3:"
    echo "  - Move window: \$mod+Shift+Right/Left/Up/Down"
    echo "  - Focus display: \$mod+Right/Left/Up/Down"
    echo ""
    echo "Usage with Deskreen:"
    echo "  1. Run: $DESKREEN_PATH"
    echo "  2. Select the virtual display ($VIRTUAL_OUTPUT) to share"
    echo "  3. Connect from iPad browser"
    echo ""
    echo "To remove: ./toggle-monitor.sh (run again)"
    echo ""

    # Offer to start Deskreen
    if [ -f "$DESKREEN_PATH" ]; then
        read -p "Start Deskreen now? (y/n): " -n 1 -r
        echo ""
        echo ""

        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Starting Deskreen..."
            nohup "$DESKREEN_PATH" > /dev/null 2>&1 &
            disown
            echo "✓ Deskreen started in background"
            echo ""
        fi
    fi
fi

echo "========================================="
