# Deployment Guide

Complete guide for deploying your WebRTC gaming streaming setup, suitable for sharing with friends.

## 🎯 Overview

This project provides a complete solution for:
- **Gamers:** Stream to local viewers with sub-second latency
- **Families:** Watch family members play like a remote second monitor
- **Friends:** Deploy low-cost streaming servers for local LAN parties

## 📋 Quick Hardware Checklist

### What You Need

**Minimum Configuration (~$170)**
- Mini PC: Intel N100 or similar (4+ cores)
- Capture card: Generic USB 3.0 HDMI capture ($30-50)
- Network: Gigabit Ethernet
- Cables: HDMI + USB 3.0

**Recommended Configuration (~$440)**
- Mini PC: Intel i5-6500T or AMD Ryzen 5 (6+ cores, 8GB RAM)
- Capture card: Elgato Cam Link 4K or Magewell ($130-150)
- Network: Gigabit Ethernet
- Cables: High-quality HDMI 2.1 + USB 3.0

**Premium Configuration (~$700)**
- Mini PC: Intel i7-12700T or AMD Ryzen 7 with GPU (8+ cores, 16GB RAM)
- Capture card: Magewell USB Capture HDMI 4K ($150-250)
- Network: Gigabit Ethernet + switch
- Cables: Premium HDMI 2.1 + USB 3.0 + Cat6

### Compatibility

**CPU Requirements:**
- ✅ Intel Core i3/i5/i7 (4th gen and newer)
- ✅ AMD Ryzen 3/5/7 (all generations)
- ✅ Intel Pentium Gold (8th gen+ with AVX2)
- ❌ Intel Core 2 Duo, AMD Athlon X2 (too old)
- ❌ ARM CPUs (not fully supported)

**Capture Card Requirements:**
- ✅ USB 3.0 (required for 1080p@60fps)
- ✅ Linux driver support (check before buying)
- ❌ USB 2.0 (insufficient bandwidth)

**OS Requirements:**
- ✅ Fedora 38+
- ✅ Ubuntu 22.04+
- ✅ Debian 12+
- ❌ Windows (limited V4L2 support)
- ❌ macOS (different architecture)

**Full Details:** [Hardware Checklist](mini-pc-setup/docs/HARDWARE_CHECKLIST.md)

## 🚀 Deployment Steps

### Step 1: Hardware Setup (30-60 minutes)

1. **Connect HDMI cables**
   - Gaming PC HDMI out → HDMI splitter input
   - HDMI splitter output 1 → Gaming monitor
   - HDMI splitter output 2 → Capture card HDMI in

2. **Connect capture card**
   - Capture card USB out → Mini PC USB 3.0 port
   - Verify capture card has power (LED on)

3. **Connect network**
   - Mini PC Ethernet → Network switch/router
   - Gaming PC Ethernet → Network switch/router (if not already)
   - Verify all devices on same network

4. **Power on devices**
   - Start mini PC
   - Start gaming PC
   - Verify capture card detected: `ls /dev/video*`

### Step 2: Install OS (1-2 hours)

If mini PC doesn't have Linux installed:

**Fedora (Recommended):**
```bash
# Download Fedora 38+ from https://fedoraproject.org/
# Create bootable USB: sudo dd if=Fedora.iso of=/dev/sdX bs=4M
# Boot from USB and install
# Create user account: streamer
```

**Ubuntu (Alternative):**
```bash
# Download Ubuntu 22.04+ from https://ubuntu.com/
# Create bootable USB: sudo dd if=Ubuntu.iso of=/dev/sdX bs=4M
# Boot from USB and install
# Create user account: streamer
```

### Step 3: Copy Setup Files (5-10 minutes)

**Option A: Network Copy (If mini PC has network access)**
```bash
# From your development machine
scp -r mini-pc-setup streamer@mini-pc-ip:/home/streamer/
```

**Option B: USB Transfer (If no network)**
```bash
# From your development machine
cp -r mini-pc-setup /media/USB_DRIVE/

# On mini PC (after plugging in USB)
cp -r /media/USB_DRIVE/mini-pc-setup ~/
```

**Option C: Direct Clone on Mini PC**
```bash
# On mini PC with network access
git clone <your-repo-url>
cd <project-directory>/mini-pc-setup
```

### Step 4: Run Setup Script (10-15 minutes)

```bash
cd ~/mini-pc-setup
chmod +x setup-mini-pc.sh
sudo ./setup-mini-pc.sh
```

**This script will:**
- Update system packages
- Install development tools (Go, Node.js, npm)
- Install GStreamer and plugins (including AV1 encoders)
- Install video capture tools
- Install video/audio libraries (VA-API, PipeWire)
- Install Docker (optional)
- Configure user permissions
- Provide next steps

### Step 5: Reboot (1-2 minutes)

```bash
sudo reboot
```

After reboot, login again.

### Step 6: Deploy Services (5-10 minutes)

```bash
cd ~/mini-pc-setup
./deploy.sh
```

