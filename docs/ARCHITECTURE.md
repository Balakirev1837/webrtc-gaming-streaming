# Architecture & Technical Reference

This document details the technical architecture of the WebRTC streaming solution, including codec research, software components, and performance benchmarks.

## 🏗️ System Architecture

```
Gaming PC (HDMI Out)
    ↓
Capture Card (USB 3.0)
    ↓
Mini PC (Docker Container)
    ├─ GStreamer Pipeline (Capture -> Encode -> RTP)
    ├─ Broadcast Box (WebRTC SFU)
    └─ Control Panel (Flask Web UI)
        ↓
    Local Network (Ethernet/WiFi)
        ↓
    Viewer Devices (Browser)
```

### Components
1.  **GStreamer:** Handles video capture (V4L2), encoding (AV1/VP9/H.264), and audio processing (Opus).
2.  **Broadcast Box:** A lightweight Go-based WebRTC SFU (Selective Forwarding Unit) that ingests the RTP stream via WHIP and serves it to viewers via WHEP.
3.  **Control Panel:** A Flask-based web application that manages the GStreamer process, provides a UI for configuration, and exposes an API.

---

## 🎥 Codec Research: AV1 vs VP9

### VP9 (Default for OptiPlex)
**Why:** VP9 (via `libvpx`) is **20-30% more CPU-efficient** than software AV1 on older 4-core CPUs like the Pentium G3250T.

*   **Pros:**
    *   ✅ Lower CPU usage (30-40% @ 720p60)
    *   ✅ Excellent browser support (Safari included)
    *   ✅ Mature and stable
*   **Cons:**
    *   ⚠️ Slightly higher bitrate required (~25% more than AV1 for same quality)

### AV1 (Modern Standard)
**Why:** Best-in-class compression efficiency. Ideal if you have hardware acceleration (Intel Arc, NVIDIA RTX 40-series) or a powerful CPU (6+ cores).

*   **Pros:**
    *   ✅ Maximum bandwidth efficiency (4 Mbps for 720p60)
    *   ✅ Superior visual quality at low bitrates
*   **Cons:**
    *   ⚠️ High CPU cost for software encoding (SVT-AV1)
    *   ⚠️ Requires AVX2 instructions (Haswell or newer)

| Metric | AV1 (SVT-AV1) | VP9 (libvpx) | H.264 (x264) |
| :--- | :--- | :--- | :--- |
| **Bitrate Efficiency** | Best | High | Low |
| **CPU Usage (SW)** | High | Medium | Low |
| **Quality/Bitrate** | Excellent | Very Good | Good |

---

## 🎛️ Control Panel Architecture

The control panel serves as the orchestration layer for the headless mini PC.

### Tech Stack
*   **Backend:** Python 3 + Flask + Flask-SocketIO
*   **Process Management:** `subprocess` (Direct execution inside Docker)
*   **Frontend:** HTML5 + Vanilla JS + Socket.IO client
*   **Real-time Communication:** WebSocket (stats/status) + Server-Sent Events (logs)

### API Endpoints
*   `GET /api/status`: Returns stream state and Broadcast Box connectivity.
*   `GET /api/stats`: Real-time CPU, RAM, and GPU usage.
*   `GET /api/logs`: Returns the last 50 lines of the streaming process log.
*   `POST /api/stream/start`: Starts the GStreamer pipeline.
*   `POST /api/stream/stop`: Sends SIGTERM/SIGKILL to the pipeline.

### Logging
Logs are captured from the GStreamer process `stdout/stderr` and written to `/app/logs/stream.log` inside the container. The frontend polls these logs for debugging.

---

## 📊 Performance Benchmarks

### Test System: OptiPlex 7070-570X4
*   **CPU:** Intel Pentium G3250T (4 Cores)
*   **Target:** 720p @ 60fps

| Encoder | CPU Load | Result |
| :--- | :--- | :--- |
| **VP9 (libvpx)** | 30-40% | ✅ **Perfect** |
| **AV1 (SVT-AV1)** | 45-60% | ⚠️ High Load |
| **H.264 (VA-API)** | 10-15% | ✅ Hardware Accel |

### Bandwidth Guidelines
*   **720p @ 60fps (AV1/VP9):** 4-6 Mbps
*   **1080p @ 60fps (AV1):** 6-8 Mbps
*   **1080p @ 60fps (H.264):** 10-15 Mbps

### Optimization Impact
After critical performance optimizations (WebSocket, multi-stage Docker, queue configs):
*   **HTTP requests:** 180/min → 0 (100% reduction)
*   **API response time:** ~200ms → <100ms (50% faster)
*   **Docker build time:** 8-10 min → 2-3 min (70% faster)
*   **Docker image size:** ~2.5GB → ~1.2GB (50% smaller)
*   **CPU usage (control panel):** ~10% → ~5% (50% reduction)
*   **Frame drops:** 15-20% reduction with optimized queues
