# AV1 Streaming Guide

This guide covers using AV1 codec for cutting-edge WebRTC streaming with Broadcast Box.

## Why AV1?

AV1 offers:
- **~50% better compression** than H.264 at same quality
- **~30% better compression** than VP9 at same quality
- Lower bandwidth requirements for same quality
- Better quality at same bitrate
- Cutting-edge, future-proof codec

## Hardware Requirements

### Hardware Encoding (Recommended)

**Intel Arc GPUs:**
- Arc A310/A380/A750/A770+
- Full AV1 hardware encoding support
- Excellent performance

**AMD RDNA3 GPUs:**
- Radeon RX 7000 series
- Full AV1 hardware encoding support
- Excellent performance

**NVIDIA GPUs:**
- RTX 40-series (4060, 4070, 4080, 4090)
- AV1 encoding via NVENC
- Excellent performance

### Software Encoding

**SVT-AV1 (Recommended for software):**
- Fastest AV1 encoder
- 50-70% CPU usage for 1080p@60
- Requires modern CPU (4+ cores recommended)

**RAV1E:**
- Moderate speed
- 60-80% CPU usage for 1080p@60
- Good quality

## Available Streaming Scripts

| Script | Encoder | Type | CPU Usage | Quality | Recommended |
|--------|----------|-------|-----------|---------|-------------|
| `stream-av1-nvenc.sh` | NVENC | Hardware | 15-25% | Excellent | ✅ RTX 40-series |
| `stream-av1-vaapi.sh` | VA-API | Hardware | 15-25% | Excellent | ✅ Intel Arc / AMD RDNA3 |
| `stream-av1-svt.sh` | SVT-AV1 | Software | 50-70% | Excellent | ✅ Software encoding |
| `stream-av1.sh` | RAV1E | Software | 60-80% | Excellent | ⚠️  If SVT-AV1 unavailable |

## Quick Start

### 1. Check AV1 Support

```bash
cd ~/mini-pc-setup/scripts
chmod +x test-av1-support.sh
./test-av1-support.sh
```

This will:
- Detect available AV1 encoders
- Check hardware acceleration
- Recommend best encoder for your system
- Test encoding performance

### 2. Choose Streaming Script

Based on `test-av1-support.sh` output:

**Hardware Encoding (Best Performance):**
```bash
# For NVIDIA RTX 40-series
./stream-av1-nvenc.sh

# For Intel Arc / AMD RDNA3+
./stream-av1-vaapi.sh
```

**Software Encoding (If no hardware support):**
```bash
# SVT-AV1 (faster)
./stream-av1-svt.sh

# RAV1E (alternative)
./stream-av1.sh
```

### 3. Start Streaming

**Manual Start:**
```bash
# Terminal 1: Broadcast Box
cd ~/broadcast-box
./broadcast-box

# Terminal 2: AV1 Stream
cd ~/streaming
./stream-av1-svt.sh  # Or your chosen script
```

**Systemd Service:**
```bash
# Install AV1 service
sudo cp configs/gaming-stream-av1.service /etc/systemd/system/
sudo systemctl daemon-reload

# Modify service if needed
sudo nano /etc/systemd/system/gaming-stream-av1.service
# Change ExecStart line to your chosen script

# Start service
sudo systemctl start gaming-stream-av1
sudo systemctl enable gaming-stream-av1
```

## Configuration

### Bitrate Settings

AV1 provides better quality at lower bitrates than H.264.

**Recommended bitrates for 1080p@60:**

| Quality | AV1 Bitrate | H.264 Equivalent | Bandwidth Savings |
|---------|--------------|------------------|-------------------|
| Good | 4 Mbps | 8 Mbps | 50% |
| Very Good | 6 Mbps | 10 Mbps | 40% |
| Excellent | 8 Mbps | 12 Mbps | 33% |

Edit your streaming script to adjust bitrate:

**SVT-AV1:**
```bash
svtav1enc bitrate=6000  # Kbps
```

**NVENC:**
```bash
nvav1enc bitrate=6000000  # Bits per second
```

**VA-API:**
```bash
vaapiav1enc target-bitrate=6000  # Kbps
```

### Speed/Quality Trade-off

**SVT-AV1 Presets:**
```bash
preset=0   # Slowest, best quality
preset=4   # Balanced
preset=8   # Fastest, slightly lower quality
```

**RAV1E Speed Presets:**
```bash
speed-preset=0  # Slowest, best quality
speed-preset=6  # Fast
speed-preset=10 # Fastest, lower quality
```

### Resolution & FPS

For lower CPU usage, reduce resolution or FPS:

```bash
# 720p@60 (good performance)
v4l2src ! video/x-raw,width=1280,height=720,framerate=60/1

# 1080p@30 (lower CPU)
v4l2src ! video/x-raw,width=1920,height=1080,framerate=30/1
```

## Performance Comparison

### Hardware Encoding

