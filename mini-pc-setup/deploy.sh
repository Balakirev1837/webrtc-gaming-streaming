#!/bin/bash
# deploy.sh - Deploy Broadcast Box and streaming service

set -e

USERNAME=${USER}
PROJECT_DIR="/home/$USERNAME/broadcast-box"
STREAM_DIR="/home/$USERNAME/streaming"

echo "=== Deploying Streaming Services ==="
echo "User: $USERNAME"
echo

# Clone and build Broadcast Box
echo "[1/6] Cloning and building Broadcast Box..."
if [ ! -d "$PROJECT_DIR" ]; then
    git clone https://github.com/Glimesh/broadcast-box.git "$PROJECT_DIR"
    cd "$PROJECT_DIR/web"
    npm install
    npm run build
    cd ..
    go build -o broadcast-box
else
    echo "Broadcast Box already exists, skipping..."
fi

# Create streaming directory
echo "[2/6] Creating streaming directory..."
mkdir -p "$STREAM_DIR"

# Copy configuration
echo "[3/6] Copying configuration..."
cp configs/.env.production "$PROJECT_DIR/.env.production"

# Copy all streaming scripts
echo "[4/6] Copying streaming scripts..."
cp scripts/stream*.sh "$STREAM_DIR/"
chmod +x "$STREAM_DIR"/*.sh
echo "  Copied AV1 and H.264 streaming scripts"

# Copy systemd services
echo "[5/6] Installing systemd services..."
sudo cp configs/broadcast-box.service /etc/systemd/system/
sudo cp configs/optiplex-stream.service /etc/systemd/system/
sudo cp configs/gaming-stream-av1.service /etc/systemd/system/
sudo systemctl daemon-reload

echo "[6/6] Setup complete!"

echo
echo "=== Deployment Complete ==="
echo
echo "To start services:"
echo "  sudo systemctl start broadcast-box"
echo
echo "For OptiPlex (recommended):"
echo "  sudo systemctl start optiplex-stream"
echo
echo "For general AV1 streaming:"
echo "  sudo systemctl start gaming-stream-av1"
echo
echo "To enable at boot:"
echo "  sudo systemctl enable broadcast-box"
echo "  sudo systemctl enable optiplex-stream"
echo
echo "To check status:"
echo "  sudo systemctl status broadcast-box"
echo "  sudo systemctl status optiplex-stream"
echo
