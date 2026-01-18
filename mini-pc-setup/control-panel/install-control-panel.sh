#!/bin/bash
# install-control-panel.sh - Install and configure the web control panel

set -e

echo "=== Installing Web Control Panel ==="
echo

# Install Python dependencies
echo "[1/4] Installing Python and Flask..."
sudo dnf install -y python3 python3-pip python3-devel
pip3 install --user flask psutil requests

# Copy control panel to home directory
echo "[2/4] Installing control panel files..."
CONTROL_DIR="$HOME/streaming/control-panel"
mkdir -p "$CONTROL_DIR/templates"

# Copy files (these would be in mini-pc-setup/control-panel)
cp stream-control.py "$CONTROL_DIR/"
cp templates/control_panel.html "$CONTROL_DIR/templates/"

# Create systemd service
echo "[3/4] Creating systemd service..."
sudo tee /etc/systemd/system/stream-control.service > /dev/null <<EOF
[Unit]
Description=Stream Control Panel
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$CONTROL_DIR
Environment="PATH=$HOME/.local/bin:$PATH"
ExecStart=$HOME/.local/bin/python3 $CONTROL_DIR/stream-control.py
Restart=always
RestartSec=5

NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload

# Start service
echo "[4/4] Starting control panel..."
sudo systemctl enable --now stream-control

# Wait a moment for service to start
sleep 2

# Check status
if systemctl is-active --quiet stream-control; then
    echo
    echo "✅ Control panel installed successfully!"
    echo
    echo "Access the control panel at:"
    echo "  http://$(hostname -I | awk '{print $1}'):8081"
    echo "  or http://$(hostname).local:8081"
    echo
    echo "Features:"
    echo "  - Select streaming script (AV1/H.264)"
    echo "  - Adjust bitrate, resolution, FPS"
    echo "  - Start/stop/restart stream"
    echo "  - Monitor system stats (CPU, GPU, memory)"
    echo "  - Get stream URL for viewers"
    echo
    echo "Logs:"
    echo "  sudo journalctl -u stream-control -f"
else
    echo
    echo "❌ Failed to start control panel"
    echo "Check logs: sudo journalctl -u stream-control -n 50"
    exit 1
fi
