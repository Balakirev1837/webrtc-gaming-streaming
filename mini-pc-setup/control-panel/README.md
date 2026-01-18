# Stream Control Panel

A web-based control panel for headless mini PC streaming servers. Manage your AV1/H.264 streaming from any device on your network.

## Features

- 🎬 **Script Selection** - Choose between AV1 and H.264 encoders
- ⚙️ **Stream Settings** - Adjust bitrate, resolution, FPS, audio bitrate
- 🎮 **Stream Control** - Start, stop, restart, and toggle streaming
- 📊 **System Monitoring** - Real-time CPU, GPU, memory usage
- 📺 **Stream URL** - Get viewer URL with one-click copy
- 📝 **Activity Log** - Track streaming operations

## Quick Start

### Install Control Panel

```bash
cd ~/mini-pc-setup/control-panel
chmod +x install-control-panel.sh
./install-control-panel.sh
```

### Access the Panel

Open your browser on any device:

```
http://mini-pc-ip:8081
```

Or with mDNS:

```
http://mini-pc.local:8081
```

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Mini PC (Headless)                      │
│                                                             │
│  ┌──────────────┐      ┌──────────────────┐             │
│  │ Stream       │─────→│ Stream Control  │             │
│  │ Scripts      │      │ Panel (Flask)   │             │
│  └──────────────┘      │    Port 8081    │             │
│                        └────────┬─────────┘             │
│                                 │                        │
│                                 │ HTTP                  │
│                                 ↓                        │
│  ┌──────────────────────────────────────┐            │
│  │         Any Browser              │            │
│  │  - Select encoder               │            │
│  │  - Configure stream            │            │
│  │  - Start/stop/restart         │            │
│  │  - Monitor system             │            │
│  └──────────────────────────────────────┘            │
│                                                             │
│  ┌──────────────┐      ┌──────────────────┐             │
│  │ systemd     │      │ Broadcast Box   │             │
│  │ Services    │◄─────│    Port 8080    │             │
│  └──────────────┘      └──────────────────┘             │
└─────────────────────────────────────────────────────────────┘
```

## Usage

### 1. Select Streaming Script

Choose from available encoders:

**AV1 Encoders:**
- AV1 (NVENC) - RTX 40-series hardware
- AV1 (VA-API) - Intel Arc / AMD RDNA3 hardware
- AV1 (SVT-AV1) - Fast software encoding
- AV1 (OptiPlex - 1440p→720p) - **Recommended for OptiPlex**: Direct downscale, 45-60% CPU
- AV1 (1440p→1080p) - For higher-end hardware (6+ cores)
- AV1 (RAV1E) - Alternative software encoding

**H.264 Fallbacks:**
- H.264 (VA-API) - Intel/AMD hardware
- H.264 (NVENC) - NVIDIA hardware

### 2. Configure Stream

- **Stream Key** - Identifier for your stream (default: "gaming")
- **Resolution** - 1080p, 720p, 1440p
- **Frame Rate** - 60 FPS or 30 FPS
- **Video Bitrate** - 2000-15000 Kbps (adjust for quality/latency)
- **Audio Bitrate** - 64-320 Kbps

### 3. Control Stream

- **Toggle Stream** - One-click start or stop streaming
- **Restart** - Restart current stream (only when streaming)
- **Stop** - Stop streaming (only when streaming)

### 4. Monitor System

Real-time stats:
- CPU usage
- Memory usage
- GPU utilization (if available)
- Stream status
- Broadcast Box status

### 5. Share Stream

Copy the stream URL and share with viewers:

```
http://mini-pc-ip:8080/gaming
```

## API Endpoints

The control panel exposes a REST API:

### GET `/api/stats`
Get system statistics
```json
{
  "cpu": 25.5,
  "memory": 42.3,
  "disk": 65.2,
  "network": {
    "bytes_sent": 1234567,
    "bytes_recv": 9876543
  },
  "gpu": {
    "name": "NVIDIA GeForce RTX 4060",
    "utilization": 45,
    "temperature": 65
  }
}
```

### GET `/api/status`
Get streaming status
```json
{
  "streaming": true,
  "broadcast_box": true,
  "stream_info": {...}
}
```

### GET `/api/config`
Get stream configuration
```json
{
  "selected_script": "av1-svt",
  "bitrate": 6000,
  "resolution": "1920x1080",
  "fps": 60,
  "audio_bitrate": 192,
  "stream_key": "gaming",
  "auto_start": false
}
```

### POST `/api/config`
Update stream configuration
```json
{
  "bitrate": 8000,
  "resolution": "1920x1080"
}
```

### POST `/api/stream/start`
Start streaming
```json
{
  "script_id": "av1-svt",
  "config": {...}
}
```

### POST `/api/stream/stop`
Stop streaming

### POST `/api/stream/restart`
Restart streaming

### POST `/api/stream/toggle`
Toggle streaming on/off
```json
{
  "script_id": "av1-svt",
  "config": {...}
}
```
If streaming is active, stops the stream. If inactive, starts with specified script and config.

### GET `/api/scripts`
Get available scripts
```json
{
  "scripts": {
    "av1-svt": {...},
    "av1-nvenc": {...}
  },
  "supported": {
    "av1-svt": true,
    "av1-nvenc": false
  }
}
```

## File Structure

```
control-panel/
├── stream-control.py              # Flask application
├── install-control-panel.sh        # Installation script
├── templates/
│   └── control_panel.html       # Web interface
└── README.md                    # This file
```

## Configuration

The control panel stores configuration in:
```
~/streaming/config/stream_config.json
```

Edit manually if needed:
```json
{
  "selected_script": "av1-svt",
  "bitrate": 6000,
  "resolution": "1920x1080",
  "fps": 60,
  "audio_bitrate": 192,
  "stream_key": "gaming",
  "auto_start": false
}
```

## Service Management

### Start/Stop Control Panel

```bash
# Start
sudo systemctl start stream-control

