# Local WebRTC Gaming Streaming

🎮 **Stream your gaming PC to local viewers with sub-second latency using VP9/AV1 and WebRTC**

> **Perfect for:** Gaming at any resolution while family watches via a simple web bookmark. Supports 720p-1080p streaming. Optimized for low-power mini PCs like OptiPlex with VP9 (20-30% more CPU-efficient than AV1).

**Repository:** https://github.com/Balakirev1837/webrtc-gaming-streaming

## 🚀 Quick Start (Git Deployment)

Clone this repo and deploy to your mini PC in 5 minutes:

```bash
# 1. Clone this repository
git clone https://github.com/Balakirev1837/webrtc-gaming-streaming.git
cd broadcast

# 2. Copy to mini PC (replace user@mini-pc with your details)
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

## 📊 Overview

### What This Does

A complete solution for streaming your Fedora + Wayland gaming PC over WebRTC to local network viewers using Broadcast Box:

```
Gaming PC (Fedora + Wayland @ your preferred resolution)
    ↓ HDMI out
HDMI Splitter (optional, for simultaneous monitor viewing)
    ↓ HDMI
Capture Card (USB 3.0)
    ↓
Mini PC (Streamer - OptiPlex, NUC, etc.)
    ├─ Broadcast Box (Go WebRTC Server)
    ├─ GStreamer Pipeline (AV1 Encoding)
    └─ Web Control Panel (Headless)
        ↓ Local Network
Viewers (Browsers) → http://mini-pc.local:8080/gaming
```

### Key Features

✅ **VP9 Encoding (Default for OptiPlex)** - 20-30% lower CPU than AV1, excellent compatibility
✅ **AV1 Encoding** - 50% bandwidth savings vs H.264, best compression efficiency
✅ **Low Latency** - Sub-second streaming with WebRTC (~450-650ms)
✅ **OptiPlex Optimized** - Direct downscale from any input to 720p@60fps, VP9 default (30-40% CPU)
✅ **Zero-Config Viewer** - Wife bookmarks URL, clicks to watch instantly
✅ **Web Control Panel** - Start/stop stream from browser, no SSH needed
✅ **Multiple Codec Options** - VP9 (CPU-efficient), AV1 (best compression), H.264 (fallback)
✅ **Local Network Only** - No external bandwidth, secure by default
✅ **Production Ready** - Systemd services, auto-restart, comprehensive docs

---

## 🎯 Hardware Requirements

### Minimum Configuration (~$170)
- **Mini PC:** Intel N100 or similar (4 cores, 8 threads)
- **Capture Card:** Generic USB 3.0 HDMI capture ($30-50)
- **Network:** Gigabit Ethernet

### Recommended - OptiPlex 7070-570X4 (~$0 if you have it)
- **CPU:** Intel Pentium G3250T (4 cores, 3.5GHz, 35W TDP)
- **Capture Card:** USB 3.0 HDMI capture (Elgato Cam Link or similar)
- **Performance:** 720p@60fps @ 45-60% CPU ✅ **Sustainable**

### Premium Configuration (~$700)
- **Mini PC:** Intel i7-12700T or AMD Ryzen 7 with GPU
- **Capture Card:** Magewell USB Capture HDMI 4K ($150-250)
- **Performance:** 1080p@60fps @ 15-25% CPU with hardware acceleration

**Full Hardware Checklist:** See [mini-pc-setup/docs/HARDWARE_CHECKLIST.md](mini-pc-setup/docs/HARDWARE_CHECKLIST.md)

---

## 📁 Project Structure

```
broadcast/
├── mini-pc-setup/              # Complete mini PC setup (deploy this)
│   ├── setup-mini-pc.sh        # One-time system setup
│   ├── deploy.sh               # Deploy services to mini PC
│   ├── optimize-streaming-pc.sh # CPU optimizations
│   │
│   ├── scripts/                # Streaming scripts
│   │   ├── stream-vp9.sh              # VP9: CPU-efficient (20-30% less CPU than AV1) ✅ NEW
│   ├── stream-av1-optiplex.sh    # ✅ OptiPlex: 1440p→720p
│   │   ├── stream-1080p-downscale.sh   # 1440p→1080p (high-end)
│   │   ├── stream-av1-svt.sh          # General AV1: 1080p@60fps
│   │   ├── stream-av1-nvenc.sh        # AV1: NVENC hardware
│   │   ├── stream-av1-vaapi.sh       # AV1: VA-API hardware
│   │   ├── stream-av1.sh             # AV1: RAV1E software
│   │   ├── stream.sh                   # H.264: VA-API fallback
│   │   ├── stream-nvenc.sh             # H.264: NVENC fallback
│   │   ├── test-av1-support.sh       # Check AV1 encoders
│   │   ├── test-capture.sh            # Test capture card
│   │   └── test-audio.sh             # Test audio capture
│   │
│   ├── configs/               # Systemd service configurations
│   │   ├── vp9-stream.service          # ✅ VP9 service (OptiPlex default) ✅ NEW
│   │   ├── optiplex-stream.service     # ✅ OptiPlex AV1 service
│   │   ├── gaming-stream-av1.service   # General AV1 service
│   │   ├── gaming-stream.service        # H.264 fallback
│   │   └── broadcast-box.service       # WebRTC server
│   │
│   ├── control-panel/         # Web control panel (headless management)
│   │   ├── stream-control.py           # Flask backend
│   │   ├── install-control-panel.sh    # Installer
│   │   ├── templates/control_panel.html # Web UI
│   │   └── README.md                # Control panel docs
│   │
│   ├── viewer/                # Zero-configuration viewer page
│   │   ├── remote-display.html        # Viewer UI
│   │   └── README.md                # Viewer docs
│   │
│   └── docs/                  # Comprehensive documentation
│       ├── SETUP_GUIDE.md            # Step-by-step setup
│       ├── HARDWARE_CHECKLIST.md     # Hardware requirements
│       ├── QUICK_REFERENCE.md        # Command reference
│       ├── OPTIPLEX_GUIDE.md        # OptiPlex-specific guide
│       └── AV1_GUIDE.md              # AV1 codec details
│
├── README.md                     # This file
└── IMPLEMENTATION_GUIDES/         # Detailed implementation docs
    ├── PROJECT_SUMMARY.md
    ├── OPTIPLEX_COMPLETE.md
    ├── DEPLOYMENT_GUIDE.md
    ├── AV1_IMPLEMENTATION.md
    ├── CONTROL_PANEL_IMPLEMENTATION.md
    ├── CPU_EFFICIENCY_IMPLEMENTATION.md
    ├── REMOTE_DISPLAY_IMPLEMENTATION.md
    └── SIMPLE_VIEWER.md
