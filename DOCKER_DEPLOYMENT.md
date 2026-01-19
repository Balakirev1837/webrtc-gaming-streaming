# Docker Deployment Guide (Recommended)

This guide describes how to deploy the WebRTC Gaming Streaming solution using Docker. This method is more stable, portable, and easier to manage than the manual script-based deployment.

## 🚀 Quick Start with Docker

### Prerequisites
1. **Docker & Docker Compose** installed on your mini PC.
   ```bash
   # Fedora
   sudo dnf install -y docker docker-compose
   sudo systemctl enable --now docker
   
   # Ubuntu
   sudo apt install -y docker.io docker-compose
   ```
2. **User Permissions**: Ensure your user is in the `docker` and `video` groups.
   ```bash
   sudo usermod -aG docker,video $USER
   newgrp docker
   ```

### Deployment Steps

1. **Clone the repository** (if you haven't already):
   ```bash
   git clone https://github.com/Balakirev1837/webrtc-gaming-streaming.git
   cd webrtc-gaming-streaming
   ```

2. **Navigate to the Docker deployment directory**:
   ```bash
   cd docker-deployment
   ```

3. **Start the services**:
   ```bash
   docker-compose up -d --build
   ```

   This will:
   - Build the `streamer` container (includes Control Panel, GStreamer, drivers).
   - Pull the `broadcast-box` container.
   - Start both services in `host` network mode.

4. **Access the Application**:
   - **Viewer:** `http://<mini-pc-ip>:8080/gaming`
   - **Control Panel:** `http://<mini-pc-ip>:8081`

## ⚙️ Configuration

Configuration is persisted in the `config/` directory within `docker-deployment`.

- **Stream Config:** `config/stream_config.json` (Managed via Control Panel)
- **PulseAudio:** The container mounts the host's PulseAudio socket. 
  - **Important:** The `docker-compose.yml` assumes the host user ID is `1000`. If your user ID is different (check with `id -u`), update the volumes section in `docker-compose.yml`.
  - Also ensure the `~/.config/pulse/cookie` exists on the host.

### Environment Variables
You can modify `docker-compose.yml` to adjust environment variables:

- `SERVER_URL`: URL of the Broadcast Box WHIP endpoint. Since we use host networking, this is usually `http://localhost:8080/api/whip`.
- `PULSE_SERVER`: Path to PulseAudio socket (default: `unix:/run/user/1000/pulse/native`).

## 🛠️ Troubleshooting

**Audio issues:**
If audio isn't working:
1. Check your User ID on the host: `id -u`.
2. If it's not `1000`, update `docker-compose.yml` volumes: `- /run/user/<YOUR_ID>/pulse:/run/user/1000/pulse`.
3. Check if the PulseAudio cookie exists: `ls -l ~/.config/pulse/cookie`.
4. Ensure you are running `docker-compose` as a user who can read that cookie (or use `sudo -E docker-compose ...` to preserve environment, though editing the file is safer).

**Video devices:**
The container runs in `privileged` mode with `/dev` mapped to ensure access to capture cards and hardware encoders (VA-API/NVENC). If your capture card isn't found, check `ls -l /dev/video*` on the host.

**Logs:**
View logs for troubleshooting:
```bash
docker-compose logs -f streamer
docker-compose logs -f broadcast-box
```

## 🔄 Updating

To update the application:
```bash
git pull
docker-compose up -d --build
```
