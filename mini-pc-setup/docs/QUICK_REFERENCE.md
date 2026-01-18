# WebRTC Gaming Streaming - Quick Reference

## Commands Reference

### Mini PC Setup
```bash
# One-time setup (run as root)
sudo ./setup-mini-pc.sh

# Deploy services
./deploy.sh

# Start services
sudo systemctl start broadcast-box
sudo systemctl start gaming-stream

# Enable at boot
sudo systemctl enable broadcast-box
sudo systemctl enable gaming-stream

# Check status
sudo systemctl status broadcast-box
sudo systemctl status gaming-stream

# View logs
journalctl -u broadcast-box -f
journalctl -u gaming-stream -f
```

### Testing
```bash
# Test capture card
./scripts/test-capture.sh

# Test audio
./scripts/test-audio.sh

# Check GPU encoding
vainfo                          # Intel/AMD
nvidia-smi --query-gpu=...      # NVIDIA
```

### Manual Stream (Debugging)
```bash
# Terminal 1: Broadcast Box
cd ~/broadcast-box && ./broadcast-box

# Terminal 2: Stream
cd ~/streaming && ./stream.sh
```

### Docker Alternative
```bash
# Start
docker-compose up -d

# Stop
docker-compose down

# View logs
docker-compose logs -f
```

### Viewer Access
```
http://<mini-pc-ip>:8080/gaming
http://<hostname>.local:8080/gaming  # with mDNS
```

## Configuration Files

| File | Purpose |
|------|---------|
| `configs/.env.production` | Broadcast Box configuration |
| `scripts/stream.sh` | VA-API streaming pipeline |
| `scripts/stream-nvenc.sh` | NVENC streaming pipeline |
| `configs/broadcast-box.service` | Systemd service |
| `configs/gaming-stream.service` | Stream service |

## Environment Variables

Set in systemd service or export:
```bash
STREAM_KEY=gaming                           # Stream identifier
SERVER_URL=http://localhost:8080/api/whip   # Broadcast Box endpoint
VIDEO_DEVICE=/dev/video0                     # Capture card device
```

## Common Issues

| Problem | Solution |
|---------|----------|
| Capture card not found | `sudo usermod -a -G video $USER` then re-login |
| Port in use | `sudo lsof -i :8080` to find process |
| No video | Run `./scripts/test-capture.sh` to verify |
| No audio | Run `./scripts/test-audio.sh` to verify |
| Can't connect | Check firewall: `sudo firewall-cmd --list-all` |
| High latency | Lower bitrate in `stream.sh` |
| Poor quality | Increase bitrate in `stream.sh` |

## Performance Tuning

### Best Quality (Current)
```bash
target-bitrate=8000-10000
keyframe-period=120
quality-level=7
tune=hq
```

### Lower Latency
```bash
target-bitrate=6000
keyframe-period=60
quality-level=4
tune=ll
```

### Higher Quality
```bash
target-bitrate=10000-12000
keyframe-period=120
quality-level=7
tune=hq
```

## Network Commands

```bash
# Set static IP
sudo nmcli connection modify "Wired connection 1" \
  ipv4.addresses 192.168.1.100/24 \
  ipv4.gateway 192.168.1.1 \
  ipv4.method manual

# Open firewall
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-port=8080/udp
sudo firewall-cmd --reload

# Check connectivity
ping <mini-pc-ip>
curl http://<mini-pc-ip>:8080/api/status
```

## Monitor Performance

```bash
# System resources
htop

# Network
iftop

# Broadcast Box status
curl http://localhost:8080/api/status

# GStreamer debug
GST_DEBUG=2 ./stream.sh
```

## File Locations

| Path | Purpose |
|------|---------|
| `~/broadcast-box/` | Broadcast Box installation |
| `~/streaming/` | Streaming scripts and config |
| `/etc/systemd/system/broadcast-box.service` | Broadcast Box service |
| `/etc/systemd/system/gaming-stream.service` | Stream service |

## Stream URLs

| Format | Example |
|--------|---------|
| IP address | `http://192.168.1.100:8080/gaming` |
| Hostname | `http://streamer.local:8080/gaming` |
| Status API | `http://192.168.1.100:8080/api/status` |
| WHIP endpoint | `http://192.168.1.100:8080/api/whip` |

## Quick Start

1. **Setup mini PC:**
   ```bash
   sudo ./setup-mini-pc.sh
   sudo reboot
   ```

2. **Deploy services:**
   ```bash
   ./deploy.sh
   ```

3. **Start services:**
   ```bash
   sudo systemctl start broadcast-box gaming-stream
   ```

4. **Test from viewer:**
   ```
   http://<mini-pc-ip>:8080/gaming
   ```

## Support

- Broadcast Box: https://github.com/Glimesh/broadcast-box
- GStreamer: https://gstreamer.freedesktop.org/documentation/
- Discord: https://discord.gg/An5jjhNUE3
