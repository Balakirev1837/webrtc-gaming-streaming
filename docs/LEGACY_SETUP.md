# Legacy Manual Setup Guide

> **Note:** This guide is for manual deployment without Docker. We highly recommend using the [Docker Deployment](./DEPLOYMENT.md) instead.

## 📋 Prerequisites
*   **OS:** Fedora 38+ or Ubuntu 22.04+
*   **User:** Sudo privileges
*   **Hardware:** [Hardware Checklist](./HARDWARE.md)

---

## 🚀 Quick Setup (Git)

1.  **Clone the Repo:**
    ```bash
    git clone https://github.com/Balakirev1837/webrtc-gaming-streaming.git
    cd webrtc-gaming-streaming
    ```

2.  **Run Setup Script:**
    ```bash
    cd mini-pc-setup
    sudo ./setup-mini-pc.sh
    # Follow prompts to install dependencies
    sudo reboot
    ```

3.  **Deploy Services:**
    ```bash
    cd mini-pc-setup
    ./deploy.sh
    ```

4.  **Start Streaming:**
    ```bash
    sudo systemctl start broadcast-box
    sudo systemctl start optiplex-stream
    ```

---

## 🛠️ Manual Configuration

### Systemd Services
Services are located in `/etc/systemd/system/`:
*   `broadcast-box.service`: The WebRTC server.
*   `optiplex-stream.service`: The GStreamer pipeline.

### Environment Variables
Edit the service files to change settings:
```ini
Environment="STREAM_KEY=gaming"
Environment="BITRATE=4000"
Environment="RESOLUTION=1280x720"
```

### Scripts
Streaming scripts are deployed to `~/streaming/`:
*   `stream-vp9.sh`: Default for OptiPlex.
*   `stream-av1-svt.sh`: Software AV1.
*   `stream-av1-vaapi.sh`: Hardware AV1 (Intel/AMD).

---

## 🧹 Uninstall
To remove the manual installation:
```bash
sudo systemctl disable --now broadcast-box optiplex-stream
sudo rm /etc/systemd/system/broadcast-box.service
sudo rm /etc/systemd/system/optiplex-stream.service
sudo systemctl daemon-reload
rm -rf ~/broadcast-box ~/streaming
```
