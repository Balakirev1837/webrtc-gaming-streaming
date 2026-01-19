FROM fedora:38

# Install dependencies
# We enable RPM Fusion free/nonfree to ensure we get all codecs if possible, 
# though we try to stick to what the original script used.
RUN dnf install -y 'dnf-command(config-manager)' && \
    dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm && \
    dnf install -y https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm && \
    dnf update -y && \
    dnf install -y \
    python3 python3-pip \
    gstreamer1-plugins-base gstreamer1-plugins-good \
    gstreamer1-plugins-bad-free gstreamer1-plugins-bad-free-extras \
    gstreamer1-plugins-ugly gstreamer1-libav \
    gstreamer1-vaapi \
    svt-av1-tools \
    rav1e \
    v4l-utils ffmpeg \
    procps-ng \
    pulseaudio-utils \
    curl \
    && dnf clean all

# Install Python deps
RUN pip3 install flask psutil

# Create app directory
WORKDIR /app
RUN mkdir -p /app/scripts /app/config /app/templates

# Copy application files
COPY stream-control.py /app/
COPY templates /app/templates/
COPY scripts /app/scripts/

# Make scripts executable
RUN chmod +x /app/scripts/*.sh

# Create a non-root user (optional, but good practice, though we need video access)
# We will run as root for simplicity with device access for now, 
# or rely on 'docker run --user' if needed.
# But GStreamer often needs access to /dev/video* and /run/user/1000/pulse.
# Running as root inside container is easiest for accessing devices mapped from host.

# Environment variables
ENV PYTHONUNBUFFERED=1
# Since we use network_mode: "host", we point to localhost
ENV SERVER_URL=http://localhost:8080/api/whip

# Expose control panel port
EXPOSE 8081

# Entrypoint
CMD ["python3", "stream-control.py"]
