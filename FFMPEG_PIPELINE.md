# Z-Movie Maker (OpenAnimotica) — FFmpeg Pipeline Matrix (v2.0)

> **Version:** 2.0.0  
> **Supported Operations:** Multi-Track Compositing, 40+ Transitions, Crop, Pan-Zoom Motion, Flip, TTS Audio, Format Conversion, Dynamic Bitrates.

---

## 1. Complex Filter Graph for Multitrack Compositing (v2.0)

```
[0:v] -> Scale & Pad -> Crop/Flip -> Motion Zoom -> Color EQ -> [v0]
[1:v] -> Scale & Pad -> Crop/Flip -> Motion Zoom -> Color EQ -> [v1]
[v0][v1] xfade (Transitions: Crossfade, Wipe, Slide, Blur, Luma) -> [v_main]

[v_main] + [PiP 1 (ChromaKey)] + [PiP 2 (Shape Mask)] -> overlay -> [v_pip]
[v_pip]  + [Text Subtitles (Animated DrawText)]        -> overlay -> [v_text]
[v_text] + [Watermark (Top/Bottom Right)]             -> overlay -> [v_final]

[Audio Main] + [Audio Music] + [Audio TTS Voice] + [Sound FX] -> amix -> [a_final]
```

---

## 2. New v2.0 Filter Formulas

### 2.1 ✂️ Video Canvas Cropping
```bash
# Crop video to custom rectangle (width, height, X offset, Y offset)
ffmpeg -y -i input.mp4 -vf "crop=w=1280:h=720:x=320:y=180" -c:a copy output_cropped.mp4
```

### 2.2 🏃 Motion & Ken Burns Pan-Zoom
```bash
# Slow smooth zoom-in towards center (25 fps, 5 seconds)
ffmpeg -y -i input.mp4 -vf \
"zoompan=z='min(zoom+0.0015,1.3)':d=150:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':s=1920x1080" \
-c:v libx264 -crf 19 output_motion.mp4

# Pan Left to Right
ffmpeg -y -i input.mp4 -vf \
"zoompan=z=1.2:x='if(lte(on,1),(iw-iw/zoom)/2,x+2)':y='ih/2-(ih/zoom/2)':d=150:s=1920x1080" \
-c:v libx264 -crf 19 output_pan.mp4
```

### 2.3 ⛵ Horizontal & Vertical Mirror Flip
```bash
# Horizontal Flip
ffmpeg -y -i input.mp4 -vf "hflip" -c:a copy output_hflip.mp4

# Vertical Inversion Flip
ffmpeg -y -i input.mp4 -vf "vflip" -c:a copy output_vflip.mp4
```

### 2.4 🔄 Universal Format Converter
```bash
# Convert to WebM (VP9 + Opus)
ffmpeg -y -i input.mp4 -c:v libvpx-vp9 -b:v 2M -c:a libopus output.webm

# Convert to Animated High-Quality GIF (with palettegen)
ffmpeg -y -i input.mp4 -vf "fps=15,scale=480:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" output.gif

# Convert to MKV / AVI / MOV
ffmpeg -y -i input.mp4 -c:v libx264 -preset fast -crf 20 -c:a aac output.mkv
```

---

## 3. Dynamic Resolution & Bitrate Export Profiles (Image 3)

| Profile Preset | Resolution (W x H) | Bitrate Flag | Target Bitrate | Frame Rates |
| :--- | :--- | :--- | :--- | :--- |
| **480P (SD)** | `854 x 480` | `-b:v 2M -maxrate 2.5M` | Draft (2 Mbps) | 24, 25, 30, 50, 60 fps |
| **720P (HD)** | `1280 x 720` | `-b:v 5M -maxrate 6M` | Standard (10 Mbps) | 24, 25, 30, 50, 60 fps |
| **1080P (FHD)**| `1920 x 1080` | `-b:v 10M -maxrate 12M`| Good (15 Mbps) | 24, 25, 30, 50, 60 fps |
| **1440P (2K)** | `2560 x 1440` | `-b:v 15M -maxrate 18M`| Best (20 Mbps) | 24, 25, 30, 50, 60 fps |
| **4K (UHD)**   | `3840 x 2160` | `-b:v 25M -maxrate 30M`| Master (30 Mbps)| 24, 25, 30, 50, 60 fps |

### Formula for Dynamic Estimated File Size:
$$\text{Estimated File Size (MB)} = \frac{\text{Duration (seconds)} \times (\text{Video Bitrate (Mbps)} + \text{Audio Bitrate (0.192 Mbps)})}{8}$$
*Example:* $3.0\text{ seconds} \times 10\text{ Mbps} / 8 = 3.75\text{ MB}$ *(Exact match with Screenshot 3)*.