```

---

## ⚡ Deployment Options

### Option A: OptiPlex 7070-570X4 (Recommended - VP9 Default)

**For:** Any resolution gaming + OptiPlex mini PC

**Configuration:**
- Capture: At your native resolution (e.g., 1440p@144Hz)
- Output: 720p@60fps (direct downscale from capture)
- Codec: VP9 (libvpx) - 20-30% more CPU-efficient than AV1 ✅ DEFAULT
- CPU: 30-40% ✅ Sustainable (15-25% better than AV1)
- Bitrate: 5000 Kbps
- Bandwidth: 5-7 Mbps

**Note:** The OptiPlex script captures at whatever resolution your gaming PC outputs (commonly 1440p@144Hz) and downscales to 720p@60fps for optimal CPU performance on 4-core systems. VP9 is the DEFAULT codec for OptiPlex as it's 20-30% more CPU-efficient than AV1 at similar quality.

**Setup:**
```bash
cd ~/mini-pc-setup
sudo ./setup-mini-pc.sh
sudo reboot

# After reboot
./deploy.sh
sudo systemctl start broadcast-box
sudo systemctl start optiplex-stream

# Or use control panel: http://mini-pc-ip:8081
```

### Option B: Higher-End Mini PC (6+ cores)

**For:** Maximum quality viewing

**Configuration:**
- Capture: At your native resolution (e.g., 1080p@60Hz or 1440p@144Hz)
- Output: 1080p@60fps
- Codec: AV1 (software or hardware)
- CPU: 70-80% (software) or 15-25% (hardware)
- Bitrate: 6000-8000 Kbps
- Bandwidth: 6-8 Mbps

**Setup:**
```bash
cd ~/mini-pc-setup
./deploy.sh
sudo systemctl start broadcast-box
sudo systemctl start gaming-stream-av1
```

### Option C: Hardware-Accelerated (NVENC/VA-API)

**For:** Mini PCs with RTX 40-series or Intel Arc/AMD RDNA3

**Configuration:**
- Use `stream-av1-nvenc.sh` or `stream-av1-vaapi.sh`
- CPU: 15-25% (hardware encoding)
- Quality: Excellent at 6-8 Mbps

---

## 🎬 Usage

### For Viewers (Wife, Family, Friends)

1. **Bookmark this URL:** `http://mini-pc-ip:8080/gaming`
2. **Click bookmark** to instantly see the stream
3. **Use picture controls** (hover over video):
   - Presets: Normal, Bright, Vivid
   - Fine-tune: Brightness, Contrast, Saturation
