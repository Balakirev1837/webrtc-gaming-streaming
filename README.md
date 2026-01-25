# Local WebRTC Gaming Streaming

🎮 **Stream your gaming PC to local viewers with sub-second latency using VP9/AV1 and WebRTC**

> **Perfect for:** Gaming at any resolution while family watches via a simple web bookmark. Supports 720p-1080p streaming. Optimized for low-power mini PCs like OptiPlex.

**Repository:** https://github.com/Balakirev1837/webrtc-gaming-streaming

---

## 🐳 Quick Start (Docker)

**The recommended way to run the project.**

1.  **Clone:**
    ```bash
    git clone https://github.com/Balakirev1837/webrtc-gaming-streaming.git
    cd webrtc-gaming-streaming/docker-deployment
    ```

2.  **Start:**
    ```bash
    docker compose up -d --build
    ```

3.  **Access:**
    *   **Stream:** `http://<mini-pc-ip>:8080/gaming`
    *   **Control:** `http://<mini-pc-ip>:8081`

See [Deployment Guide](docs/DEPLOYMENT.md) for full instructions.

---

## 📚 Documentation

*   **[Deployment Guide](docs/DEPLOYMENT.md):** Full Docker setup instructions.
*   **[User Guide](docs/USER_GUIDE.md):** How to use the Control Panel and Viewer.
*   **[Hardware Reference](docs/HARDWARE.md):** Supported Mini PCs, Capture Cards, and tuning.
*   **[Architecture](docs/ARCHITECTURE.md):** Technical details on AV1, VP9, and system design.
*   **[Legacy Setup](docs/LEGACY_SETUP.md):** Manual (non-Docker) installation guide.

---

## 🏗️ Architecture

```
Gaming PC (HDMI out)
    ↓
Capture Card (USB 3.0)
    ↓
Mini PC (Docker Container)
    ├─ GStreamer (Capture & Encode)
    ├─ Broadcast Box (WebRTC Server)
    └─ Control Panel (Web UI)
        ↓
    Local Network
        ↓
    Viewer (Browser)
```

## 📄 License
MIT License - Free to use and modify.
