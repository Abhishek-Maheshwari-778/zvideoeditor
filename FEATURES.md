# Z-Movie Maker (OpenAnimotica) — Complete Feature Specification

This document details every feature replicated from Animotica and the exact implementation specifications.

---

## 1. Dashboard & Home Screen Features

| Feature | Screenshot Ref | Description & Technical Implementation |
| :--- | :--- | :--- |
| **New Project** | Screenshot 1 | Creates a fresh timeline with customizable canvas aspect ratios (16:9, 9:16, 1:1, 4:5, 21:9) and default 60 FPS. |
| **Open Project** | Screenshot 1 | Loads `.openanimotica` / `.zmovie` JSON project files and restores complete multi-clip timeline state. |
| **Edit Video Workflow** | Screenshot 1 | Guided workflow: Pick video -> Auto-detect resolution -> Open full workspace. |
| **Slideshow Maker** | Screenshot 1 | Multi-image importer with configurable photo display durations and auto-applied transitions. |
| **Rotate Video** | Screenshot 1 | Quick utility to transpose/flip 90°, 180°, 270° with lossless rotation flags (`-metadata:s:v rotate=...` or `-vf transpose=...`). |
| **Prepare Videos** | Screenshot 1 | Transcodes problematic codecs/containers into standard H.264 MP4 with constant frame rate for stutter-free editing. |

---

## 2. The 10 Quick Tools (Stand-alone Instant Utilities)

1. **✂️ Trim Video:**
   - Visual dual-handle scrubber to set start and end points with millisecond accuracy.
   - Stream copy mode (`-c copy`) for instant lossless cuts in under 1 second.

2. **🔴 Screen Recording:**
   - Full desktop / window recording using Windows GDI / directshow capture.
   - Microphone voice capture toggle with sample rate auto-configuration.

3. **🔤 Add Text, Stickers or Logo:**
   - Overlay layer editor with drag, pinch-to-scale, and rotation on canvas.
   - Rich typography (Google Fonts), outline stroke, shadow, background box, and opacity.
   - GIPHY sticker and GIF search integration.

4. **🔁 Reverse Video:**
   - Instant reverse playback processing with `-vf reverse -af areverse`.

5. **🎵 Add Background Music:**
   - Audio track overlay with volume leveling, auto-ducking against original clip voice, fade-in, and fade-out.

6. **🎨 Effects & Adjust:**
   - Real-time color correction sliders: Brightness, Contrast, Saturation, Temperature, Tint, Gamma, Sharpness.
   - 20+ preset color LUT filters (Instagram-style: Clarendon, Gingham, Moon, Lark, Vintage, Sepia).

7. **🎧 Extract MP3:**
   - Fast lossless extraction of audio stream to high-quality 320kbps MP3 or AAC.

8. **⚡ Fast or Slow Video:**
   - Speed multiplier from 0.1x (Slow-mo) to 16x (Timelapse / Hyperlapse) with pitch correction (`atempo`).

9. **🔇 Mute Video:**
   - One-click removal of audio tracks (`-an`) with zero re-encoding time.

10. **🛡️ Video Stabilization:**
    - Two-pass motion compensation using `vidstabdetect` and `vidstabtransform` to eliminate camera shake.

---

## 3. Project Workspace & Canvas Viewport

- **Dynamic Canvas Formats:**
  - `16:9 YouTube / Landscape`
  - `9:16 TikTok / Instagram Reels / YouTube Shorts`
  - `1:1 Instagram Square`
  - `4:5 Portrait Feed`
  - `21:9 Ultra-wide Cinematic`
- **Background Fill Modes:** Solid Black, Custom Color, Gradient, or Blurred Duplicate Video background.
- **Transport Controls:** Play/Pause, Step Frame Backward (-1 frame), Step Frame Forward (+1 frame), Jump to Start/End, Volume Level.
- **Editing Tools:** Split at playhead, Trim In/Out, Duplicate clip, Delete clip, Duration dialog.
- **Custom Color & Gradient Generator:** Built-in tool to create solid color or multi-stop linear/radial gradient background cards with custom time length.

---

## 4. Transitions Engine (40+ Presets)

- **Standard:** None, Opacity (Cross Fade), Fade to Black, Fade to White, Blur.
- **Luma Mattes:** Luma Fade A, Luma Fade B, Luma Swirl, Luma Radial, Luma Clock.
- **Geometric:** Wipe Left, Wipe Right, Wipe Up, Wipe Down, Diagonal TL, Diagonal BR.
- **Dynamic:** Slide Left, Slide Right, Zoom In, Zoom Out, Pixelize, Dissolve, Squeeze.
- **Duration Control:** Configurable transition length from 0.2s to 3.0s with automatic audio cross-fading (`acrossfade`).