4. **Keyboard shortcuts:**
   - `F` - Toggle fullscreen
   - `R` - Refresh connection
   - `1/2/3` - Quick presets

### For You (Gamer - Web Control Panel)

Access: `http://mini-pc-ip:8081`

**Features:**
- 🎬 Select streaming script (AV1 encoders)
- ⚙️ Adjust bitrate, resolution, FPS
- ▶️ Start/⏹️ Stop/🔄 Restart streaming (toggle button)
- 📊 Real-time CPU, GPU, memory monitoring
- 📺 Copy stream URL for viewers
- 📝 Activity log

**API Endpoints:**
- `GET /api/stats` - System statistics
- `GET /api/status` - Streaming status
- `POST /api/stream/start` - Start streaming
- `POST /api/stream/stop` - Stop streaming
- `POST /api/stream/toggle` - Toggle on/off ✅ **New**
- `GET /api/scripts` - Available streaming scripts

### System Management

```bash
# Check service status
sudo systemctl status broadcast-box
sudo systemctl status optiplex-stream

# View logs
sudo journalctl -u broadcast-box -f
sudo journalctl -u optiplex-stream -f

# Restart services
sudo systemctl restart broadcast-box
sudo systemctl restart optiplex-stream

# Enable at boot
sudo systemctl enable broadcast-box
sudo systemctl enable optiplex-stream
```

---

## 📚 Documentation

### Quick Links

| Document | Description |
|-----------|-------------|
| **[Hardware Checklist](mini-pc-setup/docs/HARDWARE_CHECKLIST.md)** | Complete hardware requirements and compatibility |
| **[Setup Guide](mini-pc-setup/docs/SETUP_GUIDE.md)** | Step-by-step deployment instructions |
| **[OptiPlex Guide](mini-pc-setup/docs/OPTIPLEX_GUIDE.md)** | OptiPlex-specific optimizations and tuning |
| **[AV1 Guide](mini-pc-setup/docs/AV1_GUIDE.md)** | AV1 codec details and performance |
| **[Quick Reference](mini-pc-setup/docs/QUICK_REFERENCE.md)** | Common commands and troubleshooting |
| **[Deployment Guide](DEPLOYMENT.md)** | Git-based deployment (5 minutes) |
| **[Control Panel](mini-pc-setup/control-panel/README.md)** | Web control panel usage |
| **[Viewer Guide](mini-pc-setup/viewer/README.md)** | Zero-configuration viewer features |

### Implementation Guides

- [AV1 Implementation](AV1_IMPLEMENTATION.md) - Complete AV1 codec details
- [Control Panel](CONTROL_PANEL_IMPLEMENTATION.md) - Web control panel architecture
- [CPU Efficiency](CPU_EFFICIENCY_IMPLEMENTATION.md) - 15-25% CPU optimizations
- [Remote Display](REMOTE_DISPLAY_IMPLEMENTATION.md) - Viewer page implementation
- [Stream On/Off](STREAM_ON_OFF_DOWNSCALE.md) - Toggle and downscaling features

---

## 🔧 Technology Stack

### Core Components

- **Broadcast Box** - Go-based WebRTC SFU (Selective Forwarding Unit)
  - WHIP/WHEP protocol support
  - Multi-track streaming
  - Built-in web interface

- **GStreamer** - Multimedia framework
  - Video capture via V4L2
  - Hardware encoding (VA-API/NVENC)
  - Software encoding (SVT-AV1, RAV1E)
  - WebRTC WHIP sink

- **Flask** - Web framework for control panel
- **systemd** - Service management
- **Linux** - Fedora 38+ (tested), Ubuntu 22.04+

 ### Encoding Comparison

