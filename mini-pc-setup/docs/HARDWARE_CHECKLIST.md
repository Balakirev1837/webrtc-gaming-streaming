# Hardware Checklist

Complete hardware requirements and recommendations for deploying your WebRTC streaming server.

## Quick Start: What Do You Need?

### Minimum Configuration (~$150 total)
- Mini PC: Intel i3 4th gen or AMD Ryzen 3 (4GB RAM)
- Capture card: Any USB 3.0 HDMI capture ($30-50)
- Network: Gigabit Ethernet

**Result:** 720p/1080p @ 60fps with AV1 software encoding (50-70% CPU)

### Recommended Configuration (~$400 total)
- Mini PC: Intel i5 6th gen+ or AMD Ryzen 5 (8GB RAM)
- Capture card: Elgato Cam Link 4K or Magewell ($100-150)
- Network: Gigabit Ethernet

**Result:** 1080p @ 60fps with AV1 hardware encoding (15-25% CPU)

### High-End Configuration (~$800+ total)
- Mini PC: Intel i7 7th gen+ or AMD Ryzen 7 (16GB RAM)
- Capture card: Elgato Cam Link 4K ($100-150)
- GPU: NVIDIA RTX 40-series or Intel Arc (for AV1 hardware)
- Network: Gigabit Ethernet

**Result:** 1080p @ 60fps with AV1 hardware encoding (15-25% CPU)

---

## Required Hardware

### 1. Mini PC (Streaming Server)

**Purpose:** Captures video, encodes with AV1, serves via WebRTC

#### CPU Requirements

| Use Case | Minimum | Recommended | Optimal |
|----------|----------|-------------|----------|
| **720p @ 30fps** | Intel i3 2nd gen | Intel i5 4th gen | Intel i7 4th gen |
| **1080p @ 60fps (SW AV1)** | Intel i3 4th gen / AMD Ryzen 3 | Intel i5 6th gen / AMD Ryzen 5 | Intel i7 7th gen / AMD Ryzen 7 |
| **1080p @ 60fps (HW AV1)** | Intel i3 6th gen / AMD Ryzen 3 | Intel i5 8th gen / AMD Ryzen 5 | Intel i7 9th gen / AMD Ryzen 7 |

**Key Requirements:**
- 4 physical cores minimum (6+ recommended)
- AVX2 instruction set (Intel Haswell 2013+, AMD Zen 2017+)
- Hardware virtualization not required

**Common CPUs:**
- ✅ Intel Core i3/i5/i7 (4th gen and newer)
- ✅ AMD Ryzen 3/5/7 (all generations)
- ✅ Intel Pentium Gold (8th gen+)
- ✅ Intel Celeron (12th gen+ with AVX2)
- ❌ Intel Core 2 Duo, AMD Athlon X2 (too old)
- ❌ ARM CPUs (not supported by some encoders)

#### RAM Requirements

| Resolution | Minimum | Recommended | Optimal |
|-----------|----------|-------------|----------|
| **720p @ 30fps** | 2GB | 4GB | 8GB |
| **1080p @ 60fps (SW AV1)** | 4GB | 8GB | 16GB |
| **1080p @ 60fps (HW AV1)** | 4GB | 8GB | 16GB |

**Note:** More RAM allows better system responsiveness and caching

#### Storage Requirements

| Type | Minimum | Recommended |
|------|----------|-------------|
| **HDD** | 20GB | 50GB |
| **SSD** | 20GB | 128GB |
| **NVMe SSD** | 20GB | 256GB |

**Note:** Streaming uses minimal storage. SSD not required but improves boot speed.

#### GPU Requirements (For Hardware AV1 Encoding)

**Intel:**
- Arc A310, A380, A750, A770 (full AV1 encode/decode)
- Xe integrated graphics (Gen 12 iGPUs - AV1 decode only, need software encode)

**AMD:**
- RX 7000 series (RDNA3 - full AV1 encode/decode)
- RX 6000 series (RDNA2 - AV1 decode only, need software encode)

**NVIDIA:**
- RTX 40-series (4060, 4070, 4080, 4090) - full AV1 encode/decode
- RTX 30-series (AV1 decode only, need software encode)
- GTX 16-series (no AV1 support)

**No Hardware AV1?** Software encoding works fine with 4+ core CPU!

### 2. Capture Card

**Purpose:** Captures HDMI output from gaming PC

#### USB 3.0 Capture Cards (Most Common)

| Product | Price | Max Resolution | FPS | Linux Support | AV1 Compatible? |
|---------|-------|----------------|-----|----------------|------------------|
| **Elgato Cam Link 4K** | ~$130 | 4K@60fps | 60fps | ✅ Yes (via PC) |
| **Magewell USB Capture HDMI 4K** | ~$150 | 4K@60fps | 60fps | ✅ Yes (via PC) |
| **AverMedia Live Gamer Portable 2 Plus** | ~$80 | 1080p@60fps | 60fps | ✅ Yes (via PC) |
| **Razer Ripsaw HD** | ~$60 | 1080p@60fps | 60fps | ✅ Yes (via PC) |
| **Generic USB 3.0 HDMI** | ~$30-50 | 1080p@60fps | 30-60fps | ⚠️ Variable |
| **Generic USB 2.0 HDMI** | ~$20-30 | 720p@30fps | 30fps | ❌ Insufficient bandwidth |

