# Hardware Reference & OptiPlex Guide

This document consolidates hardware requirements, OptiPlex-specific tuning, and performance expectations.

## 📋 Hardware Checklist

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

---

## 🖥️ OptiPlex 7070-570X4 Specifics

### System Specs
- **CPU:** Intel Pentium G3250T (Kaby Lake Refresh)
- **Cores:** 4 physical / 4 threads
- **TDP:** 35W (Low power)
- **Instruction Set:** AVX2 (Crucial for SVT-AV1 performance)

### AV1 Encoding Capability
| Encoder | Min CPU Cores | Expected 1080p@60fps | Expected 720p@60fps | Verdict |
|---------|---------------|----------------------|---------------------|---------|
| **SVT-AV1** | 4+ | 50-60% | 35-45% | ✅ **OPTIMAL** |
| **RAV1E** | 6+ | 60-70% | 50-60% | ⚠️ Borderline |
| **VA-API AV1** | N/A | N/A | N/A | ❌ Not Supported |

### Recommended Configuration
*   **Resolution:** 1280x720 (HD) - Direct downscale from 1440p
*   **Frame Rate:** 60fps
*   **Codec:** AV1 (SVT-AV1)
*   **Bitrate:** 4000 Kbps
*   **Expected CPU:** 35-45%

---

## 🔌 Hardware Setup

### Physical Connections
```
Gaming PC (HDMI out)
    ↓
HDMI Splitter
    ↓
    ├── Output 1: Gaming Monitor (as usual)
    └── Output 2: Capture Card (USB 3.0)
        ↓
    OptiPlex (USB 3.0 Port - Blue)
```

### Verification
1.  **Check Capture Card:**
    ```bash
    ls -l /dev/video*
    # Should see /dev/video0
    ```
2.  **Check CPU:**
    ```bash
    lscpu | grep "Model name"
    ```

---

## 🛠️ Troubleshooting Hardware

### Capture Card Not Detected
*   **Symptom:** `/dev/video0` missing.
*   **Fix:**
    1.  Ensure USB 3.0 port (Blue).
    2.  Check permissions (`sudo usermod -aG video $USER`).
    3.  Re-plug device.

### High CPU Usage (>70%)
*   **Symptom:** Stuttering, thermal throttling.
*   **Fix:**
    1.  Switch to **720p @ 60fps** (Default for OptiPlex).
    2.  Reduce bitrate to 3000 Kbps.
    3.  Ensure `optimize-optiplex.sh` script has been run (sets CPU governor to performance).

### Viewers Can't Connect
*   **Symptom:** Timeout on browser.
*   **Fix:**
    1.  Check firewall rules (Allow 8080/tcp, 8080/udp).
    2.  Ensure devices are on the same subnet.