**This script will:**
- Clone and build Broadcast Box
- Copy configuration files
- Install systemd services
- Provide next steps

### Step 7: Install Control Panel (5-10 minutes, Optional)

```bash
cd ~/mini-pc-setup/control-panel
chmod +x install-control-panel.sh
sudo ./install-control-panel.sh
```

**This will:**
- Install Python dependencies (Flask, psutil)
- Copy control panel files
- Create systemd service
- Start control panel automatically

**Access:** `http://mini-pc-ip:8081`

### Step 8: Apply CPU Optimizations (2-5 minutes, Recommended)

```bash
cd ~/mini-pc-setup
chmod +x optimize-streaming-pc.sh
sudo ./optimize-streaming-pc.sh
sudo reboot
```

**This will:**
- Set CPU governor to performance
- Disable unnecessary services
- Optimize kernel parameters
- Configure process priorities
- Save 15-25% CPU

### Step 9: Start Streaming (2-3 minutes)

```bash
# Option A: Using systemd services (OptiPlex recommended)
sudo systemctl start broadcast-box
sudo systemctl start optiplex-stream  # OptiPlex-optimized (720p@60fps)

# Option B: General AV1 streaming
sudo systemctl start broadcast-box
sudo systemctl start gaming-stream-av1  # General AV1 (1080p@60fps)

# Option C: Using control panel
# Open http://mini-pc-ip:8081
# Click "Start Stream"
```

### Step 10: Test Viewer Access (2-3 minutes)

**From another device on the same network:**

```bash
# Open browser
http://mini-pc-ip:8080/gaming

# Or with mDNS
http://mini-pc.local:8080/gaming
```

**Bookmark the viewer page for easy access!**

## ✅ Verification Checklist

### Hardware Verification

- [ ] Capture card visible: `ls /dev/video*` shows /dev/video0
- [ ] Capture card test passes: `~/mini-pc-setup/scripts/test-capture.sh`
- [ ] Audio capture works: `~/mini-pc-setup/scripts/test-audio.sh`
- [ ] Network connectivity: `ping mini-pc-ip` successful
- [ ] All devices on same subnet

### Software Verification

- [ ] GStreamer installed: `gst-inspect-1.0 | grep -E "(pipewire|av1|rtp)"`
- [ ] Broadcast Box built: `cd ~/broadcast-box && ./broadcast-box --version`
- [ ] Control panel accessible: `curl http://mini-pc-ip:8081`

### Streaming Verification

- [ ] Broadcast Box running: `sudo systemctl status broadcast-box` = active
- [ ] Stream service running:
  - OptiPlex: `sudo systemctl status optiplex-stream` = active
  - General: `sudo systemctl status gaming-stream-av1` = active
- [ ] CPU usage acceptable: <70% (software) or <30% (hardware)
- [ ] Viewer can connect: Open `http://mini-pc-ip:8080/gaming`
- [ ] Video and audio in sync
- [ ] Quality acceptable for resolution/bitrate

### Performance Verification

```bash
# Run CPU efficiency check
cd ~/mini-pc-setup/scripts
./verify-cpu-efficiency.sh

# Should show optimization score >80%
```

## 🌐 Network Configuration

### Static IP (Recommended for Mini PC)

```bash
# Get current interface
nmcli device status

# Set static IP
sudo nmcli connection modify "Wired connection 1" \
  ipv4.addresses 192.168.1.100/24 \
  ipv4.gateway 192.168.1.1 \
  ipv4.method manual
```

### Firewall Configuration

```bash
# Open ports
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-port=8080/udp
sudo firewall-cmd --permanent --add-port=8081/tcp
sudo firewall-cmd --reload

# Verify
sudo firewall-cmd --list-all
```

### mDNS (Optional, for hostname.local access)

```bash
sudo dnf install avahi
sudo systemctl enable --now avahi-daemon

# Test
ping mini-pc.local
```

## 🎯 Different Use Cases

### Use Case 1: Personal Gaming Stream

**Purpose:** You want to stream to 1-5 local viewers

**Configuration:**
- Mini PC: Recommended or Premium
- Encoding: AV1 hardware preferred
- Bitrate: 6000-8000 Kbps
- Quality: Balanced or High

**Viewer Experience:**
- URL: `http://mini-pc-ip:8080/gaming`
- Zero configuration
- Auto-reconnect on disconnect

### Use Case 2: Family Remote Monitor

**Purpose:** Family member watches what you're playing (like second monitor)

**Configuration:**
- Mini PC: Minimum or Recommended
- Encoding: AV1 software acceptable
- Bitrate: 4000-6000 Kbps
- Quality: Normal preset

**Viewer Experience:**
- URL: `http://mini-pc-ip:8080/gaming`
- Bookmarked, one-click access
- Simple picture controls (brightness, contrast)

### Use Case 3: LAN Party Stream

**Purpose:** Multiple friends watching same stream

**Configuration:**
- Mini PC: Premium
- Encoding: AV1 hardware
- Bitrate: 8000-10000 Kbps
- Quality: Ultra or High

