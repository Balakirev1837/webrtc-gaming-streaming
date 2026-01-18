#!/bin/bash
# setup-mini-pc.sh - One-time setup for mini PC streaming server

set -e

echo "=== Mini PC Streaming Server Setup ==="
echo

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (sudo ./setup-mini-pc.sh)"
    exit 1
fi

# System update
echo "[1/6] Updating system..."
dnf update -y

# Install base development tools
echo "[2/6] Installing development tools..."
dnf install -y git gcc gcc-c++ make pkg-config
dnf install -y golang nodejs npm

# Install GStreamer and plugins (including AV1 support)
echo "[3/6] Installing GStreamer and plugins..."
dnf install -y gstreamer1 gstreamer1-plugins-base gstreamer1-plugins-good
dnf install -y gstreamer1-plugins-bad-free gstreamer1-plugins-bad-nonfree
dnf install -y gstreamer1-plugins-ugly gstreamer1-libav
dnf install -y gstreamer1-vaapi gstreamer1-plugins-good-extras

# Install AV1 encoding support
echo "[3.5/6] Installing AV1 encoding plugins..."
dnf install -y gstreamer1-plugins-bad-free-extras  # Contains AV1 encoders
dnf install -y libavcodec-free  # For AV1 codec support
dnf install -y svt-av1-tools  # SVT-AV1 encoder (fastest software)
dnf install -y rav1e  # RAV1E encoder

# Install video capture and media tools
echo "[4/6] Installing video capture tools..."
dnf install -y v4l-utils ffmpeg
dnf install -y libva libva-utils intel-media-driver mesa-va-drivers

# Install Docker
echo "[5/6] Installing Docker..."
dnf install -y docker docker-compose
systemctl enable --now docker

# Add user to video and docker groups
echo "[6/6] Setting up permissions..."
read -p "Enter username for streaming service: " USERNAME

if id "$USERNAME" &>/dev/null; then
    usermod -a -G video,docker "$USERNAME"
    echo "Added $USERNAME to video and docker groups"
else
    echo "Error: User $USERNAME not found"
    exit 1
fi

echo
echo "=== Setup Complete ==="
echo "Please logout and login again for group changes to take effect"
echo
echo "Next steps:"
echo "  1. Reboot: sudo reboot"
echo "  2. Clone the project: git clone <your-repo>"
echo "  3. Run: cd mini-pc-setup && ./deploy.sh"
