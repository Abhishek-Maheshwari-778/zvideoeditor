# Z-Movie Maker (OpenAnimotica) — System Architecture

## 1. High-Level System Architecture

Z-Movie Maker is built on a modular desktop architecture separating the **UI & Timeline Presentation Layer**, the **Hardware-Accelerated Real-Time Preview Engine**, and the **Non-Destructive FFmpeg Rendering & Processing Core**.

```
+-------------------------------------------------------------------------+
|                         FLUTTER DESKTOP UI LAYER                        |
|                                                                         |
|  +-------------------+  +--------------------------------------------+  |
|  |  Dashboard / Home |  |             Project Workspace              |  |
|  |  - 10 Quick Tools |  |  +--------------------+ +----------------+ |  |
|  |  - Projects List  |  |  |   Canvas Viewport  | |  Clip Toolbar  | |  |
|  |  - Media Creators |  |  +--------------------+ +----------------+ |  |
|  +-------------------+  |  |   Storyboard & Multi-Clip Scrub Bar   | |  |
|                         |  +---------------------------------------+ |  |
|                         +--------------------------------------------+  |
+-------------------------------------------------------------------------+
                                     |
                                     v
+-------------------------------------------------------------------------+
|                  TIMELINE & STATE MANAGEMENT (Riverpod)                 |
|                                                                         |
|  - ProjectState (Canvas aspect ratio, resolution, global duration)       |
|  - TrackState (Video Track, Overlay Track, Audio Tracks, Text Tracks)   |
|  - PlaybackController (Play, Pause, Step-Frame, Loop, Playhead Time)    |
|  - HistoryManager (Full Undo / Redo Command Pattern)                    |
+-------------------------------------------------------------------------+
            |                                           |
            v                                           v
+-----------------------+                   +-----------------------+
|    PREVIEW ENGINE     |                   |    EXPORT & TOOLS     |
| (media_kit + MPV lib) |                   | (Native FFmpeg Core)  |
|                       |                   |                       |
| - Fast frame seek     |                   | - 40+ XFade Matrix    |
| - Low latency scrub   |                   | - Deshake / VidStab   |
| - Direct3D/D3D11 HWND |                   | - Chroma Keying       |
| - Real-time sync      |                   | - 10 Quick Tools      |
+-----------------------+                   +-----------------------+
            |                                           |
            v                                           v
+-------------------------------------------------------------------------+
|                    EXTERNAL APIS & ASSET REPOSITORIES                   |
|                                                                         |
|  - GIPHY Search & Sticker API (Animated transparent overlays)          |
|  - Pexels & Pixabay Media API (Free 4K stock video & audio)             |
|  - Local Hardware Devices (Webcam, USB Microphones, Screen Display)     |
+-------------------------------------------------------------------------+
```

---

## 2. Core Subsystems

### 2.1 State Management (`lib/state/`)
- **`project_provider.dart`**: Holds the active `ProjectModel`, handling track additions, clip splitting, trimming, and duration calculations.
- **`playback_provider.dart`**: Synchronizes the UI playhead with the `media_kit` hardware player.
- **`history_provider.dart`**: Implements undo/redo actions for clip cuts, transitions, volume edits, and text transformations.

### 2.2 Preview Engine (`lib/engine/preview/`)
- Uses `media_kit` with native Direct3D11 texture rendering on Windows for zero-copy high frame-rate preview.
- Dynamic aspect ratio canvas wrapping (`16:9`, `9:16`, `1:1`, `4:5`, `21:9`) with customizable solid, gradient, or blurred background padding.

### 2.3 FFmpeg Pipeline Engine (`lib/engine/ffmpeg/`)
- **Command Generator**: Translates the active `ProjectModel` timeline into a deterministic multi-input `filter_complex` script.
- **Process Manager**: Spawns isolated native `ffmpeg.exe` and `ffprobe.exe` processes with real-time `stderr` parsing for accurate percentage progress and ETA calculations.
- **Quick Tool Runners**: Dedicated standalone single-task processors for instant, non-destructive exports.

### 2.4 Project Storage & Serialization (`lib/services/storage/`)
- Open JSON format `.openanimotica` / `.zmovie`.
- Portable project packaging with relative media references.

---

## 3. Directory Layout

```
z_movie_maker/
├── .github/
│   └── workflows/
│       └── build_windows.yml          # Automated CI/CD & release packaging
├── assets/
│   ├── audio/                         # Royalty-free music and SFX
│   ├── icons/                         # App and tool icons
│   ├── luma/                          # Grayscale Luma matte transition maps
│   └── bin/                           # Bundled FFmpeg & FFprobe binaries (Windows)
├── lib/
│   ├── main.dart                      # Application entry point
│   ├── core/                          # Constants, theme colors, theme helpers
│   ├── models/                        # Project, Track, Clip, Transition, Layer models
│   ├── state/                         # Riverpod state providers
│   ├── engine/
│   │   ├── ffmpeg/                    # Filter complex builders & CLI execution
│   │   └── preview/                   # Player controllers and frame synchronization
│   ├── services/                      # GIPHY, Stock Media, Screen capture, Audio recording
│   ├── ui/
│   │   ├── home/                      # Dashboard, Recent Projects, Quick Tools Grid
│   │   ├── workspace/                 # Main editor workspace
│   │   ├── canvas/                    # Preview canvas with overlays
│   │   ├── timeline/                  # Storyboard, scrub bar, transition connectors
│   │   ├── drawers/                   # Transition picker, Color picker, Effects panel
│   │   ├── quick_tools/               # Dedicated UI dialogs for the 10 quick utilities
│   │   └── widgets/                   # Reusable buttons, sliders, modals, window controls
└── windows/                           # Windows C++ Desktop host configuration
```
