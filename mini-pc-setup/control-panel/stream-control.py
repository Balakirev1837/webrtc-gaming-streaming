#!/usr/bin/env python3
"""
Simple web control panel for headless mini PC streaming server
"""

import subprocess
import json
import os
import psutil
import time
from flask import Flask, render_template, jsonify, request
from pathlib import Path

app = Flask(__name__)

# Configuration
STREAM_DIR = Path.home() / "streaming"
CONFIG_DIR = STREAM_DIR / "config"
CONFIG_FILE = CONFIG_DIR / "stream_config.json"

# Optimize for CPU efficiency
# Reduce polling frequency for headless streaming PC
STATS_POLL_INTERVAL = 5  # Seconds (was 2)
STATUS_POLL_INTERVAL = 5  # Seconds (was 2)

# Streaming scripts
STREAMING_SCRIPTS = {
    "av1-nvenc": {
        "name": "AV1 (NVENC - RTX 40-series)",
        "script": "stream-av1-nvenc.sh",
        "type": "hardware",
        "codec": "AV1",
        "recommended": False,
    },
    "av1-vaapi": {
        "name": "AV1 (VA-API - Intel Arc/AMD RDNA3)",
        "script": "stream-av1-vaapi.sh",
        "type": "hardware",
        "codec": "AV1",
        "recommended": False,
    },
    "av1-svt": {
        "name": "AV1 (SVT-AV1 - Software)",
        "script": "stream-av1-svt.sh",
        "type": "software",
        "codec": "AV1",
        "recommended": False,
    },
    "av1-optiplex": {
        "name": "AV1 (OptiPlex - 1440p→720p)",
        "script": "stream-av1-optiplex.sh",
        "type": "software",
        "codec": "AV1",
        "recommended": True,
    },
    "av1-rav1e": {
        "name": "AV1 (RAV1E - Software)",
        "script": "stream-av1.sh",
        "type": "software",
        "codec": "AV1",
        "recommended": False,
    },
    "downscale-av1": {
        "name": "AV1 (1440p@144Hz → 1080p@60Hz)",
        "script": "stream-1080p-downscale.sh",
        "type": "software",
        "codec": "AV1",
        "recommended": False,
    },
    "h264-vaapi": {
        "name": "H.264 (VA-API - Intel/AMD)",
        "script": "stream.sh",
        "type": "hardware",
        "codec": "H.264",
        "recommended": False,
    },
    "h264-nvenc": {
        "name": "H.264 (NVENC - NVIDIA)",
        "script": "stream-nvenc.sh",
        "type": "hardware",
        "codec": "H.264",
        "recommended": False,
    },
}

# Default configuration
DEFAULT_CONFIG = {
    "selected_script": "av1-optiplex",
    "bitrate": 4000,
    "resolution": "1280x720",
    "fps": 60,
    "audio_bitrate": 192,
    "stream_key": "gaming",
    "auto_start": False,
}


def get_system_stats():
    """Get system statistics (optimized for CPU efficiency)"""
    # Use shorter interval for faster polling
    cpu_percent = psutil.cpu_percent(interval=0.1)
    memory = psutil.virtual_memory()
    # Skip disk check (saves CPU)

    # Network stats (cached to reduce overhead)
    net_io = psutil.net_io_counters()

    # Get GPU info if available (cached)
    gpu_info = None
    try:
        # Only query GPU every 10th call to save CPU
        if (
            not hasattr(get_system_stats, "gpu_cache")
            or (time.time() - getattr(get_system_stats, "gpu_time", 0)) > 50
        ):
            result = subprocess.run(
                [
                    "nvidia-smi",
                    "--query-gpu=name,utilization.gpu,temperature.gpu",
                    "--format=csv,noheader",
                ],
                capture_output=True,
                text=True,
                timeout=5,
            )
            if result.returncode == 0:
                parts = result.stdout.strip().split(", ")
                gpu_info = {
                    "name": parts[0],
                    "utilization": int(parts[1].split()[0]),
                    "temperature": int(parts[2].split()[0]),
                }
                get_system_stats.gpu_cache = gpu_info
                get_system_stats.gpu_time = time.time()
            else:
                gpu_info = getattr(get_system_stats, "gpu_cache", None)
        else:
            gpu_info = getattr(get_system_stats, "gpu_cache", None)
    except:
        pass

    return {
        "cpu": cpu_percent,
        "memory": memory.percent,
        "network": {"bytes_sent": net_io.bytes_sent, "bytes_recv": net_io.bytes_recv},
        "gpu": gpu_info,
    }


def get_stream_status():
    """Get current streaming status"""
    try:
        # Check if streaming service is running
        result = subprocess.run(
            ["systemctl", "is-active", "gaming-stream-av1"],
            capture_output=True,
            text=True,
        )
        stream_active = result.stdout.strip() == "active"

        # Get Broadcast Box status
        result = subprocess.run(
            ["systemctl", "is-active", "broadcast-box"], capture_output=True, text=True
        )
        broadcast_box_active = result.stdout.strip() == "active"

        # Check Broadcast Box API
        stream_info = None
        if broadcast_box_active:
            try:
                result = subprocess.run(
                    ["curl", "-s", "http://localhost:8080/api/status"],
                    capture_output=True,
                    text=True,
                    timeout=5,
                )
                if result.returncode == 0:
                    stream_info = json.loads(result.stdout)
            except:
                pass

        return {
            "streaming": stream_active,
            "broadcast_box": broadcast_box_active,
            "stream_info": stream_info,
        }
    except:
        return {"streaming": False, "broadcast_box": False, "stream_info": None}


