# Optimization Guide for OptiPlex & Low-End Hardware

This guide explains how to optimize the WebRTC streaming server for maximum performance on low-end hardware like the OptiPlex 7070-570X4 (Intel Pentium G3250T).

## 🚀 Applied Optimizations (Automatic)

The Docker deployment (`docker-deployment/control-panel`) has been pre-tuned with the following environment variables:

### GStreamer Optimizations (Container-Level)
These are active automatically every time the container starts:

*   **SVT_AV1_THREADS=4**
    *   Sets AV1 encoder to use 4 threads (matches OptiPlex 4 cores).
    *   *Benefit:* Prevents thread contention, improving stability.
*   **SVT_AV1_TILES=2x1**
    *   Sets tile layout for efficient parallelization on limited cores.
    *   *Benefit:* Better frame distribution across threads.
*   **SVT_AV1_TIER=1**
    *   Sets AV1 encoding tier. Lower tier = faster encode, less CPU.
    *   *Benefit:* Reduced complexity for software encoding.
*   **GST_DEBUG=no** & **GST_DEBUG_NO_COLOR=1**
    *   Disables verbose debug logging.
    *   *Benefit:* Less CPU overhead for I/O operations.

**Status:** ✅ These are already active in `docker-deployment/control-panel/Dockerfile`.

---

## ⚙️ Host-Level Optimizations (Manual)

The following optimizations require running a script on the **host operating system** (Ubuntu) *outside* of Docker.

> **Note:** Be cautious when modifying system-level settings (CPU governor, kernel parameters). These affect the entire system, not just the stream.

### Recommended Script
Run the provided optimization script:
```bash
sudo docker-deployment/control-panel/scripts/optimize-optiplex.sh
```

This script applies:
*   CPU Governor: Sets to `performance`
*   Kernel Schedulers: Sets I/O to `deadline`
*   Systemd Services: Disables CUPS, Bluetooth, Avahi
*   Kernel Parameters: Optimizes TCP buffer sizes for streaming
*   Thermal Management: Configures aggressive runtime for small form factor

### What NOT to do
*   **Do NOT** manually change CPU governor to `performance` if your OptiPlex runs hot or has poor cooling. The script handles this, but you should monitor thermals.
*   **Do NOT** run optimization scripts repeatedly. They are one-time setup.

---

## 🎯 Critical Fixes Implemented

### 1. Fixed GStreamer Pipeline Linking
*   **Issue:** `videoscale` element cannot handle frame rate conversion (144Hz -> 60Hz).
*   **Fix:** Added `videorate drop-only=true` element before `videoscale`.
*   **Files:** `stream-vp9.sh`, `stream-av1-optiplex.sh`, `stream-1080p-downscale.sh`.
*   **Status:** ✅ Deployed.

### 2. Fixed GStreamer "opusenc" Property
*   **Issue:** `application=audio` property deprecated in GStreamer 1.22+.
*   **Fix:** Changed to `audio-type=generic`.
*   **Files:** All streaming scripts.
*   **Status:** ✅ Deployed.

### 3. Fixed Memory Leaks (Web Dashboard)
*   **Issue:**
    *   Log file (`/app/logs/stream.log`) was read entirely into RAM every 2 seconds.
    *   Stream start process left file descriptor open (not closing it).
*   **Fix:**
    *   Use system `tail` command to read last 50 lines efficiently.
    *   Use `with open(...)` context manager to ensure file handles close.
*   **Impact:** Control panel remains stable with negligible memory usage over time.
*   **Status:** ✅ Deployed.

### 4. Fixed "whipsink" Deprecation
*   **Issue:** `whipsink` element is deprecated and fails with VP9 payload negotiation.
*   **Fix:** Migrated to `whipclientsink` (part of `gst-plugin-webrtc`).
*   **Files:** All scripts, Dockerfile.
*   **Status:** ✅ Deployed.

---

## 📊 Performance Expectations

### OptiPlex 7070-570X4 (Pentium G3250T)
*   **Target:** 720p @ 60fps (VP9)
*   **Expected CPU:** 35-45%
*   **Expected Bandwidth:** 4-6 Mbps

### Hardware Upgrade Impact
*   **Current:** 4 Cores, 3.5GHz, 8GB RAM
*   **To 1080p @ 60fps:** Consider 6+ Core CPU or Intel Arc (Hardware AV1).
*   **To AV1 @ 720p:** Same CPU but ~25% more load (SVT-AV1).

---

## 🔧 Troubleshooting Performance

### High CPU Usage (>60%)
1.  Verify resolution is 720p.
2.  Check if `stream-vp9.sh` is selected (not AV1).
3.  Ensure CPU governor is set to `performance` (run `optimize-optiplex.sh`).

### Thermal Throttling
If the stream drops frames or quality degrades randomly:
1.  Check mini PC vents for dust.
2.  Ensure ambient temperature is < 30°C.
3.  Do not block airflow around the small form factor.
4.  Consider lowering bitrate to 3500 Kbps.

---

## 🚨 Warnings

1.  **Build Cache Corruption:** If `docker build` fails with "parent snapshot does not exist", run:
    ```bash
    ./update.sh --repair
    ```
2.  **System Instability:** If applying kernel parameters causes instability, reboot and they will reset to defaults (unless persisted in `/etc/sysctl.d/`).

---

**Summary:** The most critical path-based and memory optimizations are already active in the container. Host-level tuning is available via `optimize-optiplex.sh` but should be applied carefully.
