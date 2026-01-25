# Deployment Guide

Quick guide for deploying this streaming solution to your mini PC via Git.

> **Note:** We now recommend the **Docker Deployment** method for better stability and easier setup. See [DOCKER_DEPLOYMENT.md](DOCKER_DEPLOYMENT.md).

## 🚀 Quick Deployment (5 Minutes)

### Option 1: Docker (Recommended)
See [DOCKER_DEPLOYMENT.md](DOCKER_DEPLOYMENT.md) for the full guide.
1. Clone the repo.
2. Run `docker compose up -d --build` inside `docker-deployment/`.

### Option 2: Manual (Legacy)
Follow the steps below to deploy manually via scripts.

```bash
# 1. Clone the repository
git clone https://github.com/Balakirev1837/webrtc-gaming-streaming.git
cd webrtc-gaming-streaming

# 2. Copy to mini PC (replace with your mini PC details)
scp -r mini-pc-setup user@mini-pc-ip:~/

# 3. SSH into mini PC
ssh user@mini-pc-ip

# 4. Run setup (installs all dependencies)
cd ~/mini-pc-setup
sudo ./setup-mini-pc.sh
sudo reboot

# 5. After reboot, deploy services
./deploy.sh

# 6. Start streaming (OptiPlex optimized)
sudo systemctl start broadcast-box
sudo systemctl start optiplex-stream

# 7. Access stream
# Open: http://mini-pc-ip:8080/gaming
# Control panel: http://mini-pc-ip:8081
```

That's it! Your stream is ready. Viewers just need to bookmark the URL.

---

## 📋 Pre-Deployment Checklist

### Hardware
- [ ] Mini PC (Intel 4th gen+ or AMD Ryzen 3+)
- [ ] Capture card (USB 3.0 HDMI)
- [ ] Gigabit Ethernet connection
- [ ] HDMI splitter (if gaming PC has only one HDMI out)
- [ ] All cables (HDMI, USB 3.0, Ethernet)

### Software
- [ ] Mini PC has Fedora 38+ or Ubuntu 22.04+
- [ ] User account created on mini PC
- [ ] SSH access configured
- [ ] Network switch/router available (if using multiple devices)

---

## 🎯 Deployment Options

### Option A: OptiPlex 7070-570X4 (Recommended)

**For:** Any resolution gaming + OptiPlex mini PC

**Configuration:**
- Capture: At your native gaming resolution (e.g., 1440p@144Hz)
- Output: 720p@60fps (direct downscale from capture)
- Codec: AV1 (SVT-AV1)
- CPU: 45-60% ✅ Sustainable
- Bitrate: 4000 Kbps

**Setup:**
```bash
# After running setup-mini-pc.sh and deploy.sh
sudo systemctl start broadcast-box
sudo systemctl start optiplex-stream
```

**Verification:**
```bash
# Check service status
sudo systemctl status broadcast-box
sudo systemctl status optiplex-stream

# Check logs
sudo journalctl -u optiplex-stream -f

# Access control panel
# Open: http://mini-pc-ip:8081
```

### Option B: Higher-End Mini PC (6+ cores)

**For:** Maximum quality viewing

**Configuration:**
- Capture: At your native gaming resolution (e.g., 1080p@60Hz or 1440p@144Hz)
- Output: 1080p@60fps
- Codec: AV1 (software or hardware)
- CPU: 70-80% (software) or 15-25% (hardware)
- Bitrate: 6000-8000 Kbps

**Setup:**
```bash
cd ~/mini-pc-setup
sudo ./setup-mini-pc.sh
sudo reboot

# After reboot
./deploy.sh
sudo systemctl start broadcast-box
sudo systemctl start vp9-stream      # VP9 default (30-40% CPU)
# Or: sudo systemctl start optiplex-stream  # AV1 alternative (45-60% CPU)
```

### Option C: Hardware-Accelerated (NVENC/VA-API)

**For:** Mini PCs with RTX 40-series or Intel Arc/AMD RDNA3

**Setup:**
```bash
# Select script in control panel or manually
# stream-av1-nvenc.sh for NVIDIA RTX 40-series
# stream-av1-vaapi.sh for Intel Arc/AMD RDNA3

sudo systemctl start broadcast-box
sudo systemctl start gaming-stream-av1
```

---

## 📁 What Gets Deployed

### Scripts Deployed
- `stream-av1-optiplex.sh` - OptiPlex-optimized 720p@60fps
- `stream-1080p-downscale.sh` - 1440p→1080p downscale
- `stream-av1-svt.sh` - General AV1 1080p@60fps
- `stream-av1-nvenc.sh` - NVENC hardware AV1
- `stream-av1-vaapi.sh` - VA-API hardware AV1
- `stream-av1.sh` - RAV1E software AV1
- `stream.sh` - H.264 VA-API fallback
- `stream-nvenc.sh` - H.264 NVENC fallback