**Viewer Experience:**
- All access same URL
- Supports 5-10 viewers on gigabit network
- Bandwidth: 8-12 Mbps per viewer

## 🔧 Troubleshooting

### Common Issues

**Issue: Capture card not detected**
```bash
# Check device
ls -l /dev/video*

# Check permissions
groups | grep video
# If not in video group: sudo usermod -a -G video $USER
# Re-login required
```

**Issue: Can't connect to stream**
```bash
# Check services
sudo systemctl status broadcast-box
sudo systemctl status gaming-stream-av1

# Check firewall
sudo firewall-cmd --list-all

# Check network
ping mini-pc-ip
curl http://mini-pc-ip:8080/api/status
```

**Issue: High CPU usage**
```bash
# Check CPU usage
htop

# Run optimization
cd ~/mini-pc-setup
sudo ./optimize-streaming-pc.sh

# Verify
cd ~/mini-pc-setup/scripts
./verify-cpu-efficiency.sh
```

**Issue: Poor video quality**
```bash
# Check capture
cd ~/mini-pc-setup/scripts
./test-capture.sh

# Adjust settings via control panel
# http://mini-pc-ip:8081
# Reduce resolution or bitrate
```

### Getting Help

**Documentation:**
- [Hardware Checklist](mini-pc-setup/docs/HARDWARE_CHECKLIST.md)
- [Quick Reference](mini-pc-setup/docs/QUICK_REFERENCE.md)
- [AV1 Guide](mini-pc-setup/docs/AV1_GUIDE.md)

**Community:**
- Broadcast Box Discord: https://discord.gg/An5jjhNUE3
- Broadcast Box GitHub: https://github.com/Glimesh/broadcast-box/issues

## 📊 Timeline Estimate

| Step | Time | Cumulative |
|------|------|------------|
| Hardware setup | 30-60m | 30-60m |
| OS installation | 1-2h | 1.5-3h |
| Copy setup files | 5-10m | 1.75-3.1h |
| Run setup script | 10-15m | 1.9-3.4h |
| Reboot | 2m | 2.0-3.5h |
| Deploy services | 5-10m | 2.1-3.7h |
| Install control panel | 5-10m | 2.2-3.8h |
| Apply CPU optimizations | 2-5m | 2.3-3.9h |
| Start streaming | 2-3m | 2.4-4.0h |
| Testing & verification | 15-30m | 2.75-4.5h |

**Total: 2.75-4.5 hours** for complete deployment

## 📁 File Organization for Deployment

```
project-root/
├── mini-pc-setup/              # Main setup directory
│   ├── setup-mini-pc.sh       # Step 4: System setup
│   ├── deploy.sh              # Step 6: Service deployment
│   ├── control-panel/
│   │   ├── install-control-panel.sh  # Step 7: Control panel
│   │   └── README.md
│   ├── optimize-streaming-pc.sh  # Step 8: CPU optimization
│   ├── scripts/
│   │   ├── test-capture.sh    # Verification
│   │   ├── test-audio.sh      # Verification
│   │   ├── stream-av1-svt.sh  # AV1 encoding
│   │   └── verify-cpu-efficiency.sh  # Verification
│   ├── configs/               # Configuration files
│   ├── docs/                  # All documentation
│   └── viewer/
│       ├── remote-display.html   # Viewer page
│       └── README.md
└── README.md                   # Main documentation
```

## 🎉 Success Criteria

Your deployment is successful when:

✅ All hardware is connected and detected
✅ System is installed and updated
✅ Setup script runs without errors
✅ Services are deployed and running
✅ CPU optimizations are applied
✅ Control panel is accessible
✅ Stream is active
✅ Viewers can connect from other devices
✅ Video quality is acceptable for use case
✅ CPU usage is acceptable for hardware
✅ Network is stable with no packet loss
✅ Viewer page is bookmarked for easy access

## 📝 Sharing with Friends

To share this project with friends:

1. **Share GitHub repository** (or zip file)
2. **Point them to this deployment guide**
3. **Direct them to hardware checklist** for compatibility check
4. **Encourage them to test hardware** before buying

**Tips for friends:**
- Start with minimum configuration to test
- Upgrade components as needed
- Use recommended configuration for best experience
- Ask for help on Discord if issues

## 🚀 Next Steps

After successful deployment:

1. **Enjoy your stream!** - Everything should be working
2. **Bookmark the viewer page** - Easy access for everyone
3. **Test different settings** - Find optimal quality/performance balance
4. **Share with friends** - Help others set up similar systems
5. **Contribute back** - Share improvements, fixes, or features

---

**Ready to deploy?** Start with [Hardware Checklist](mini-pc-setup/docs/HARDWARE_CHECKLIST.md) to verify your setup!

**Need help?** Join the [Broadcast Box Discord](https://discord.gg/An5jjhNUE3) community.

**Estimated time to complete deployment:** 3-4 hours
**Difficulty:** Easy (most steps are automated)
**Maintenance:** Very low (runs unattended)
