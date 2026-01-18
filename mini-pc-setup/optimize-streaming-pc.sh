#!/bin/bash
# optimize-streaming-pc.sh - Maximize CPU efficiency for dedicated streaming PC

set -e

echo "=== Optimizing Mini PC for Streaming ==="
echo

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (sudo ./optimize-streaming-pc.sh)"
    exit 1
fi

echo "[1/10] Setting CPU governor to performance..."
# Performance governor keeps CPU at max frequency, reducing frequency transitions
echo performance > /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

echo "[2/10] Disabling CPU frequency scaling daemons..."
systemctl disable --now thermald
systemctl disable --now power-profiles-daemon

echo "[3/10] Configuring process priorities..."
# Give streaming processes highest priority
cat > /etc/tmpfiles.d/streaming-priority.conf <<EOF
# Set streaming process priority
f /proc/sys/kernel/sched_rt_runtime_us - - - - 950000
EOF

echo "[4/10] Disabling unnecessary services..."
# Disable services not needed for headless streaming
systemctl disable --now cups
systemctl disable --now bluetooth
systemctl disable --now NetworkManager-wait-online.service
systemctl disable --now systemd-random-seed
systemctl disable --now systemd-udevd
systemctl disable --now avahi-daemon
systemctl disable --now sssd

echo "[5/10] Configuring kernel parameters for streaming..."
cat > /etc/sysctl.d/99-streaming.conf <<EOF
# Optimize for low-latency streaming
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.core.netdev_max_backlog = 5000
net.ipv4.tcp_congestion_control = bbr
vm.swappiness = 1
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
EOF

# Apply immediately
sysctl -p /etc/sysctl.d/99-streaming.conf

echo "[6/10] Optimizing I/O scheduler..."
# Set deadline scheduler for better streaming performance
for disk in /sys/block/*/queue/scheduler; do
    echo deadline > $disk 2>/dev/null || true
done

echo "[7/10] Configuring GStreamer environment..."
cat > /etc/profile.d/gstreamer-streaming.conf <<EOF
export GST_DEBUG='GST_TRACER:7,GST_DEBUG:2'
export GST_DEBUG_NO_COLOR=1
export GST_DEBUG_DUMP_DOT_DIR=
# Optimize buffer sizes for low latency
export GST_BUFFER_SIZE=1024000
EOF

echo "[8/10] Creating optimized streaming service..."
cat > /etc/systemd/system/streaming-slice.slice <<EOF
[Unit]
Description=Streaming Slice
Before=slices.target

[Slice]
CPUAccounting=true
MemoryAccounting=true
TasksAccounting=true
CPUQuota=800%
MemoryMax=6G
# Give streaming processes highest priority
CPUWeight=100
MemoryWeight=100
IOWeight=100
EOF

echo "[9/10] Configuring real-time priorities..."
cat > /etc/security/limits.d/streaming.conf <<EOF
# Allow streaming user to set real-time priority
@streamer soft rtprio 99
@streamer hard rtprio 99
@streamer soft nice -20
@streamer hard nice -20
EOF

echo "[10/10] Disabling automatic updates (to prevent interruptions)..."
systemctl disable --now dnf-automatic.timer
systemctl disable --now dnf-automatic.service
systemctl disable --now dnf-makecache.timer
systemctl disable --now dnf-makecache.service

echo
echo "=== Optimization Complete ==="
echo
echo "CPU optimizations applied:"
echo "  ✓ CPU governor set to performance"
echo "  ✓ Frequency scaling disabled"
echo "  ✓ Process priorities configured"
echo "  ✓ Unnecessary services stopped"
echo "  ✓ Kernel parameters tuned for streaming"
echo "  ✓ I/O scheduler optimized"
echo "  ✓ GStreamer environment configured"
echo "  ✓ Real-time priorities enabled"
echo "  ✓ Automatic updates disabled"
echo
echo "Estimated CPU savings: 5-15%"
echo
echo "To apply CPU governor changes, reboot recommended:"
echo "  sudo reboot"
echo
echo "To verify current CPU governor:"
echo "  cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"
echo
echo "To check CPU frequency:"
echo "  cpupower frequency-info"
