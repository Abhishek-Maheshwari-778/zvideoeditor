# Z-Movie Maker (OpenAnimotica) — System Architecture (v2.0)

> **Version:** 2.0.0  
> **Target Framework:** Flutter Desktop (Windows 10/11 x64, macOS, Linux)  
> **Engines:** Native FFmpeg 6.0+, Direct3D11 `media_kit` (MPV), Flutter TTS / SAPI5

---

## 1. High-Level Subsystems (v2.0)

```
+-----------------------------------------------------------------------------------------+
|                                FLUTTER DESKTOP UI LAYER                                 |
|                                                                                         |
|  +---------------------------+  +----------------------------------------------------+  |
|  |       Dashboard Hub       |  |             Advanced Workspace Editor              |  |
|  | - 12 Quick Tools Grid     |  |  +---------------------+  +---------------------+  |  |
|  | - Video Format Converter  |  |  |   Canvas Viewport   |  | Overlay & FX Panel  |  |  |
|  | - Media & DVD Player Mode |  |  +---------------------+  +---------------------+  |  |
|  | - Text to Speech Studio   |  |  |        5-Track Timeline with Zoom Engine        |  |  |
|  |                           |  |  | [Video] [Audio] [PiP/Overlay] [Text] [Effects]  |  |  |
|  +---------------------------+  +----------------------------------------------------+  |
+-----------------------------------------------------------------------------------------+
                                             |
                                             v
+-----------------------------------------------------------------------------------------+
|                          TIMELINE & STATE MANAGEMENT (Riverpod)                         |
|                                                                                         |
|  - ProjectState (Aspect ratio, 5-Track sequence, watermarks, output profile)            |
|  - PlaybackNotifier (Transport, frame stepping, timecode formatting, timeline zoom)     |
|  - OverlayTransformNotifier (Interactive drag, scale, rotation, layer hierarchy)       |
|  - HistoryManager (Multi-level Undo / Redo Command Pattern)                             |
+-----------------------------------------------------------------------------------------+
            |                                           |
            v                                           v
+-----------------------+                   +---------------------------------------------+
|    PREVIEW ENGINE     |                   |               CORE PROCESSING               |
| (media_kit + MPV lib) |                   |             (Native FFmpeg Core)            |
|                       |                   |                                             |
| - D3D11 Texture HWND  |                   | - 40+ XFade Matrix & Luma Transitions       |
| - Low latency scrub   |                   | - Deshake / 2-Pass VidStab Motion Detection |
| - Real-time audio sync|                   | - Chroma Keying & Shape Masked PiP          |
| - Frame-accurate seek |                   | - Crop, Flip (H/V), & Ken Burns Pan-Zoom    |
| - Dynamic canvas zoom |                   | - 5-Tier Resolution & 4-Tier Bitrate Engine |
+-----------------------+                   +---------------------------------------------+
            |                                           |
            v                                           v
+-----------------------------------------------------------------------------------------+
|                           EXTERNAL SERVICES & HARDWARE PLUGINS                          |
|                                                                                         |
|  - Text-to-Speech (TTS) Voice Synthesizer (Windows SAPI5 / Piper neural engine)         |
|  - GIPHY Animated Sticker & GIF Repository                                              |
|  - Free Stock Media Search (Pexels / Pixabay 4K Assets)                                 |
|  - Screen & Audio Capture (GDI Desktop Grab + Microphone DirectShow)                    |
+-----------------------------------------------------------------------------------------+
```

---

## 2. Multitrack Timeline Layer Hierarchy

```
Ruler:  [00:00:00.0] -------- [00:00:03.0] -------- [00:00:06.0] -------- [00:00:09.0]
Track 1 (Video):   [ [<  Clip 1 (Filmstrip + Waveform)  >] ]-[+]--[ [<  Clip 2  >] ]
Track 2 (Audio):   [       🎵 Background Music 01        ] [ 🗣️ TTS Voiceover Clip ]
Track 3 (Overlay): [ 🖼️ PiP Video (Circle Mask) ]          [  ⭐ GIPHY Sticker     ]
Track 4 (Text):    [   🔤 Animated Lower-Third Title    ]  [   🔤 Subtitle Block   ]
Track 5 (Effects): [ 🎞️ Cinematic Orange & Teal LUT      ]  [  🎞️ Vignette Filter  ]
```

---

## 3. Directory Layout (v2.0)

```
z_movie_maker/
├── .github/
│   └── workflows/
│       └── build_windows.yml          # Automated CI/CD & release packaging
├── assets/
│   ├── audio/                         # Royalty-free music and SFX
│   ├── icons/                         # App and tool icons
│   └── bin/                           # Bundled FFmpeg & FFprobe binaries (Windows)
├── lib/
│   ├── main.dart                      # Application entry point & window manager
│   ├── core/                          # Constants, colors, themes
│   ├── models/                        # Project, Track, Clip, Transition, Layer models
│   ├── state/                         # Riverpod state providers
│   ├── engine/
│   │   ├── ffmpeg/                    # Filter complex builders & CLI execution
│   │   └── preview/                   # Player controllers and frame synchronization
│   ├── services/                      # GIPHY, TTS, Stock Media, Screen capture
│   ├── ui/
│   │   ├── home/                      # Dashboard, Quick Tools Grid, Format Converter
│   │   ├── workspace/                 # Main editor workspace
│   │   ├── canvas/                    # Preview canvas with interactive overlay widgets
│   │   ├── timeline/                  # 5-Track Multitrack timeline with Zoom slider
│   │   ├── drawers/                   # Transition picker, Color picker, Audio mixer, TTS
│   │   ├── quick_tools/               # Dedicated interactive dialogs for the 12 quick tools
│   │   └── export/                    # Advanced 5-Tier Resolution & Bitrate Modal
```
