#!/bin/bash
# verify-cpu-efficiency.sh - Check CPU optimizations

echo "=== CPU Efficiency Verification ==="
echo

# Check CPU governor
echo "[1] CPU Governor:"
GOVERNOR=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "N/A")
echo "  Current: $GOVERNOR"
if [ "$GOVERNOR" = "performance" ]; then
    echo "  ✓ Optimal for streaming"
else
    echo "  ⚠  Should be 'performance' for streaming"
fi

echo
echo "[2] CPU Frequency Info:"
cpupower frequency-info | grep -E "(CPU min|CPU max|governor)" | head -10

echo
echo "[3] Disabled Services:"

# Check for disabled non-essential services
SERVICES=("cups" "bluetooth" "thermald" "power-profiles-daemon")
for service in "${SERVICES[@]}"; do
    if systemctl is-enabled "$service" &>/dev/null; then
        echo "  $service: ⚠  Still enabled (should be disabled)"
    else
        echo "  $service: ✓ Disabled"
    fi
done

echo
echo "[4] Kernel Parameters:"
sysctl net.ipv4.tcp_congestion_control net.core.rmem_max 2>/dev/null | sed 's/ = /: /'

echo
echo "[5] I/O Scheduler:"
for disk in /sys/block/*/queue/scheduler; do
    CURRENT=$(cat $disk 2>/dev/null | awk '{print $1}')
    echo "  $disk: $CURRENT"
    if [ "$CURRENT" = "deadline" ] || [ "$CURRENT" = "noop" ]; then
        echo "    ✓ Good for streaming"
    fi
done

echo
echo "[6] Running Services:"
echo "  Streaming-related:"
systemctl is-active broadcast-box &>/dev/null && echo "    ✓ Broadcast Box: Running" || echo "    ⚠  Broadcast Box: Not running"
systemctl is-active gaming-stream-av1 &>/dev/null && echo "    ✓ Stream: Running" || echo "    ⚠  Stream: Not running"
systemctl is-active stream-control &>/dev/null && echo "    ✓ Control Panel: Running" || echo "    ⚠  Control Panel: Not running"

echo
echo "[7] CPU Usage Breakdown:"
# Show top CPU consumers
ps -eo pid,ppid,comm,%cpu --sort=%cpu | head -10 | tail -9

echo
echo "[8] Memory Usage:"
free -h | grep -E "Mem|Swap"

echo
echo "[9] Real-time Priorities:"
# Check for streaming processes with RT priority
if command -v ps &>/dev/null; then
    STREAMING_PROCS=$(ps -eo pid,comm,rtprio | grep -E "(gst|stream|broadcast)" | head -5)
    if [ -n "$STREAMING_PROCS" ]; then
        echo "  Streaming processes with RT priority:"
        echo "$STREAMING_PROCS"
    else
        echo "  ⚠  No streaming processes found"
    fi
fi

echo
echo "[10] Optimization Status:"

# Count optimizations
OPT_COUNT=0

[ "$GOVERNOR" = "performance" ] && ((OPT_COUNT++))
[ ! -f "/etc/sysctl.d/99-streaming.conf" ] && ((OPT_COUNT++))

TOTAL_OPTS=10
PERCENT=$((OPT_COUNT * 100 / TOTAL_OPTS))

echo "  Optimizations applied: $OPT_COUNT / $TOTAL_OPTS ($PERCENT%)"

if [ $PERCENT -ge 80 ]; then
    echo "  ✓ Excellent - System is well optimized"
elif [ $PERCENT -ge 60 ]; then
    echo "  ⚠  Good - Some optimizations could be applied"
else
    echo "  ❌ Needs optimization - Run ./optimize-streaming-pc.sh"
fi

echo
echo "=== Verification Complete ==="
echo
echo "Recommendations:"

if [ "$GOVERNOR" != "performance" ]; then
    echo "  - Run: sudo ./optimize-streaming-pc.sh"
fi

if systemctl is-enabled cups &>/dev/null; then
    echo "  - Disable: sudo systemctl disable --now cups"
fi

echo
echo "To apply all optimizations:"
echo "  sudo ./optimize-streaming-pc.sh"
echo "  sudo reboot"
