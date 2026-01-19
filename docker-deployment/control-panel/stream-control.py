#!/usr/bin/env python3
"""
Container-friendly web control panel for streaming
"""

import subprocess
import json
import os
import psutil
import time
import signal
from flask import Flask, render_template, jsonify, request
from pathlib import Path

app = Flask(__name__)

# Configuration
STREAM_DIR = Path("/app/scripts")
CONFIG_DIR = Path("/app/config")
CONFIG_FILE = CONFIG_DIR / "stream_config.json"
PID_FILE = CONFIG_DIR / "stream.pid"

# Ensure directories exist
CONFIG_DIR.mkdir(parents=True, exist_ok=True)

# Optimize for CPU efficiency
STATS_POLL_INTERVAL = 5
STATUS_POLL_INTERVAL = 5

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
        "recommended": False,
    },
    "vp9": {
        "name": "VP9 (OptiPlex Default - 1440p→720p)",
        "script": "stream-vp9.sh",
        "type": "software",
        "codec": "VP9",
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
    "selected_script": "vp9",
    "bitrate": 5000,
    "resolution": "1280x720",
    "fps": 60,
    "audio_bitrate": 192,
    "stream_key": "gaming",
    "auto_start": False,
}


def get_system_stats():
    """Get system statistics"""
    cpu_percent = psutil.cpu_percent(interval=0.1)
    memory = psutil.virtual_memory()
    net_io = psutil.net_io_counters()

    gpu_info = None
    try:
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
    streaming = False

    # Check PID file
    if PID_FILE.exists():
        try:
            pid = int(PID_FILE.read_text().strip())
            if psutil.pid_exists(pid):
                streaming = True
            else:
                # Stale PID file
                PID_FILE.unlink(missing_ok=True)
        except:
            PID_FILE.unlink(missing_ok=True)

    # Check Broadcast Box
    broadcast_box_active = False
    stream_info = None
    try:
        # Check if broadcast-box is reachable
        # Since we use network_mode: "host", we access via localhost
        result = subprocess.run(
            ["curl", "-s", "http://localhost:8080/api/status"],
            capture_output=True,
            text=True,
            timeout=2,
        )
        if result.returncode == 0:
            broadcast_box_active = True
            stream_info = json.loads(result.stdout)
    except:
        # Try localhost if not in docker network yet (fallback)
        try:
            result = subprocess.run(
                ["curl", "-s", "http://localhost:8080/api/status"],
                capture_output=True,
                text=True,
                timeout=1,
            )
            if result.returncode == 0:
                broadcast_box_active = True
                stream_info = json.loads(result.stdout)
        except:
            pass

    return {
        "streaming": streaming,
        "broadcast_box": broadcast_box_active,
        "stream_info": stream_info,
    }


def load_config():
    """Load stream configuration"""
    if CONFIG_FILE.exists():
        try:
            with open(CONFIG_FILE, "r") as f:
                return {**DEFAULT_CONFIG, **json.load(f)}
        except:
            pass
    return DEFAULT_CONFIG.copy()


def save_config(config):
    """Save stream configuration"""
    with open(CONFIG_FILE, "w") as f:
        json.dump(config, f, indent=2)


def start_stream(script_id, config):
    """Start streaming with specified script"""
    if script_id not in STREAMING_SCRIPTS:
        return {"success": False, "error": "Invalid script"}

    # Stop existing stream if running
    stop_stream()

    try:
        script_info = STREAMING_SCRIPTS[script_id]
        script_path = STREAM_DIR / script_info["script"]

        # Prepare environment
        env = os.environ.copy()
        env["STREAM_KEY"] = config["stream_key"]
        env["SERVER_URL"] = "http://localhost:8080/api/whip"
        env["VIDEO_DEVICE"] = "/dev/video0"
        env["RESOLUTION"] = config["resolution"]
        env["BITRATE"] = str(config["bitrate"])
        env["FPS"] = str(config["fps"])

        # Start process
        process = subprocess.Popen(
            [str(script_path)],
            env=env,
            cwd=str(STREAM_DIR),
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            start_new_session=True,
        )

        # Save PID
        PID_FILE.write_text(str(process.pid))

        save_config(config)
        return {"success": True}
    except Exception as e:
        return {"success": False, "error": str(e)}


def stop_stream():
    """Stop streaming"""
    try:
        if PID_FILE.exists():
            pid = int(PID_FILE.read_text().strip())
            try:
                os.kill(pid, signal.SIGTERM)
                # Wait a bit
                time.sleep(1)
                if psutil.pid_exists(pid):
                    os.kill(pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
            finally:
                PID_FILE.unlink(missing_ok=True)

        # Also try to kill gst-launch-1.0 processes to be safe
        subprocess.run(["pkill", "-f", "gst-launch-1.0"])

        return {"success": True}
    except Exception as e:
        return {"success": False, "error": str(e)}


def restart_stream():
    """Restart streaming"""
    config = load_config()
    stop_stream()
    time.sleep(2)
    return start_stream(config.get("selected_script", "vp9"), config)


def detect_av1_support():
    """Detect AV1 encoder support"""
    supported = {}
    for script_id, script_info in STREAMING_SCRIPTS.items():
        script_path = STREAM_DIR / script_info["script"]
        supported[script_id] = script_path.exists()
    return supported


@app.route("/")
def index():
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
    return jsonify(get_system_stats())


@app.route("/api/status")
def api_status():
    return jsonify(get_stream_status())


@app.route("/api/config", methods=["GET", "POST"])
def api_config():
    if request.method == "GET":
        return jsonify(load_config())
    else:
        config = request.json
        save_config(config)
        return jsonify({"success": True})


@app.route("/api/stream/start", methods=["POST"])
def api_start_stream():
    data = request.json
    script_id = data.get("script_id")
    config = data.get("config", load_config())
    return jsonify(start_stream(script_id, config))


@app.route("/api/stream/stop", methods=["POST"])
def api_stop_stream():
    return jsonify(stop_stream())


@app.route("/api/stream/restart", methods=["POST"])
def api_restart_stream():
    return jsonify(restart_stream())


@app.route("/api/stream/toggle", methods=["POST"])
def api_toggle_stream():
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
    return jsonify({"scripts": STREAMING_SCRIPTS, "supported": detect_av1_support()})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8081, debug=False)
