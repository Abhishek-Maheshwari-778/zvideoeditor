# Z-Movie Maker (OpenAnimotica) — FFmpeg Command & Filter Graph Pipeline

This document contains the exact FFmpeg command generation formulas used across all editing, filtering, transition, and export pipelines.

---

## 1. Complex Filter Graph for Multi-Clip Sequencing with Transitions

When exporting a timeline containing $N$ clips with transitions:

```bash
ffmpeg -y \
  -i clip_0.mp4 \
  -i clip_1.mp4 \
  -i clip_2.mp4 \
  -filter_complex " \
    [0:v]scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,setsar=1,fps=60[v0]; \
    [1:v]scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,setsar=1,fps=60[v1]; \
    [2:v]scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,setsar=1,fps=60[v2]; \
    [v0][v1]xfade=transition=fadeblack:duration=1:offset=3.0[vx1]; \
    [vx1][v2]xfade=transition=slideleft:duration=1:offset=7.0[vout]; \
    [0:a][1:a]acrossfade=d=1[ax1]; \
    [ax1][2:a]acrossfade=d=1[aout] \
  " \
  -map "[vout]" -map "[aout]" \
  -c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p \
  -c:a aac -b:a 192k \
  output_project.mp4
```

---

## 2. Chroma Key & Layer Overlays (Stickers / Text / PiP)

```bash
ffmpeg -y \
  -i main_background.mp4 \
  -i overlay_video.mp4 \
  -i sticker.png \
  -filter_complex " \
    [1:v]colorkey=0x00FF00:0.3:0.1,scale=640:360[ck]; \
    [0:v][ck]overlay=x=50:y=50:enable='between(t,1.0,5.0)'[tmp1]; \
    [tmp1][2:v]overlay=x='(main_w-overlay_w)/2':y='(main_h-overlay_h)/2':enable='between(t,2.0,6.0)'[vout] \
  " \
  -map "[vout]" -map 0:a \
  -c:v libx264 -crf 19 output_layered.mp4
```

---

## 3. Quick Tools Command Matrix

### 3.1 Lossless Trim (No Re-encoding)
```bash
ffmpeg -y -ss {START_SEC} -to {END_SEC} -i input.mp4 -c copy output_trimmed.mp4
```

### 3.2 Extract MP3
```bash
ffmpeg -y -i input.mp4 -vn -c:a libmp3lame -q:a 2 output_audio.mp3
```

### 3.3 Speed Ramping (Slow-Motion / Fast-Motion)
```bash
# Example: 2x Fast Speed
ffmpeg -y -i input.mp4 -filter_complex "[0:v]setpts=0.5*PTS[v];[0:a]atempo=2.0[a]" -map "[v]" -map "[a]" -c:v libx264 -crf 19 output_fast.mp4

# Example: 0.5x Slow Motion
ffmpeg -y -i input.mp4 -filter_complex "[0:v]setpts=2.0*PTS[v];[0:a]atempo=0.5[a]" -map "[v]" -map "[a]" -c:v libx264 -crf 19 output_slow.mp4
```

### 3.4 Reverse Video & Audio
```bash
ffmpeg -y -i input.mp4 -vf reverse -af areverse -c:v libx264 -crf 19 output_reversed.mp4
```

### 3.5 Video Stabilization
```bash
# Step 1: Detect shaky camera movements
ffmpeg -y -i input.mp4 -vf vidstabdetect=stepsize=6:shakiness=8:accuracy=15:result=transforms.trf -f null -

# Step 2: Apply 2D translation/rotation compensation
ffmpeg -y -i input.mp4 -vf vidstabtransform=input=transforms.trf:zoom=2:smoothing=12:interpol=bicubic -c:v libx264 -crf 18 output_stabilized.mp4
```

### 3.6 Screen & Audio Recording (Direct Windows DirectShow / GDI)
```bash
ffmpeg -y -f gdigrab -framerate 60 -i desktop -c:v libx264 -preset ultrafast -crf 22 screen_capture.mp4
```

### 3.7 Add Background Music with Audio Ducking
```bash
ffmpeg -y -i video.mp4 -i music.mp3 -filter_complex " \
  [1:a]volume=0.3[bg]; \
  [0:a][bg]amix=inputs=2:duration=first:dropout_transition=2[aout] \
" -map 0:v -map "[aout]" -c:v copy -c:a aac -b:a 192k output_music.mp4
```