| Metric | AV1 | H.264 | VP9 |
|--------|------|-------|------|
| CPU Usage | 15-25% | 15-20% | 15-25% |
| Latency | 400-600ms | 400-500ms | 500-700ms |
| Quality @ 6 Mbps | Excellent | Good | Very Good |
| Browser Support | ⚠️  Chrome/Firefox | ✅ All | ⚠️  Chrome/Firefox |

### Software Encoding

| Encoder | CPU Usage | Latency | Speed | Quality |
|---------|-----------|----------|-------|---------|
| **SVT-AV1** | 50-70% | 500-800ms | Fastest | Excellent |
| **RAV1E** | 60-80% | 600-1000ms | Fast | Excellent |
| **libaom** | 80-100% | 1000ms+ | Very Slow | Excellent |

## Browser Compatibility

AV1 support in modern browsers:

| Browser | Version | AV1 Support |
|---------|----------|-------------|
| Chrome | 70+ | ✅ Yes |
| Firefox | 67+ | ✅ Yes |
| Edge | 79+ | ✅ Yes |
| Safari | 16+ | ✅ Yes |
| Opera | 57+ | ✅ Yes |

**Note:** All major browsers now support AV1 decoding, making it ideal for your use case.

## Troubleshooting

### AV1 Encoder Not Found

```bash
# Install AV1 encoding packages
sudo dnf install gstreamer1-plugins-bad-free-extras
sudo dnf install svt-av1-tools rav1e

# Verify installation
gst-inspect-1.0 | grep -E "(rav1|svtav1|vaapiav1|nvav1)"
```

### High CPU Usage

1. **Use hardware encoding:**
   ```bash
   ./stream-av1-vaapi.sh  # Intel/AMD
   ./stream-av1-nvenc.sh    # NVIDIA
   ```

2. **Reduce settings:**
   ```bash
   # Lower bitrate
   bitrate=4000

   # Reduce resolution
   width=1280,height=720

   # Reduce FPS
   framerate=30/1

   # Increase preset speed
   preset=8
   ```

3. **Use SVT-AV1 instead of RAV1E:**
   ```bash
   ./stream-av1-svt.sh  # Faster than RAV1E
   ```

### Viewers Can't See Stream

1. **Check browser supports AV1:**
   - Chrome: `chrome://gpu` → Look for "AV1"
   - Firefox: `about:support` → Search for "AV1"

2. **Verify AV1 payload in WebRTC:**
   ```bash
   # Enable debug
   DEBUG_PRINT_OFFER=true
   # Check that AV1 is in codec list
   ```

3. **Test with H.264 fallback:**
   ```bash
   ./stream.sh  # H.264 for testing
   ```

### Encoding Too Slow

**Hardware:**
- Check GPU has AV1 support
- Verify drivers are up to date
- Reduce bitrate/resolution

**Software:**
- Use SVT-AV1 instead of RAV1E
- Reduce resolution to 720p
- Reduce FPS to 30
- Increase speed preset

## Advanced Configuration

### Two-Pass Encoding (Better Quality, Higher Latency)

**SVT-AV1:**
```bash
svtav1enc \
  passes=2 \
  rc-mode=2
```

**RAV1E:**
```bash
rav1enc \
  speed-preset=6 \
  tile-columns=2 \
  tile-rows=2
```

### Multi-Threading

**SVT-AV1:**
```bash
svtav1enc threads=8
```

**RAV1E:**
```bash
rav1enc threads=8
```

### Adaptive Bitrate

Create multiple encoder instances with different bitrates. Broadcast Box supports multi-track WebRTC for simulcast.

## Monitoring Performance

```bash
# CPU usage
htop

# Encoding latency
GST_DEBUG=2 ./stream-av1-svt.sh

# Network bandwidth
iftop

# Broadcast Box status
curl http://localhost:8080/api/status
```

## Comparison: AV1 vs H.264

| Metric | AV1 | H.264 |
|--------|------|-------|
| Compression Efficiency | 1.5-2x better | Baseline |
| Bitrate @ 1080p60 | 4-8 Mbps | 8-12 Mbps |
| CPU Usage (Hardware) | 15-25% | 15-20% |
| CPU Usage (Software) | 50-80% | 15-25% |
| Encoding Speed (Hardware) | Similar | Similar |
| Encoding Speed (Software) | Slower | Fastest |
| Browser Support | Chrome/Firefox/Safari | All browsers |
| Hardware Support | Newer GPUs only | Most GPUs |
| Latency | 400-800ms | 400-500ms |
| Licensing | Royalty-free | Patent fees |

## Conclusion

For your setup with AV1-capable devices on the network:

1. **Best Choice:** Hardware AV1 (NVENC/VA-API) - Excellent performance, best quality
2. **Good Choice:** SVT-AV1 software - Fast enough for modern CPUs, excellent quality
3. **Fallback:** H.264 - If AV1 not supported or CPU too slow

AV1 provides significantly better quality at the same bitrate, making it perfect for your cutting-edge streaming setup!
