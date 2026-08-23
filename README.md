# 🎬 Z-Movie Maker (OpenAnimotica Project) v2.0

[![Build & Release Windows Desktop App](https://github.com/Abhishek-Maheshwari-778/zvideoeditor/actions/workflows/build_windows.yml/badge.svg)](https://github.com/Abhishek-Maheshwari-778/zvideoeditor/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.19+-02569B?logo=flutter)](https://flutter.dev)

An open-source, feature-complete, modern video editor and movie maker built with **Flutter Desktop**, **MediaKit (MPV engine)**, and **Native FFmpeg**, directly replicating the UI, workflows, and tools of Animotica (Version 2.0).

---

## 🌟 Key Features (v2.0)

### 1. 🏠 Home Dashboard & 12 Standalone Quick Tools
- **Core Guided Workflows:** `Edit video`, `Slideshow Maker`, `Rotate video`, `Convert Video Format`, `Play DVDs`, `Prepare videos for Z-Movie Maker`.
- **12 Standalone Quick Tools (No Watermark):**
  1. ✂️ **Trim Video:** Dual-handle lossless stream-copy trimmer.
  2. 🔴 **Record Screen:** 60 FPS desktop screen capture with microphone.
  3. 🔄 **Convert Video:** Transcode between MP4, MKV, WebM, AVI, MOV, and animated GIF.
  4. 🔁 **Reverse Video:** Plays footage backwards with audio reversal.
  5. 🛡️ **Stabilize Video:** 2-Pass `vid.stab` motion compensation to eliminate camera shake.
  6. 🎧 **Extract MP3:** Fast audio stream extraction to 320kbps MP3.
  7. 🔄 **Rotate Video:** Lossless 90°, 180°, 270° orientation changer.
  8. 🗣️ **Text to Speech (TTS):** Synthetic voice generator with pitch and rate controls.
  9. 🎵 **Add Background Music:** Background audio mixing with auto-ducking.
  10. 🎨 **Effects & Adjust:** Color correction sliders (Brightness, Contrast, Saturation, Temp, Hue).
  11. ⚡ **Fast or Slow Video:** Speed multiplier from 0.1x to 16x with pitch correction.
  12. 🔇 **Mute Video:** Instant one-click audio stream removal.

### 2. 🎞️ Advanced 5-Track Multitrack Timeline & Zoom Engine
- **Track 1 (Master Video):** Filmstrip thumbnails, audio waveform preview, clip duration tag, volume control, and dual-handle trim brackets (`[<` and `>]`).
- **Track 2 (Audio & Music):** Dedicated background music, sound effects, and voiceover layer.
- **Track 3 (Overlays & PiP):** Picture-in-Picture videos, shape masks (Circle, Rounded), and GIPHY stickers.
- **Track 4 (Text & Subtitles):** Animated text titles, lower-thirds, and caption intervals.
- **Track 5 (Effects & Filters):** Global color LUTs, vignette, and blur layers.
- **Timeline Zoom Engine:** Interactive zoom slider (`-` / `+`) and `Fit to Window` button.
- **Floating Quick Add (`+`):** Append new media with one click directly on the timeline.

### 3. 🛠️ Complete Bottom Editing Action Shelf
- `+ Add` Media | `][ Split` at playhead | `|-| Duration` dialog | `🎨 Effect` (Color LUTs & filters)
- `✂ Crop` (Custom aspect ratio & bounding box)
- `🏃 Motion` (Ken Burns Pan-Zoom animations)
- `⛶ Transform` (Scale, position, fit/fill canvas)
- `🔄 Rotate` (90° steps) | `⛵ Flip` (Horizontal & Vertical mirror flip)
- `📄 Duplicate` clip | `🗑 Delete` clip | `💾 Save Video` (Export Studio)

### 4. 💾 Advanced Save Video & Export Studio
- **5 Resolution Tiers:** `480P (SD)`, `720P (HD)`, `1080P (Full HD)`, `1440P (2K)`, `4K (Ultra HD)`.
- **4 Quality Bitrate Tiers:** `Draft (2 Mbps)`, `Standard (10 Mbps)`, `Good (15 Mbps)`, `Best (20 Mbps)`.
- **Live Output File Size Estimator:** Real-time size display (e.g. `Output File Size: 3.75 MB`).
- **5 Framerate Options:** `24 fps`, `25 fps`, `30 fps`, `50 fps`, `60 fps`.
- **More Settings:** Codec (libx264, libx265, AV1), Audio sample rate, and channels.

---

## 🚀 Getting Started Locally

### Prerequisites
- Flutter SDK (3.16+)
- Git
- Visual Studio 2022 (with Desktop development with C++)
- FFmpeg (automatically bundled in CI/CD)

### Run on Windows
```bash
# 1. Clone repository
git clone https://github.com/Abhishek-Maheshwari-778/zvideoeditor.git
cd zvideoeditor

# 2. Get Flutter packages
flutter pub get

# 3. Run Windows Desktop App
flutter run -d windows
```

### Run Tests
```bash
flutter test
```

---

## 📦 Automated GitHub Actions CI/CD
Every tag push (e.g. `v2.0.0`) triggers `.github/workflows/build_windows.yml` to build and publish Windows release binaries automatically.