**Requirements:**
- USB 3.0 port (blue connector) - USB 2.0 won't handle 1080p@60fps
- Linux driver support (check before buying)
- V4L2 compatible

#### PCIe Capture Cards (Higher Performance)

| Product | Price | Max Resolution | FPS | Notes |
|---------|-------|----------------|-----|-------|
| **Magewell Pro Capture HDMI** | ~$250 | 4K@60fps | PCIe x4, very stable |
| **Blackmagic Design Intensity Pro 4K** | ~$340 | 4K@60fps | PCIe x8, high quality |

#### HDMI Splitter (Optional but Recommended)

**Purpose:** Send HDMI to both monitor and capture card

| Type | Price | Quality | Notes |
|------|-------|---------|-------|
| **Passive Splitter** | $10-20 | Good | Same signal to both outputs |
| **Powered Splitter** | $20-40 | Better | Amplifies signal, longer cables |
| **Switch** | $15-30 | Best | Select between multiple inputs |

**Without Splitter:**
- Manual cable switching required
- Monitor OR capture, not both
- Inconvenient for regular use

### 3. Network

**Purpose:** WebRTC stream delivery to viewers

#### Wired Network (Recommended)

| Type | Speed | Latency | Recommendation |
|------|--------|----------|---------------|
| **100Mbps Ethernet** | Minimum | <1ms | Only for 1 viewer, 720p |
| **1Gbps Ethernet** | Recommended | <1ms | ✅ Best for all use cases |
| **10Gbps Ethernet** | Overkill | <1ms | Not needed |

**Switch Requirements:**
- Gigabit switch (for multi-device networks)
- Jumbo frames (optional, may improve performance)
- Managed switch not required

#### Wireless Network (Not Recommended)

| Type | Speed | Latency | Recommendation |
|------|--------|----------|---------------|
| **WiFi 5GHz** | Variable | 2-10ms | ⚠️ Only if wired not possible |
| **WiFi 6/6E** | Variable | 1-5ms | ⚠️ Better than 5GHz but still variable |

**WiFi Issues:**
- Higher latency
- Packet loss during interference
- Reduced quality
- Not recommended for gaming streaming

### 4. Cables

#### HDMI Cables

| Type | Length | Quality | Recommendation |
|------|--------|---------|---------------|
| **HDMI 2.0 High Speed** | < 3m | Good for 1080p@60fps |
| **HDMI 2.1 Premium High Speed** | < 5m | ✅ Best for all resolutions |
| **HDMI 2.1 Ultra High Speed** | < 10m | ✅ Supports 4K@60fps |

**Avoid:** Long cables (>10m), very cheap cables, HDMI 1.4

#### USB 3.0 Cables

| Type | Length | Quality | Recommendation |
|------|--------|---------|---------------|
| **USB 3.0 (Blue connector)** | < 1m | ✅ Best, minimal latency |
| **USB 3.0 (Blue connector)** | < 3m | Good for most setups |

