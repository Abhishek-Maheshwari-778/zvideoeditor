# Z-Movie Maker (OpenAnimotica) — Complete Feature Specification (v2.0)

> **Version:** 2.0.0 (Updated from Advanced Editor & Quick Tools Screenshots)  
> **Platform:** Windows 10/11 Desktop, Cross-Platform Flutter

---

## 1. Complete Feature Inventory & Hunted Additions (v2.0)

```
+-----------------------------------------------------------------------------------+
|                           Z-MOVIE MAKER v2.0 FEATURE SUITE                        |
+-----------------------------------+-----------------------------------------------+
| 1. CORE WORKSPACES & HUBS         | 4. MULTITRACK TIMELINE & CONTROLS             |
|    - Dashboard Hub                |    - Track 1: Master Video / Clip Track (🎬)  |
|    - Advanced Multitrack Timeline |    - Track 2: Audio & Music Track (🎵)        |
|    - Save Video / Export Modal    |    - Track 3: Overlays & PiP Track (🖼️)       |
|    - Format Converter Hub         |    - Track 4: Text & Subtitle Track (🔤)      |
|    - Media & DVD Player           |    - Track 5: Filter & Effects Track (🎞️)     |
|                                   |    - Dual-Handle Trimmer Blocks ([< ... >])   |
| 2. EXPANDED QUICK TOOLS (12 TOOLS)|    - Interactive Timeline Zoom (- / + / Fit)  |
|    - 1. Trim Video (Lossless)     |    - Granular Second/Millisecond Ruler        |
|    - 2. Screen Recorder (60 FPS)  |                                               |
|    - 3. Convert Video Format      | 5. ADVANCED BOTTOM ACTION SHELF               |
|    - 4. Reverse Video             |    - Add Media (+)                            |
|    - 5. Stabilize Video (VidStab) |    - Split (][)                               |
|    - 6. Extract MP3 Audio         |    - Duration (|-|)                           |
|    - 7. Rotate Video              |    - Effect & LUT Filter (🎨)                 |
|    - 8. Text to Speech (TTS) [NEW]|    - Crop Video Canvas (✂️) [NEW]             |
|    - 9. Add Background Music      |    - Motion & Ken Burns Pan-Zoom (🏃) [NEW]   |
|    - 10. Effects & Color Adjust   |    - Transform & Fit/Fill (⛶) [NEW]           |
|    - 11. Fast or Slow Video       |    - Rotate (90°/180°/270°) (🔄)              |
|    - 12. Mute Audio Stream        |    - Flip Horizontal / Vertical (⛵) [NEW]    |
|                                   |    - Duplicate (📄) & Delete (🗑️)             |
| 3. SAVE VIDEO & EXPORT ENGINE     |                                               |
|    - 5 Resolution Tiers           | 6. OVERLAYS & AUDIO STUDIO                    |
|      (480p, 720p, 1080p, 2K, 4K)  |    - Interactive Canvas Drag/Scale/Rotate     |
|    - 4 Bitrate Quality Tiers      |    - Animated Google Fonts Titles             |
|      (Draft 2M, Std 10M, Good, Max)|   - Chroma Key Green/Blue Screen Studio       |
|    - Real-Time File Size Estimator|    - Multi-Track Audio Mixer & Auto-Ducking   |
|    - 5 Frame Rates (24-60 fps)    |    - GIPHY Animated Stickers & Stock Search   |
+-----------------------------------+-----------------------------------------------+
```

---

## 2. Detailed Breakdown of New v2.0 Features

### 2.1 🗣️ Text to Speech (TTS) Studio (Image 1)
- **Engine:** Integrated Flutter TTS / Windows SAPI5 / Piper neural voice generator.
- **Controls:** Pitch adjustment, Speech rate slider, Volume multiplier, and Language/Voice selector.
- **Workflow:** Input text script -> Generate synthetic waveform -> Auto-inserts as a dedicated voiceover clip onto Audio Track 2.

### 2.2 🔄 Universal Video Format Converter (Image 1)
- **Supported Formats:** MP4 (H.264 / H.265 / AV1), MKV, MOV (ProRes / H.264), WebM (VP9 / AV1), AVI, Animated GIF, WMV.
- **Presets:** Social Media (YouTube 4K, Instagram Reel 1080x1920, TikTok, WhatsApp compressed), Lossless transcode, Web-optimized faststart.

### 2.3 🎚️ Advanced 5-Track Multitrack Timeline & Zoom Engine (Image 2)
1. **Master Video Track (🎬):** Displays thumbnails filmstrip, audio waveform preview, clip duration tag, volume icon, and draggable start/end trim handles (`[<` and `>]`).
2. **Audio Track (🎵):** Dedicated layer for background music, audio sound effects, and voice recordings.
3. **Overlay & PiP Track (🖼️):** Holds Picture-in-Picture videos, PNG logos, and GIPHY stickers with layer order index.
4. **Text Track (🔤):** Displays subtitle blocks, lower-thirds, animated text titles, and caption intervals.
5. **Effects Track (🎞️):** Global color LUTs, vintage filters, vignette, and blur layers.
6. **Timeline Zoom Controls:** Interactive slider from 1x to 10x zoom, `-` (Zoom Out), `+` (Zoom In), and `Fit to Window` button to snap all clips into full view.
7. **Floating Quick-Add (`+`):** Positioned on the right side of the timeline for 1-click media appending.

### 2.4 🛠️ New Bottom Shelf Editing Tools (Image 2)
- ✂️ **Crop Tool:** Custom aspect ratio cropping (`16:9`, `9:16`, `1:1`, `4:3`, Freeform) with on-screen grid handles.
- 🏃 **Motion & Ken Burns Pan/Zoom:** Dynamic camera animations (*Zoom In, Zoom Out, Pan Left to Right, Pan Right to Left, Floating Drift*).
- ⛶ **Transform Tool:** Freeform scale, position offset (X/Y), Canvas Fit mode (*Fit inside, Fill canvas, Stretch, Center*).
- ⛵ **Flip Tool:** One-click instant horizontal mirror flip (`-vf hflip`) and vertical inversion (`-vf vflip`).

### 2.5 💾 Advanced Save Video / Export Modal (Image 3)
- **Resolution Slider (5 Tiers):** `480P (SD)`, `720P (HD)`, `1080P (Full HD)`, `1440P (2K)`, `4K (Ultra HD)`.
- **Quality & Bitrate Slider (4 Tiers):**
  - `Draft (2 Mbps)` — Lightweight preview export
  - `Standard (10 Mbps)` — Balanced web export
  - `Good (15 Mbps)` — High fidelity YouTube/Vimeo export
  - `Best (20 Mbps)` — Master archival render
- **Live Output File Size Estimator:** Calculates estimated `.mp4` size in real-time as duration × target bitrate (e.g. `Output File Size: 3.75 MB`).
- **Framerate Slider (5 Tiers):** `24 fps (Cinematic)`, `25 fps (PAL)`, `30 fps (Standard)`, `50 fps`, `60 fps (Smooth)`.
- **Expandable More Settings:** Audio Bitrate (128k, 192k, 320k), Audio Sample Rate (44.1kHz, 48kHz), Video Codec selector (libx264, libx265, AV1).
- **Watermark Toggle:** Orange `Remove Watermark` button and `Export Video` execution trigger.
