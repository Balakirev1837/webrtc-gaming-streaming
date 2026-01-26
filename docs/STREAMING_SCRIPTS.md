# Streaming Scripts Reference

## Available Scripts (Optimized for Low-Power Hardware)

The control panel now shows only appropriate streaming options for low-power systems like OptiPlex 7070-570X4.

### Recommended Scripts

#### 1. VP9 (Default - OptiPlex)
- **Script:** `stream-vp9.sh`
- **Resolution:** 1440p→720p downscale
- **Codec:** VP9 (libvpx)
- **CPU Usage:** 30-40% @ 720p60
- **Recommended:** ✅ Yes (Best for 4-core CPUs)

#### 2. AV1 (OptiPlex - Downscaled)
- **Script:** `stream-av1-optiplex.sh`
- **Resolution:** 1440p→720p downscale
- **Codec:** AV1 (SVT-AV1)
- **CPU Usage:** 45-60% @ 720p60
- **Recommended:** ⚠️ Conditional (Better quality, higher CPU)

### Hardware Encoder Options

These are shown if GPU hardware is detected and available:

#### 3. H.264 (VA-API - Intel/AMD)
- **Script:** `stream.sh`
- **Resolution:** 1080p60
- **Codec:** H.264 (hardware)
- **CPU Usage:** 10-15%
- **Recommended:** ✅ Yes (if GPU available)

#### 4. H.264 (NVENC - NVIDIA)
- **Script:** `stream-nvenc.sh`
- **Resolution:** 1080p60
- **Codec:** H.264 (hardware)
- **CPU Usage:** 10-15%
- **Recommended:** ✅ Yes (if NVENC available)

#### 5. AV1 (VA-API - Intel Arc/AMD RDNA3)
- **Script:** `stream-av1-vaapi.sh`
- **Resolution:** 1080p60
- **Codec:** AV1 (hardware)
- **CPU Usage:** 15-25%
- **Recommended:** ✅ Yes (if AV1 hardware available)

#### 6. AV1 (NVENC - RTX 40-series)
- **Script:** `stream-av1-nvenc.sh`
- **Resolution:** 1080p60
- **Codec:** AV1 (hardware)
- **CPU Usage:** 5-10%
- **Recommended:** ✅ Yes (if RTX 40-series available)

### Removed Scripts (Too CPU-Intensive)

The following scripts have been removed for low-power systems:

#### AV1 (SVT-AV1) - REMOVED
- **Reason:** 55-75% CPU usage, too demanding for 4-core systems
- **Use Instead:** VP9 or AV1 OptiPlex (downscaled)

#### AV1 (RAV1E) - REMOVED
- **Reason:** 60-80% CPU usage, very high encoding time
- **Use Instead:** VP9 for reliability

#### AV1 1080p Downscale - REMOVED
- **Reason:** 1080p too demanding for low-power, 45-60% CPU
- **Use Instead:** 720p AV1 or VP9

---

## Selection Guide

### For OptiPlex 7070-570X4 (Pentium G3250T, 4 Cores)

**Best Performance:** VP9 @ 720p60
- Smooth 60 FPS
- CPU headroom (~40% used)
- Minimal frame drops

**Best Quality:** AV1 @ 720p60 (OptiPlex)
- 15-20% better compression
- Higher CPU (~60% used)
- May need to lower bitrate

**Hardware Acceleration:** Use H.264/AV1 hardware encoders if available
- Massive CPU savings (10-25%)
- Better for higher resolutions (1080p)

### For Higher Performance Systems

If you have a more powerful system (6+ cores, AVX2 support):

1. AV1 @ 1080p60 is feasible
2. AV1 @ 720p60 is viable
3. VP9 @ 1080p60 is possible

Consider enabling these scripts in `stream-control.py` if you upgrade hardware.

---

## Technical Details

### Queue Configuration

All remaining scripts use `queue-config.sh` for optimized queues:
- Low res: 5 buffers, 500ms
- Mid res: 10 buffers, 500ms
- High res: 15 buffers, 500ms
- Audio: 10 buffers, 200ms
- RTP: 5 buffers, 100ms

See `queue-config.sh` for configuration details.

---

Last Updated: 2025-01-26