def load_config():
    """Load stream configuration"""
    CONFIG_DIR.mkdir(parents=True, exist_ok=True)

    if CONFIG_FILE.exists():
        try:
            with open(CONFIG_FILE, "r") as f:
                return {**DEFAULT_CONFIG, **json.load(f)}
        except:
            pass

    return DEFAULT_CONFIG.copy()


def save_config(config):
    """Save stream configuration"""
    CONFIG_DIR.mkdir(parents=True, exist_ok=True)
    with open(CONFIG_FILE, "w") as f:
        json.dump(config, f, indent=2)


def start_stream(script_id, config):
    """Start streaming with specified script"""
    if script_id not in STREAMING_SCRIPTS:
        return {"success": False, "error": "Invalid script"}

    try:
        # Update systemd service
        script_info = STREAMING_SCRIPTS[script_id]
        service_file = f"""[Unit]
Description=Gaming WebRTC Stream ({script_info["name"]})
Requires=broadcast-box.service
After=broadcast-box.service

[Service]
Type=simple
User={os.getlogin()}
WorkingDirectory={STREAM_DIR}
Environment="STREAM_KEY={config["stream_key"]}"
Environment="SERVER_URL=http://localhost:8080/api/whip"
Environment="VIDEO_DEVICE=/dev/video0"
ExecStart={STREAM_DIR / script_info["script"]}
Restart=always
RestartSec=5

NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths={STREAM_DIR}

[Install]
WantedBy=multi-user.target
"""

        service_path = Path("/etc/systemd/system/gaming-stream-av1.service")
        subprocess.run(
            ["sudo", "tee", str(service_path)], input=service_file.encode(), check=True
        )
        subprocess.run(["sudo", "systemctl", "daemon-reload"], check=True)
        subprocess.run(["sudo", "systemctl", "start", "gaming-stream-av1"], check=True)

        save_config(config)
        return {"success": True}
    except Exception as e:
        return {"success": False, "error": str(e)}


def stop_stream():
    """Stop streaming"""
    try:
        subprocess.run(["sudo", "systemctl", "stop", "gaming-stream-av1"], check=True)
        return {"success": True}
    except Exception as e:
        return {"success": False, "error": str(e)}


def restart_stream():
    """Restart streaming"""
    try:
        subprocess.run(
            ["sudo", "systemctl", "restart", "gaming-stream-av1"], check=True
        )
        return {"success": True}
    except Exception as e:
        return {"success": False, "error": str(e)}


def detect_av1_support():
    """Detect AV1 encoder support"""
    supported = {}

    for script_id, script_info in STREAMING_SCRIPTS.items():
        script_path = STREAM_DIR / script_info["script"]
        if script_path.exists():
            supported[script_id] = True
        else:
            supported[script_id] = False

    return supported


@app.route("/")
def index():
    """Main control panel"""
    config = load_config()
    stats = get_system_stats()
    status = get_stream_status()
    supported_scripts = detect_av1_support()

    return render_template(
        "control_panel.html",
        config=config,
        stats=stats,
        status=status,
        scripts=STREAMING_SCRIPTS,
        supported_scripts=supported_scripts,
    )


@app.route("/api/stats")
def api_stats():
    """API: Get system statistics"""
    return jsonify(get_system_stats())


@app.route("/api/status")
def api_status():
    """API: Get streaming status"""
    return jsonify(get_stream_status())


@app.route("/api/config", methods=["GET", "POST"])
def api_config():
    """API: Get or update configuration"""
    if request.method == "GET":
        return jsonify(load_config())
    else:
        config = request.json
        save_config(config)
        return jsonify({"success": True})


@app.route("/api/stream/start", methods=["POST"])
def api_start_stream():
    """API: Start streaming"""
    data = request.json
    script_id = data.get("script_id")
    config = data.get("config", load_config())
    return jsonify(start_stream(script_id, config))


@app.route("/api/stream/stop", methods=["POST"])
def api_stop_stream():
    """API: Stop streaming"""
    return jsonify(stop_stream())


@app.route("/api/stream/restart", methods=["POST"])
def api_restart_stream():
    """API: Restart streaming"""
    return jsonify(restart_stream())


@app.route("/api/stream/toggle", methods=["POST"])
def api_toggle_stream():
    """API: Toggle streaming on/off"""
    status = get_stream_status()
    if status["streaming"]:
        return jsonify(stop_stream())
    else:
        data = request.json
        script_id = data.get("script_id")
        config = data.get("config", load_config())
        return jsonify(start_stream(script_id, config))


@app.route("/api/scripts")
def api_scripts():
    """API: Get available streaming scripts"""
    return jsonify({"scripts": STREAMING_SCRIPTS, "supported": detect_av1_support()})


if __name__ == "__main__":
    STREAM_DIR.mkdir(parents=True, exist_ok=True)

    # Run on port 8081 (Broadcast Box uses 8080)
    app.run(host="0.0.0.0", port=8081, debug=False)
