# User Guide

## 🚀 Quick Start

### For You (The Streamer)
1.  **Start the Mini PC:** Ensure it's powered on.
2.  **Open Control Panel:** `http://<mini-pc-ip>:8081`
3.  **Check Status:** Ensure "Broadcast Box" is Running.
4.  **Start Stream:** Click **Start Stream** (or toggle on).
5.  **Monitor:** Watch CPU usage and stream status.

### For Viewers (Wife/Friends)
1.  **Open Link:** `http://<mini-pc-ip>:8080/gaming`
2.  **Bookmark It:** `Ctrl+D` (Chrome/Firefox/Edge)
3.  **Done!** The stream auto-connects.

---

## 🎮 Control Panel Features

The web interface (`:8081`) allows you to:
*   **Toggle Stream:** Start/Stop the GStreamer pipeline without SSH.
*   **Select Encoder:** Choose between VP9 (OptiPlex default), AV1, or H.264.
*   **Monitor Stats:** Real-time CPU, RAM, and GPU usage.
*   **View Logs:** Debug stream issues directly in the browser.

### Recommended Settings (OptiPlex)
*   **Script:** `VP9 (OptiPlex Default)`
*   **Resolution:** `1280x720`
*   **FPS:** `60`
*   **Bitrate:** `4000` - `5000` Kbps

---

## 📺 Viewer Features

The viewer page (`:8080/gaming`) is designed for zero-configuration usage.

*   **Auto-Connect:** Automatically retries if the stream drops.
*   **Picture Controls:** Hover over the top-right to adjust:
    *   Brightness
    *   Contrast
    *   Saturation
*   **Presets:** Quick toggles for "Normal", "Bright", and "Vivid".
*   **Shortcuts:**
    *   `F`: Fullscreen
    *   `R`: Force Refresh

---

## 🔧 Troubleshooting

### Stream Won't Start
1.  **Check Logs:** Look at the "Activity Log" in the Control Panel.
2.  **Common Errors:**
    *   `Device or resource busy`: Another process is using `/dev/video0`.
    *   `Permission denied`: Docker container doesn't have access to `/dev/video0` (Check `privileged: true` or group permissions).
    *   `whipsink not found`: The GStreamer plugin failed to load. Run `./update.sh --force` to rebuild.

### Viewer Can't Connect
1.  **Firewall:** Ensure ports `8080` (TCP/UDP) are open on the Mini PC.
2.  **Network:** Ensure both devices are on the same WiFi/Ethernet subnet.
3.  **Browser:** Try Chrome or Edge (best WebRTC support).

### Poor Quality / Stuttering
1.  **High CPU:** If CPU > 80%, switch to **720p**.
2.  **Bitrate:** Lower the bitrate to `3000` Kbps in the Control Panel.
3.  **Thermal:** Check if the Mini PC is overheating (vents blocked?).