### Services Installed
- `broadcast-box.service` - WebRTC server
- `optiplex-stream.service` - OptiPlex AV1 stream (720p)
- `gaming-stream-av1.service` - General AV1 stream (1080p)
- `gaming-stream.service` - H.264 fallback stream

### Directories Created
- `~/broadcast-box/` - Broadcast Box server (cloned during deploy)
- `~/streaming/` - Streaming scripts and configs
- `~/streaming/config/` - Stream configuration files

---

## 🧪 Troubleshooting Deployment

### Issue: Permission denied on setup script
```bash
# Make script executable
chmod +x setup-mini-pc.sh
sudo ./setup-mini-pc.sh
```

### Issue: Script not found after git clone
```bash
# Check you're in the right directory
ls -la

# Make sure you cloned with mini-pc-setup directory
ls mini-pc-setup/
```

### Issue: Services won't start
```bash
# Check status
sudo systemctl status broadcast-box optiplex-stream

# Check logs
sudo journalctl -u broadcast-box -n 50
sudo journalctl -u optiplex-stream -n 50

# Check for missing dependencies
gst-inspect-1.0 svtav1enc
```

### Issue: Can't access from other devices
```bash
# Open firewall ports
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-port=8080/udp
sudo firewall-cmd --permanent --add-port=8081/tcp
sudo firewall-cmd --reload

# Verify
sudo firewall-cmd --list-all
```

---

## 📊 Post-Deployment Verification

### Services Running
```bash
# All services should show "active"
sudo systemctl status broadcast-box
sudo systemctl status optiplex-stream
```

### Capture Card Detected
```bash
# Should show /dev/video0
ls -l /dev/video*
v4l2-ctl --list-devices
```

### Stream Accessible
```bash
# From another device
curl http://mini-pc-ip:8080/api/status

# Should return: {"streaming":true/false,"broadcast_box":true}
```

### Control Panel Working
```bash
# Open browser
http://mini-pc-ip:8081

# Should show control panel with system stats
```

### Viewer Page Working
```bash
# Open browser
http://mini-pc-ip:8080/gaming

# Should show viewer page with video
```

---

## 📝 Updating from Git

To get updates to the streaming solution:

```bash
# On mini PC
cd ~/mini-pc-setup
git pull origin main

# Or re-clone from main machine
git pull
scp -r mini-pc-setup user@mini-pc-ip:~/
```

---

## 🎬 Starting Streaming

### Option 1: Using Control Panel (Recommended)
1. Open `http://mini-pc-ip:8081`
2. Select streaming script (default: "AV1 (OptiPlex - 1440p→720p)")
3. Adjust settings if needed (bitrate, resolution, FPS)
4. Click "Start Stream" or "Toggle Stream" button
5. Share stream URL with viewers: `http://mini-pc-ip:8080/gaming`

### Option 2: Using Systemd Services
```bash
sudo systemctl start optiplex-stream
sudo systemctl enable optiplex-stream  # Auto-start at boot
```

### Option 3: Manual
```bash
cd ~/streaming
./stream-av1-optiplex.sh
```

---

## 🔧 Configuration

### Environment Variables

Edit systemd service files or set in shell:
```bash
STREAM_KEY=gaming
SERVER_URL=http://localhost:8080/api/whip
VIDEO_DEVICE=/dev/video0
RESOLUTION=1280x720  # For OptiPlex
BITRATE=4000          # For OptiPlex
```

### Common Adjustments

**Lower CPU usage:**
```bash
# In optiplex-stream.service
Environment="BITRATE=3000"
```

**Higher quality:**
```bash
Environment="BITRATE=5000"
```

**Different resolution:**
```bash
Environment="RESOLUTION=1920x1080"  # For high-end PC
```

---

## 📚 Additional Documentation

- [Hardware Checklist](mini-pc-setup/docs/HARDWARE_CHECKLIST.md) - Complete hardware requirements
- [Setup Guide](mini-pc-setup/docs/SETUP_GUIDE.md) - Detailed setup instructions
- [OptiPlex Guide](mini-pc-setup/docs/OPTIPLEX_GUIDE.md) - OptiPlex-specific tuning
- [AV1 Guide](mini-pc-setup/docs/AV1_GUIDE.md) - AV1 codec details
- [Quick Reference](mini-pc-setup/docs/QUICK_REFERENCE.md) - Common commands

---

## 💡 Tips

1. **Test capture first** - Run `test-capture.sh` before starting stream
2. **Monitor CPU** - Use control panel or `htop` to watch CPU usage
3. **Optimize** - Run `optimize-streaming-pc.sh` for better performance
4. **Bookmark** - Have viewers bookmark the URL for easy access
5. **Control panel** - Use web panel instead of SSH for day-to-day management

---

## 🆘 Support

- **Documentation:** See guides in `mini-pc-setup/docs/`
- **Broadcast Box Discord:** https://discord.gg/An5jjhNUE3
- **GitHub Issues:** https://github.com/Balakirev1837/webrtc-gaming-streaming/issues

---

**🚀 Deployed! Your streaming solution is ready to use.**
