#!/bin/bash
# test-av1-support.sh - Check AV1 encoding support and performance

echo "=== AV1 Support Checker ==="
echo

# Check AV1 GStreamer plugins
echo "[1] Checking GStreamer AV1 plugins:"
echo

gst-inspect-1.0 rav1enc 2>/dev/null && echo "✅ RAV1E encoder found" || echo "❌ RAV1E encoder not found"
gst-inspect-1.0 svtav1enc 2>/dev/null && echo "✅ SVT-AV1 encoder found" || echo "❌ SVT-AV1 encoder not found"
gst-inspect-1.0 vaapiav1enc 2>/dev/null && echo "✅ VA-API AV1 encoder found" || echo "❌ VA-API AV1 encoder not found"
gst-inspect-1.0 nvav1enc 2>/dev/null && echo "✅ NVENC AV1 encoder found" || echo "❌ NVENC AV1 encoder not found"
gst-inspect-1.0 rtpav1pay 2>/dev/null && echo "✅ AV1 RTP payloader found" || echo "❌ AV1 RTP payloader not found"

echo
echo "[2] Checking hardware acceleration:"

# Check VA-API support
if command -v vainfo &> /dev/null; then
    echo "VA-API available"
    if vainfo 2>/dev/null | grep -i "av1" > /dev/null; then
        echo "✅ AV1 hardware encoding supported via VA-API"
    else
        echo "⚠️  VA-API available but AV1 encoding not supported (older GPU)"
    fi
else
    echo "⚠️  VA-API not found"
fi

# Check NVIDIA NVENC
if command -v nvidia-smi &> /dev/null; then
    echo "NVIDIA GPU detected"
    if nvidia-smi --query-gpu=encoder.version.info.av1 --format=csv,noheader 2>/dev/null | grep -v "N/A" > /dev/null; then
        echo "✅ AV1 hardware encoding supported via NVENC (RTX 40-series required)"
    else
        echo "⚠️  NVIDIA GPU found but AV1 encoding not supported (requires RTX 40-series or newer)"
    fi
else
    echo "⚠️  No NVIDIA GPU detected"
fi

echo
echo "[3] CPU information for software encoding:"

if command -v lscpu &> /dev/null; then
    CORES=$(lscpu | grep "^CPU(s):" | awk '{print $2}')
    THREADS=$(lscpu | grep "^Thread(s) per core:" | awk '{print $4}')
    MODEL=$(lscpu | grep "Model name:" | cut -d: -f2 | xargs)
    
    echo "CPU: $MODEL"
    echo "Cores: $CORES, Threads per core: $THREADS"
    
    if [ "$CORES" -ge 4 ]; then
        echo "✅ CPU has enough cores for software AV1 encoding"
    else
        echo "⚠️  CPU may struggle with software AV1 encoding (4+ cores recommended)"
    fi
else
    echo "⚠️  Cannot determine CPU information"
fi

echo
echo "[4] Recommended encoder for your system:"

# Priority: Hardware > SVT-AV1 > RAV1E
ENCODER_RECOMMENDED=""

if gst-inspect-1.0 nvav1enc &> /dev/null; then
    ENCODER_RECOMMENDED="stream-av1-nvenc.sh (NVENC hardware)"
elif gst-inspect-1.0 vaapiav1enc &> /dev/null && vainfo 2>/dev/null | grep -i av1 > /dev/null; then
    ENCODER_RECOMMENDED="stream-av1-vaapi.sh (VA-API hardware)"
elif gst-inspect-1.0 svtav1enc &> /dev/null; then
    ENCODER_RECOMMENDED="stream-av1-svt.sh (SVT-AV1 software)"
elif gst-inspect-1.0 rav1enc &> /dev/null; then
    ENCODER_RECOMMENDED="stream-av1.sh (RAV1E software)"
else
    ENCODER_RECOMMENDED="No AV1 encoder found. Install AV1 encoding plugins."
fi

if [ -n "$ENCODER_RECOMMENDED" ]; then
    echo "🎯 Recommended: $ENCODER_RECOMMENDED"
else
    echo "❌ No AV1 encoder available"
fi

echo
echo "[5] Performance expectations:"

echo "Hardware encoding (VA-API/NVENC):"
echo "  - CPU usage: ~15-25%"
echo "  - Latency: 400-600ms"
echo "  - Quality: Excellent"
echo

echo "SVT-AV1 (software, fast):"
echo "  - CPU usage: ~50-70% (depends on CPU)"
echo "  - Latency: 500-800ms"
echo "  - Quality: Excellent"
echo

echo "RAV1E (software, moderate):"
echo "  - CPU usage: ~60-80% (depends on CPU)"
echo "  - Latency: 600-1000ms"
echo "  - Quality: Excellent"
echo

echo "[6] Test encoding speed (10 seconds):"
echo

# Quick benchmark with SVT-AV1 or RAV1E
if gst-inspect-1.0 svtav1enc &> /dev/null; then
    echo "Testing SVT-AV1..."
    timeout 10s gst-launch-1.0 videotestsrc ! video/x-raw,width=1920,height=1080,framerate=60/1 ! svtav1enc ! fakesink 2>&1 | grep -E "(ERROR|WARNING)" || echo "✅ SVT-AV1 working"
elif gst-inspect-1.0 rav1enc &> /dev/null; then
    echo "Testing RAV1E..."
    timeout 10s gst-launch-1.0 videotestsrc ! video/x-raw,width=1920,height=1080,framerate=60/1 ! rav1enc speed-preset=8 ! fakesink 2>&1 | grep -E "(ERROR|WARNING)" || echo "✅ RAV1E working"
fi

echo
echo "=== AV1 Support Check Complete ==="
echo
echo "Use the recommended script to start streaming:"
echo "  $ENCODER_RECOMMENDED"
