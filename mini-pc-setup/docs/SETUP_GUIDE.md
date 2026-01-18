# Mini PC Setup Guide

Step-by-step guide to set up your mini PC as a dedicated WebRTC streaming server.

## Phase 1: Hardware Setup

### 1.1 Physical Connections

1. Connect gaming PC HDMI out to HDMI splitter input
2. Connect HDMI splitter output 1 to gaming monitor
3. Connect HDMI splitter output 2 to capture card HDMI input
4. Connect capture card USB 3.0 to mini PC USB 3.0 port
5. Connect mini PC Ethernet to network switch/router
6. Power on all devices

### 1.2 Verify Connections

```bash
# On mini PC, check if capture card is detected
ls -l /dev/video*

# Should see /dev/video0, /dev/video1, etc.
```

## Phase 2: Operating System

### 2.1 Install Fedora (Recommended)

1. Download Fedora Workstation 38+ from https://fedoraproject.org/
2. Create bootable USB: `sudo dd if=Fedora.iso of=/dev/sdX bs=4M`
3. Boot from USB and install Fedora
4. During setup, create user account (e.g., "streamer")

### 2.2 Update System

```bash
sudo dnf update -y
sudo reboot
```

## Phase 3: Software Installation

### 3.1 Run Setup Script

```bash
# Transfer mini-pc-setup directory to mini PC
# Option 1: SCP
scp -r mini-pc-setup streamer@mini-pc-ip:/home/streamer/

# Option 2: USB drive
# Copy to USB, transfer to mini PC, extract

# SSH into mini PC
ssh streamer@mini-pc-ip
cd mini-pc-setup

# Run setup (requires sudo)
sudo ./setup-mini-pc.sh
```

The setup script will:
- Update system packages
- Install development tools (Go, Node.js, npm)
- Install GStreamer and plugins
- Install video capture tools
- Install Docker and Docker Compose
- Configure user permissions

### 3.2 Reboot

```bash
sudo reboot
```

After reboot, login again.

## Phase 4: Test Hardware

### 4.1 Test Capture Card

```bash
cd ~/mini-pc-setup/scripts
chmod +x test-capture.sh
./test-capture.sh
```

You should see video from your gaming PC for 10 seconds.

### 4.2 Test Audio

```bash
chmod +x test-audio.sh
./test-audio.sh
```

Follow the prompts to select your audio device.

### 4.3 Verify GPU Encoding

**For VA-API (Intel/AMD):**
```bash
vainfo
```

**For NVENC (NVIDIA):**
```bash
nvidia-smi --query-gpu=encoder.version.info.purevid,encoder.version.info.fw --format=csv
```

## Phase 5: Deploy Services

### 5.1 Run Deploy Script

```bash
cd ~/mini-pc-setup
./deploy.sh
```

This will:
- Clone and build Broadcast Box
- Copy configuration files
- Install systemd services

### 5.2 Configure Static IP (Optional but Recommended)

```bash
sudo nmcli connection modify "Wired connection 1" \
  ipv4.addresses 192.168.1.100/24 \
  ipv4.gateway 192.168.1.1 \
  ipv4.method manual
```

Replace IP addresses with your network configuration.

### 5.3 Configure Firewall

```bash
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-port=8080/udp
sudo firewall-cmd --reload
```

## Phase 6: Start Services

### 6.1 Manual Start (For Testing)

```bash
# Terminal 1: Start Broadcast Box
cd ~/broadcast-box
./broadcast-box

# Terminal 2: Start stream
cd ~/streaming
./stream.sh
```

### 6.2 Systemd Start (For Production)

```bash
# Start services
sudo systemctl start broadcast-box
sudo systemctl start gaming-stream

# Enable at boot
sudo systemctl enable broadcast-box
sudo systemctl enable gaming-stream

# Check status
sudo systemctl status broadcast-box
sudo systemctl status gaming-stream
```

## Phase 7: Verify Streaming

### 7.1 From Another Device

On a different device (laptop, phone, etc.) on the same network:

1. Open web browser
2. Navigate to: `http://192.168.1.100:8080/gaming`
   - Replace IP with your mini PC's IP
3. Stream should start automatically

### 7.2 Check Status

```bash
curl http://localhost:8080/api/status
```

Should show active stream information.

## Phase 8: Optimization

### 8.1 Monitor Performance

```bash
# CPU/GPU usage
htop

# Network usage
iftop

# Broadcast Box logs
journalctl -u broadcast-box -f

# Stream logs
journalctl -u gaming-stream -f
```

### 8.2 Adjust Settings

Edit `~/streaming/stream.sh`:

**For best quality:**
```bash
target-bitrate=10000
keyframe-period=120
quality-level=7
tune=hq
```

**For lower latency:**
```bash
target-bitrate=6000
keyframe-period=60
quality-level=4
tune=ll
```

Restart service after changes:
```bash
sudo systemctl restart gaming-stream
```

## Phase 9: Optional Enhancements

### 9.1 mDNS/Avahi (for hostname.local access)

```bash
sudo dnf install avahi
sudo systemctl enable --now avahi-daemon
```

Now access: `http://streamer.local:8080/gaming`

### 9.2 Recording

Edit stream script to add recording:
```bash
tee name=t ! queue ! rtph264pay ! ... ! whipsink
t. ! queue ! filesink location=recording.h264
```

### 9.3 Web Authentication

Create webhook server to validate stream keys.

## Troubleshooting

### Services Won't Start

```bash
# Check logs
sudo journalctl -u broadcast-box -n 50
sudo journalctl -u gaming-stream -n 50

# Common issues:
# - User not in video group: sudo usermod -a -G video $USER
# - Port in use: sudo lsof -i :8080
# - Missing dependencies: Run setup-mini-pc.sh again
```

### No Video

```bash
# Check capture card
v4l2-ctl --list-devices

# Test capture directly
ffplay -f v4l2 -framerate 60 -video_size 1920x1080 -i /dev/video0
```

### No Audio

```bash
# List audio devices
pactl list sources short

# Test audio
gst-launch-1.0 pulsesrc ! audioconvert ! autoaudiosink
```

### Viewers Can't Connect

```bash
# Check firewall
sudo firewall-cmd --list-all

# Test from viewer machine
curl http://192.168.1.100:8080/api/status

# Check network connectivity
ping 192.168.1.100
```

## Final Checklist

- [ ] Capture card detected and working
- [ ] Audio capture working
- [ ] Broadcast Box running
- [ ] Stream service running
- [ ] Viewers can connect from other devices
- [ ] Latency acceptable (< 500ms for best quality)
- [ ] Quality acceptable
- [ ] Services start at boot
- [ ] Static IP configured (optional)
- [ ] Firewall configured

## Success!

Your mini PC is now configured as a dedicated WebRTC streaming server. Viewers on your local network can access your gaming stream at:

```
http://<mini-pc-ip>:8080/gaming
```

or with mDNS:

```
http://<hostname>.local:8080/gaming
```
