# Single-stage Dockerfile for WebRTC Gaming Streaming
# Uses standard GStreamer packages with whipclientsink (stable)
FROM fedora:40

# Install runtime dependencies
RUN dnf install -y 'dnf-command(config-manager)' && \
    dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm && \
    dnf install -y https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm && \
    dnf update -y && \
    dnf install -y \
    python3 python3-pip \
    gstreamer1-plugins-base \
    gstreamer1-plugins-good \
    gstreamer1-plugins-bad-free \
    gstreamer1-plugins-bad-free-extras \
    gstreamer1-plugins-ugly \
    gstreamer1-libav \
    gstreamer1-vaapi \
    svt-av1 \
    rav1e \
    v4l-utils \
    ffmpeg \
    procps-ng \
    pulseaudio-utils \
    curl \
    && dnf clean all && \
    rm -rf /var/cache/dnf /var/lib/dnf

# Install Python dependencies
RUN pip3 install --no-cache-dir flask psutil requests flask-socketio

# Create app directory
WORKDIR /app
RUN mkdir -p /app/scripts /app/config /app/templates /app/logs

# Copy application files
COPY stream-control.py /app/
COPY templates /app/templates/
COPY scripts /app/scripts/

# Make scripts executable
RUN chmod +x /app/scripts/*.sh

# Create non-root user
RUN useradd -m -u 1000 streamer && \
    chown -R streamer:streamer /app

# Switch to non-root user
USER streamer

# Environment variables
ENV PYTHONUNBUFFERED=1
ENV GST_DEBUG=no
ENV GST_DEBUG_NO_COLOR=1
ENV SVT_AV1_THREADS=4
ENV SVT_AV1_TILES=2x1
ENV SVT_AV1_TIER=1
ENV SERVER_URL=http://localhost:8080/api/whip

# Expose control panel port
EXPOSE 8081

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8081/ || exit 1

# Entrypoint
CMD ["python3", "stream-control.py"]