**Avoid:** USB 2.0 cables (won't work for capture)

### 5. Gaming PC

**No Special Requirements!**
- Any HDMI output works
- No software installation required on gaming PC
- Wayland or X11 both supported (capture card handles it)

**Note:** Your gaming PC just outputs video. Capture happens elsewhere.

---

## Hardware Configurations

### Configuration 1: Budget Setup (~$200)

**Total Cost: ~$200**

| Component | Recommendation | Cost |
|-----------|----------------|-------|
| Mini PC | Intel N100 or similar mini PC | ~$100 |
| Capture Card | Generic USB 3.0 HDMI capture | ~$30 |
| HDMI Splitter | Passive 1x2 splitter | ~$15 |
| Cables | HDMI + USB 3.0 | ~$15 |
| Network | Gigabit Ethernet cable | ~$10 |
| **Total** | | **~$170** |

**Performance:** 1080p @ 60fps, AV1 software encoding, 50-70% CPU

### Configuration 2: Recommended Setup (~$400)

**Total Cost: ~$400**

| Component | Recommendation | Cost |
|-----------|----------------|-------|
| Mini PC | Intel i5-6500T or AMD Ryzen 5 mini PC | ~$250 |
| Capture Card | Elgato Cam Link 4K | ~$130 |
| HDMI Splitter | Powered 1x2 splitter | ~$30 |
| Cables | HDMI 2.1 + USB 3.0 | ~$20 |
| Network | Cat6 Ethernet cable | ~$10 |
| **Total** | | **~$440** |

**Performance:** 1080p @ 60fps, AV1 software encoding, 40-50% CPU

### Configuration 3: Premium Setup (~$800)

**Total Cost: ~$800**

| Component | Recommendation | Cost |
|-----------|----------------|-------|
| Mini PC | Intel i7-12700T or AMD Ryzen 7 mini PC (with GPU) | ~$450 |
| Capture Card | Magewell USB Capture HDMI 4K | ~$150 |
| HDMI Splitter | Powered 1x2 splitter | ~$30 |
| Cables | HDMI 2.1 + USB 3.0 + Cat6 | ~$30 |
| Network | Gigabit switch | ~$40 |
| **Total** | | **~$700** |

**Performance:** 1080p @ 60fps, AV1 hardware encoding, 15-25% CPU

---

## OS Compatibility

### Linux Distributions

| Distribution | Support Level | Notes |
|--------------|----------------|-------|
| **Fedora 38+** | ✅ Excellent | Tested and recommended |
| **Ubuntu 22.04+** | ✅ Excellent | Well supported |
| **Debian 12+** | ✅ Excellent | Stable choice |
| **Arch Linux** | ✅ Good | Rolling, requires manual setup |
| **openSUSE** | ✅ Good | Supported |
| **Pop!_OS** | ✅ Good | Based on Arch |

**Not Supported:**
- Windows (GStreamer V4L2 support is limited)
- macOS (different video capture architecture)
- RHEL/CentOS 7 (too old)

---

## Verification Checklist

### Before Purchase

- [ ] Capture card has Linux driver support
- [ ] Mini PC has 4+ cores
- [ ] Network supports gigabit
- [ ] All cables are correct type and length
- [ ] HDMI splitter is compatible with your resolution

### After Purchase

- [ ] Test capture card on a different machine first
- [ ] Verify mini PC meets minimum specs
- [ ] Check network connectivity between all devices
- [ ] Confirm HDMI splitter works with your monitor

### After Setup

- [ ] Capture card visible as `/dev/video0`
- [ ] AV1 encoder installed (check with `verify-cpu-efficiency.sh`)
- [ ] Streaming service starts successfully
- [ ] Viewers can connect from other devices
- [ ] Audio and video are in sync
- [ ] CPU usage is acceptable (<70% for software, <30% for hardware)

---

## Troubleshooting Hardware

### Capture Card Not Detected

**Problem:** `/dev/video0` doesn't exist

**Solutions:**
1. Check USB port: Use USB 3.0 (blue connector), not USB 2.0
2. Check USB hub: Direct connection to mini PC, not through hub
3. Check permissions: `sudo usermod -a -G video $USER`
4. Try different USB port
5. Verify Linux driver support before purchase

### Poor Video Quality

**Problem:** Video looks pixelated, low FPS, or drops frames

**Solutions:**
1. Check USB 3.0 bandwidth: Don't use USB hub
2. Reduce resolution/bitrate if using software encoding
3. Check cable quality: Use shorter HDMI cables
4. Disable other USB devices that might share bandwidth
5. Verify capture card supports your resolution/FPS

### Network Issues

**Problem:** Viewers can't connect, poor quality, buffering

**Solutions:**
1. All devices on same network/subnet
2. Use wired Ethernet, not WiFi
3. Check switch: Gigabit switch, not 100Mbps
4. Test network: `ping mini-pc-ip -c 10`
5. Check for packet loss: `iperf3 -c mini-pc-ip`

### CPU Too High

**Problem:** Mini PC slow, thermal throttling, crashes

**Solutions:**
1. Reduce resolution to 720p
2. Reduce FPS to 30
3. Lower bitrate
4. Use hardware encoding if GPU supports AV1
5. Add cooling (case fan, better thermal paste)
6. Run CPU optimizations: `./optimize-streaming-pc.sh`

---

## Where to Buy Hardware

### Mini PCs

**New:**
- Intel NUC series (Intel N100, i5-6500T, etc.)
- Minisforum (UM560, UM690)
- Beelink (T4 Pro, GTR series)
- ASUS Mini PC (PB series)
- Zotac ZBOX series

**Used:**
- eBay/Facebook Marketplace for older NUCs
- Refurbished from manufacturers

### Capture Cards

**New:**
- Amazon: Elgato, Magewell, AverMedia
- B&H Photo Video: Professional grade
- Micro Center: Local availability

**Used:**
- eBay: Older capture cards work fine
- Facebook Marketplace: Often used gear

### Cables

**Recommendations:**
- Monoprice: Good quality, inexpensive
- Cable Matters: Premium HDMI and USB cables
- Anker: Reliable USB 3.0 cables

---

## Summary

### What You Need (Minimum):

✅ Mini PC with 4+ core CPU  
✅ 4GB RAM (8GB recommended)  
✅ USB 3.0 HDMI capture card  
✅ Gigabit network  
✅ HDMI cables  
✅ HDMI splitter (optional but recommended)  

### What You Need (Recommended):

✅ Mini PC with 6+ core CPU  
✅ 8GB RAM  
✅ Quality capture card (Elgato/Magewell)  
✅ Gigabit network  
✅ All quality cables  

### What You Need (Optimal):

✅ Mini PC with 8+ core CPU + AV1 hardware GPU  
✅ 16GB RAM  
✅ Premium capture card  
✅ Gigabit network with switch  
✅ All premium cables  

---

**Total Cost Range:** $170-700 depending on configuration

**Setup Difficulty:** Easy (plug and play, mostly)

**Maintenance:** Very low (runs unattended)

**Perfect for:** Home streaming, remote monitoring, second monitor experience