# Stop
sudo systemctl stop stream-control

# Restart
sudo systemctl restart stream-control

# Enable at boot
sudo systemctl enable stream-control

# Check status
sudo systemctl status stream-control

# View logs
sudo journalctl -u stream-control -f
```

## Troubleshooting

### Control Panel Won't Start

```bash
# Check logs
sudo journalctl -u stream-control -n 50

# Common issues:
# 1. Port 8081 in use
sudo lsof -i :8081

# 2. Python dependencies missing
pip3 install --user flask psutil requests

# 3. Permissions
sudo usermod -a -G video $USER
```

### Can't Access Web Interface

```bash
# Check service is running
sudo systemctl status stream-control

# Check firewall
sudo firewall-cmd --list-all
sudo firewall-cmd --permanent --add-port=8081/tcp
sudo firewall-cmd --reload

# Test locally
curl http://localhost:8081
```

### Scripts Not Detected

```bash
# Check scripts are in correct location
ls -l ~/streaming/stream-*.sh

# Scripts should be executable
chmod +x ~/streaming/stream-*.sh
```

### Stream Won't Start

```bash
# Check control panel logs
sudo journalctl -u stream-control -f

# Check streaming service logs
sudo journalctl -u gaming-stream-av1 -f

# Manual test
cd ~/streaming
./stream-av1-svt.sh
```

## Security

### Authentication (Optional)

Add basic authentication:

```python
# In stream-control.py
from flask_httpauth import HTTPBasicAuth
auth = HTTPBasicAuth()

@auth.verify_password
def verify_password(username, password):
    return username == 'admin' and password == 'your-password'

@app.route('/')
@auth.login_required
def index():
    ...
```

### HTTPS (Optional)

Use reverse proxy with SSL:

```nginx
server {
    listen 443 ssl;
    server_name stream-control.local;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location / {
        proxy_pass http://localhost:8081;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### Network Isolation

Control panel is accessible on local network only. Restrict further:

```bash
# Allow only specific IPs
sudo firewall-cmd --permanent --add-rich-rule='
  rule family="ipv4" 
  source address="192.168.1.0/24" 
  port port="8081" 
  protocol="tcp" 
  accept'
```

## Advanced Features

### Auto-Start Stream

Configure auto-start:

```json
{
  "auto_start": true,
  "selected_script": "av1-svt"
}
```

### Multiple Stream Keys

Create multiple stream configurations for different games or viewers:

```bash
# Gaming stream
http://mini-pc-ip:8080/gaming

# Testing stream
http://mini-pc-ip:8080/testing

# Family stream
http://mini-pc-ip:8080/family
```

### Stream Recording Integration

Add to streaming scripts:
```bash
tee name=t ! queue ! rtpav1pay ! ... ! whipsink
t. ! queue ! filesink location=recording.av1
```

## Performance

### Resource Usage

**Control Panel (Python/Flask):**
- CPU: < 1%
- Memory: ~50 MB
- Network: Negligible

**Recommended Hardware:**
- 2 CPU cores minimum
- 1 GB RAM minimum
- 100 MB free disk space

### Scalability

Supports multiple concurrent browsers accessing the control panel without performance impact.

## Development

### Adding New Streaming Scripts

1. Add script to `STREAMING_SCRIPTS` in `stream-control.py`
2. Copy script to `~/streaming/`
3. Restart control panel

### Modifying UI

Edit `templates/control_panel.html` - it's vanilla HTML/CSS/JavaScript.

## Support

- Check logs: `sudo journalctl -u stream-control -f`
- API documentation: See endpoints above
- Broadcasting: Broadcast Box - https://github.com/Glimesh/broadcast-box

## License

MIT License - Free to modify and distribute.
