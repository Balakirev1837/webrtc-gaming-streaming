# Mini PC Streaming Server Setup

This directory contains all files needed to set up a dedicated streaming server on your mini PC using Broadcast Box WebRTC.

## Quick Start

### 1. Setup Mini PC (One-time)

Copy the entire `mini-pc-setup` directory to your mini PC:

```bash
# On development laptop
scp -r mini-pc-setup user@mini-pc-ip:/home/user/

# SSH into mini PC
ssh user@mini-pc-ip
cd mini-pc-setup

# Run setup (requires sudo)
sudo ./setup-mini-pc.sh
```

### 2. Deploy Services

After setup completes and you've rebooted:

```bash
./deploy.sh
```

### 3. Start Services

```bash
# Start manually for testing
sudo systemctl start broadcast-box
sudo systemctl start gaming-stream

# Enable at boot
sudo systemctl enable broadcast-box
sudo systemctl enable gaming-stream
```

## Directory Structure

```
mini-pc-setup/
├── setup-mini-pc.sh      # One-time system setup (install packages, etc.)
├── deploy.sh              # Deploy Broadcast Box and streaming services
├── docker-compose.yml     # Docker deployment (alternative to native)
├── scripts/
│   ├── stream.sh          # Main streaming pipeline (VA-API)
│   ├── stream-nvenc.sh    # Streaming pipeline (NVENC for NVIDIA GPUs)
│   ├── test-capture.sh    # Test capture card functionality
│   └── test-audio.sh      # Test audio capture
├── configs/
│   ├── .env.production    # Broadcast Box configuration
│   ├── broadcast-box.service   # Systemd service for Broadcast Box
│   └── gaming-stream.service   # Systemd service for streaming
└── README.md              # This file
```

## Configuration

### Environment Variables

Edit `configs/.env.production` or set in systemd service files:

- `STREAM_KEY`: Stream key (default: "gaming")
- `SERVER_URL`: Broadcast Box WHIP endpoint (default: "http://localhost:8080/api/whip")
- `VIDEO_DEVICE`: Capture card device (default: "/dev/video0")

### Audio Device

List available audio devices:
```bash
pactl list sources short
```

Update `scripts/stream.sh` with your audio device:
```bash
pulsesrc device=alsa_output.pci-0000_00_1f.3.analog-stereo.monitor
```

## Testing

### Test Capture Card

```bash
chmod +x scripts/test-capture.sh
./scripts/test-capture.sh
```

### Test Audio

```bash
chmod +x scripts/test-audio.sh
./scripts/test-audio.sh
```

### Test Full Pipeline (Manual)

```bash
# Terminal 1: Start Broadcast Box
cd ~/broadcast-box
./broadcast-box

# Terminal 2: Start stream
cd ~/streaming
./stream.sh
```

## Viewer Access

Once services are running, viewers can access the stream from any device on the local network:

```
http://<mini-pc-ip>:8080/gaming
```

Or with mDNS (if Avahi is installed):
```
http://<hostname>.local:8080/gaming
```

## Troubleshooting

### Capture card not found

```bash
# Check device permissions
ls -l /dev/video*

# Add user to video group
sudo usermod -a -G video $USER
# Logout and login again
```

### Stream won't start

```bash
# Check service status
sudo systemctl status broadcast-box
sudo systemctl status gaming-stream

# View logs
journalctl -u broadcast-box -f
journalctl -u gaming-stream -f
```

### No audio

```bash
# List audio sources
pactl list sources short

# Test audio capture
gst-launch-1.0 pulsesrc ! audioconvert ! autoaudiosink
```

### Viewers can't connect

```bash
# Check firewall
sudo firewall-cmd --list-all

# Open ports
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-port=8080/udp
sudo firewall-cmd --reload
```

### GPU encoder issues

**Check VA-API:**
```bash
vainfo
```

**Check NVENC (NVIDIA):**
```bash
nvidia-smi --query-gpu=encoder.version.info.purevid,encoder.version.info.fw --format=csv
```

## Performance Tuning

### Best Quality (Current Settings)

- Video bitrate: 8000 Kbps
- Audio bitrate: 192 Kbps
- Keyframe period: 60 frames
- Quality level: 7
- Tune: high quality

### Lower Latency

Edit `scripts/stream.sh`:
```bash
target-bitrate=6000          # Lower bitrate
keyframe-period=60           # Fewer keyframes
quality-level=4              # Faster encoding
tune=ll                      # Low latency
```

### Higher Quality

Edit `scripts/stream.sh`:
```bash
target-bitrate=10000         # Higher bitrate
keyframe-period=120          # More frequent keyframes
quality-level=7              # Higher quality
tune=hq                      # High quality
```

## Docker vs Native Deployment

### Native (Recommended)

```bash
./deploy.sh
sudo systemctl start broadcast-box
```

- Direct hardware access
- Better performance
- Full GPU acceleration

### Docker (Alternative)

```bash
docker-compose up -d
```

- Easier to manage
- Isolated environment
- May have GPU limitations

## System Requirements

### Hardware

- CPU: Intel 4th gen+ or AMD Ryzen (for hardware encoding)
- RAM: 4GB minimum, 8GB recommended
- Storage: 20GB minimum
- Network: Gigabit Ethernet preferred
- USB 3.0+ for capture card

### Software

- OS: Fedora 38+ or similar Linux distribution
- Go 1.18+
- Node.js 18+
- GStreamer 1.20+
- VA-API or NVENC support

## Expected Performance

| Resolution | FPS | Bitrate | CPU Usage | Latency | Quality |
|------------|-----|---------|----------|---------|---------|
| 1080p | 60 | 6 Mbps | 15-20% | 400ms | Good |
| 1080p | 60 | 8 Mbps | 20-25% | 500ms | Very Good |
| 1080p | 60 | 10 Mbps | 25-30% | 600ms | Excellent |
| 1440p | 60 | 12 Mbps | 30-40% | 700ms | Excellent |

## Advanced Features

### Multiple Quality Levels

Broadcast Box supports multi-track WebRTC. Create multiple encoder instances with different bitrates for simulcast.

### Recording

Add to GStreamer pipeline:
```bash
tee name=t ! queue ! rtph264pay ! ... ! whipsink
t. ! queue ! filesink location=recording.h264
```

### OBS Studio Integration

OBS can broadcast to Broadcast Box via WHIP:
1. OBS → Settings → Stream
2. Service: WHIP
3. Server: `http://mini-pc-ip:8080/api/whip`
4. Stream Key: `gaming` (or your custom key)

## Security

### Local Network Only

By default, the stream is only accessible on the local network. No external exposure.

### Optional Authentication

Add to `.env.production`:
```bash
WEBHOOK_URL=http://localhost:9000/validate
```

## Support

- Broadcast Box: https://github.com/Glimesh/broadcast-box
- GStreamer: https://gstreamer.freedesktop.org/documentation/
- VA-API: https://github.com/intel/libva
- Discord: https://discord.gg/An5jjhNUE3