| Encoder | Type | Resolution | CPU Usage | Bitrate | Quality |
|---------|------|------------|------------|----------|---------|
| **VP9 (libvpx)** | Software | 720p@60fps | 30-40% | 5000 Kbps | Very Good |
| **SVT-AV1** | Software | 720p@60fps | 45-60% | 4000 Kbps | Very Good |
| **NVENC AV1** | Hardware | 1080p@60fps | 15-25% | 6000 Kbps | Excellent |
| **VA-API AV1** | Hardware | 1080p@60fps | 15-25% | 6000 Kbps | Excellent |
| **VA-API H.264** | Hardware | 1080p@60fps | 15-20% | 8000 Kbps | Good (fallback) |

---

## 🎯 Performance

### OptiPlex 7070-570X4 @ 720p@60fps

| Metric | Value | Status |
|--------|-------|--------|
 | **CPU Usage** | 30-40% | ✅ Sustainable (VP9 default) |
 | **Temperature** | 45-55°C | ✅ Safe (<75°C) |
 | **Power** | 20-30W | ✅ Efficient |
 | **Latency** | 400-550ms | ✅ Excellent |
 | **Bitrate** | 5000 Kbps | ✅ Efficient |
 | **Bandwidth** | 5-7 Mbps | ✅ Local network friendly |
 | **Quality** | Very Good (VP9) | ✅ Great for tablets/laptops/phones |

### Network Requirements

- **Per stream:** 4-8 Mbps (AV1, 50% less than H.264)
- **Latency:** <5ms between devices
- **Scale:** 1-5 viewers on gigabit network
- **Stability:** No packet loss required

---

## 🐛 Troubleshooting

### Common Issues

**Stream won't start:**
```bash
# Check services
sudo systemctl status broadcast-box optiplex-stream

# Check logs
sudo journalctl -u optiplex-stream -n 50

# Verify capture card
ls -l /dev/video*
v4l2-ctl --list-devices
```

**Capture card not detected:**
```bash
# Add user to video group
sudo usermod -a -G video $USER
# Logout and login again
```

**High CPU usage:**
```bash
# Run CPU optimizations
cd ~/mini-pc-setup
sudo ./optimize-streaming-pc.sh
sudo reboot
```

**Viewers can't connect:**
```bash
# Open firewall ports
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-port=8080/udp
sudo firewall-cmd --permanent --add-port=8081/tcp
sudo firewall-cmd --reload
```

**Full troubleshooting:** See [Quick Reference](mini-pc-setup/docs/QUICK_REFERENCE.md)

---

## 🔐 Security

### Local Network Only
By default, the stream is only accessible on your local network. No external exposure.

### Optional Authentication
Configure Broadcast Box with webhook for stream key validation.

### Firewall
Open only necessary ports:
- 8080/tcp - Broadcast Box (streaming)
- 8080/udp - WebRTC media
- 8081/tcp - Control panel (optional)

---

## 📊 Timeline

**Estimated setup time: 1-2 days**

| Phase | Time |
|-------|------|
| Hardware setup | 2-4 hours |
| OS installation | 1-2 hours (if needed) |
| Git clone & transfer | 10-15 minutes |
| Run setup script | 10-15 minutes |
| Deploy services | 5-10 minutes |
| Install control panel | 5-10 minutes |
| Apply optimizations | 5-10 minutes |
| Testing & tuning | 2-4 hours |

---

## 🤝 Contributing

This is a personal project for local streaming. Feel free to:
- Fork and modify for your hardware
- Share improvements via pull requests
- Report issues
- Adapt for different use cases

---

## 📄 License

MIT License - Free to use, modify, and distribute.

Uses open-source components:
- [Broadcast Box](https://github.com/Glimesh/broadcast-box) - MIT
- [GStreamer](https://gstreamer.freedesktop.org/) - LGPL
- [SVT-AV1](https://gitlab.com/AOMediaCodec/SVT-AV1) - BSD-2

---

## 🙏 Acknowledgments

- **Broadcast Box** - Excellent WebRTC SFU implementation
- **GStreamer Team** - Powerful multimedia framework
- **AOMedia** - AV1 codec development
- **Open Source Community** - All the tools and libraries

---

## 📞 Support

- **Documentation:** See guides in `/mini-pc-setup/docs/`
- **Broadcast Box Discord:** https://discord.gg/An5jjhNUE3
- **Issues:** Open a GitHub issue

---

**🚀 Ready to stream? Clone this repo and deploy to your mini PC in 5 minutes!**

**📖 Start with:** [Deployment Guide](DEPLOYMENT.md) → [Hardware Checklist](mini-pc-setup/docs/HARDWARE_CHECKLIST.md) → [Setup Guide](mini-pc-setup/docs/SETUP_GUIDE.md)
