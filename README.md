# 🎬 Z-Movie Maker (OpenAnimotica Project)

[![Build & Release Windows Desktop App](https://github.com/your-username/z-movie-maker/actions/workflows/build_windows.yml/badge.svg)](https://github.com/your-username/z-movie-maker/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.19+-02569B?logo=flutter)](https://flutter.dev)

An open-source, feature-complete, modern video editor and movie maker built with **Flutter Desktop**, **MediaKit (MPV engine)**, and **Native FFmpeg**, directly replicating the UI, workflows, and tools of Animotica.

---

## 🌟 Key Features

### 1. 🏠 Home Dashboard & Workflow Hub
- **Direct Project Creation:** `+ New project` and `📁 Open a project`.
- **4 Guided Workflow Cards:**
  - `Edit video`: Change resolution, adjust color, rotate, zoom, trim, and more.
  - `Slideshow`: Create photo slideshows with transitions and background music.
  - `Rotate video`: Lossless orientation changer (90°, 180°, 270°).
  - `Prepare videos for Z-Movie Maker`: Automatic transcode to standard H.264 MP4.

### 2. ⚡ The 10 Standalone Quick Tools (No Watermark)
1. ✂️ **Trim video:** Dual-handle lossless trimmer.
2. 🔴 **Screen recording:** Full desktop screen capture with audio.
3. 🔤 **Add text, stickers or logo:** Free GIPHY stickers & animated text overlays.
4. 🔁 **Reverse video:** Plays footage backwards with audio reversal.
5. 🎵 **Add background music:** Background audio mixing with auto-ducking.
6. 🎨 **Effects & Adjust:** Color correction (Brightness, Contrast, Saturation, Temp, Hue).
7. 🎧 **Extract MP3:** Fast audio stream extraction to 320kbps MP3.
8. ⚡ **Fast or slow video:** Speed multiplier from 0.1x to 16x with pitch correction.
9. 🔇 **Mute video:** Instant one-click audio removal.
10. 🛡️ **Video stabilization:** 2-Pass `vid.stab` motion compensation to eliminate camera shake.

### 3. 🎞️ Canvas Viewport & Storyboard Timeline
- **Aspect Ratios:** `16:9` (YouTube), `9:16` (TikTok / Reels / Shorts), `1:1` (Square), `4:5` (Portrait), `21:9` (Cinematic).
- **Transport Controls:** Play/Pause, Frame-by-frame step backward/forward, Jump to Start/End, Volume, Undo/Redo.
- **Storyboard Tray:** Sequenced clip thumbnails, duration tags, delete badges, and `+` transition nodes.
- **40+ Transitions:** Cross Fade, Fade Black, Fade White, Blur, Luma Fades, Glow, Lens Flare, Wipes, Slides, and Zooms.

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
git clone https://github.com/your-username/z-movie-maker.git
cd z-movie-maker

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
Every tag push (e.g. `v1.0.0`) triggers `.github/workflows/build_windows.yml` to:
1. Download static FFmpeg binaries.
2. Build the Flutter Windows Release (`flutter build windows --release`).
3. Package the standalone `Z-Movie-Maker-Windows-Portable.zip`.
4. Automatically attach release assets to GitHub Releases.

---

## 📄 Project File Format
Z-Movie Maker uses open `.openanimotica` / `.zmovie` JSON schemas, ensuring complete portable preservation of tracks, clips, aspect ratios, overlays, and transitions.
