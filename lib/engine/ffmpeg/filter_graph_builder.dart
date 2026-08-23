import '../../models/project_model.dart';
import '../../models/clip_model.dart';
import '../../models/transition_model.dart';
import '../../models/overlay_layer_model.dart';
import '../../services/hardware_acceleration_service.dart';

class FilterGraphBuilder {
  /// Builds a complete FFmpeg command array for exporting the entire project timeline
  static List<String> buildProjectExportCommand({
    required ProjectModel project,
    required String outputPath,
    String? ffmpegPath,
    bool useBlurBackground = true, // Smart Canvas Auto-Reframing (16:9 -> 9:16 / 1:1)
  }) {
    final List<String> args = ['-y'];
    final List<String> filterComplex = [];
    final int outW = project.exportWidth;
    final int outH = project.exportHeight;
    final int fps = project.fps;

    if (project.clips.isEmpty) {
      throw Exception('Cannot export an empty timeline without clips.');
    }

    // Hardware Acceleration Decoding & Multithreading flags
    args.addAll(HardwareAccelerationService().getFFmpegHardwareFlags());

    int inputIndex = 0;

    // Step 1: Add inputs for all video/color clips
    for (int i = 0; i < project.clips.length; i++) {
      final clip = project.clips[i];
      if (clip.type == ClipType.solidColor) {
        final color = (clip.solidColorHex ?? '#000000').replaceAll('#', '0x');
        args.addAll([
          '-f',
          'lavfi',
          '-t',
          clip.duration.toStringAsFixed(2),
          '-i',
          'color=c=$color:s=${outW}x$outH:r=$fps',
        ]);
      } else if (clip.type == ClipType.gradient) {
        final c1 = (clip.gradientColorsHex != null && clip.gradientColorsHex!.isNotEmpty)
            ? clip.gradientColorsHex![0].replaceAll('#', '0x')
            : '0x8A2387';
        args.addAll([
          '-f',
          'lavfi',
          '-t',
          clip.duration.toStringAsFixed(2),
          '-i',
          'color=c=$c1:s=${outW}x$outH:r=$fps',
        ]);
      } else {
        if (clip.sourceTrimIn > 0) {
          args.addAll(['-ss', clip.sourceTrimIn.toStringAsFixed(2)]);
        }
        if (clip.sourceTrimOut > clip.sourceTrimIn) {
          args.addAll(['-t', (clip.sourceTrimOut - clip.sourceTrimIn).toStringAsFixed(2)]);
        } else {
          args.addAll(['-t', clip.duration.toStringAsFixed(2)]);
        }
        args.addAll(['-i', clip.filePath ?? '']);
      }
      inputIndex++;
    }

    // Step 2: Add inputs for custom background audio tracks
    final List<int> audioInputIndices = [];
    for (final track in project.audioTracks) {
      args.addAll(['-i', track.filePath]);
      audioInputIndices.add(inputIndex);
      inputIndex++;
    }

    // Step 3: Add inputs for PiP video overlays
    final List<int> pipInputIndices = [];
    for (final overlay in project.overlays) {
      if (overlay.type == OverlayType.pipVideo && overlay.content.isNotEmpty) {
        args.addAll(['-i', overlay.content]);
        pipInputIndices.add(inputIndex);
        inputIndex++;
      }
    }

    // Step 4: Scale, Pad/Blur Re-framing, Frame-rate, and Color filter normalization per clip
    for (int i = 0; i < project.clips.length; i++) {
      final clip = project.clips[i];

      if (clip.type == ClipType.solidColor || clip.type == ClipType.gradient) {
        final List<String> vf = ['setsar=1', 'fps=$fps'];
        filterComplex.add('[$i:v]${vf.join(',')}[v$i]');
      } else if (useBlurBackground && (project.aspectRatio == CanvasAspectRatio.vertical9_16 || project.aspectRatio == CanvasAspectRatio.square1_1)) {
        // Smart Canvas Auto-Reframing with Ambient Blurred Background Fill (16:9 -> 9:16 / 1:1)
        final bgFilter = '[$i:v]scale=$outW:$outH:force_original_aspect_ratio=increase,crop=$outW:$outH,boxblur=25:25,fps=$fps[bg$i]';
        final fgFilter = '[$i:v]scale=$outW:$outH:force_original_aspect_ratio=decrease,fps=$fps[fg$i]';
        final mergeFilter = '[bg$i][fg$i]overlay=(W-w)/2:(H-h)/2[v$i]';
        filterComplex.addAll([bgFilter, fgFilter, mergeFilter]);
      } else {
        final List<String> vf = [];
        vf.add('scale=$outW:$outH:force_original_aspect_ratio=decrease');
        vf.add('pad=$outW:$outH:(ow-iw)/2:(oh-ih)/2:color=black');
        vf.add('setsar=1');
        vf.add('fps=$fps');

        if (clip.isFlippedHorizontal) vf.add('hflip');
        if (clip.isFlippedVertical) vf.add('vflip');
        if (clip.rotation > 0) {
          if (clip.rotation == 90) vf.add('transpose=1');
          if (clip.rotation == 180) vf.add('transpose=2,transpose=2');
          if (clip.rotation == 270) vf.add('transpose=2');
        }

        if (clip.speed != 1.0) {
          final pts = (1.0 / clip.speed).toStringAsFixed(4);
          vf.add('setpts=$pts*PTS');
        }

        final b = clip.colorAdjustments.brightness;
        final c = clip.colorAdjustments.contrast;
        final s = clip.colorAdjustments.saturation;
        if (b != 0.0 || c != 1.0 || s != 1.0) {
          vf.add('eq=brightness=${b.toStringAsFixed(2)}:contrast=${c.toStringAsFixed(2)}:saturation=${s.toStringAsFixed(2)}');
        }

        if (clip.isReversed) {
          vf.add('reverse');
        }

        filterComplex.add('[$i:v]${vf.join(',')}[v$i]');
      }
    }

    // Step 5: Chain Transitions via xfade
    String lastVideoLabel = '[v0]';
    double currentOffset = project.clips[0].duration;

    if (project.clips.length == 1) {
      lastVideoLabel = '[v0]';
    } else {
      for (int i = 0; i < project.clips.length - 1; i++) {
        final nextIndex = i + 1;
        final nextClip = project.clips[nextIndex];
        final trans = project.clips[i].transitionAfter ??
            const TransitionModel(id: 'default', type: TransitionType.crossFade, duration: 1.0);
        final xfadeName = trans.ffmpegXfadeName.isNotEmpty ? trans.ffmpegXfadeName : 'fade';
        final transDur = trans.duration > 0 ? trans.duration : 1.0;
        final offset = (currentOffset - transDur).clamp(0.1, 999999.0);

        final outLabel = i == project.clips.length - 2 ? '[v_trans_out]' : '[vx$nextIndex]';
        filterComplex.add(
          '$lastVideoLabel[v$nextIndex]xfade=transition=$xfadeName:duration=${transDur.toStringAsFixed(2)}:offset=${offset.toStringAsFixed(2)}$outLabel',
        );

        lastVideoLabel = outLabel;
        currentOffset = offset + nextClip.duration;
      }
    }

    // Step 6: Overlays (Text, Stickers, PiP, Chroma Key)
    String finalVideoOutput = lastVideoLabel;
    int overlayIdx = 0;
    int pipCounter = 0;

    for (final overlay in project.overlays) {
      if (!overlay.isVisible) continue;

      if (overlay.type == OverlayType.text) {
        final sanitizedText = overlay.content.replaceAll("'", "\\'").replaceAll(":", "\\:");
        final color = overlay.fontColorHex.replaceAll('#', '0x');
        final xPos = '(w-tw)*${overlay.posX.toStringAsFixed(2)}';
        final yPos = '(h-th)*${overlay.posY.toStringAsFixed(2)}';
        final enableCond = "between(t,${overlay.startTime.toStringAsFixed(2)},${(overlay.startTime + overlay.duration).toStringAsFixed(2)})";

        String drawTextFilter =
            "drawtext=text='$sanitizedText':fontcolor=$color:fontsize=${overlay.fontSize.toInt()}:x=$xPos:y=$yPos:enable='$enableCond'";
        if (overlay.backgroundColorHex != null) {
          final bgCol = overlay.backgroundColorHex!.replaceAll('#', '0x');
          drawTextFilter += ":box=1:boxcolor=$bgCol@0.8:boxborderw=6";
        }
        if (overlay.hasShadow) {
          drawTextFilter += ":shadowcolor=0x000000@0.8:shadowx=2:shadowy=2";
        }

        final nextLabel = '[v_txt_$overlayIdx]';
        filterComplex.add('$finalVideoOutput$drawTextFilter$nextLabel');
        finalVideoOutput = nextLabel;
        overlayIdx++;
      } else if (overlay.type == OverlayType.pipVideo && pipCounter < pipInputIndices.length) {
        final pipInIdx = pipInputIndices[pipCounter];
        final pipW = (outW * overlay.scale).toInt();
        final pipH = (outH * overlay.scale).toInt();
        final pipX = '(W-w)*${overlay.posX.toStringAsFixed(2)}';
        final pipY = '(H-h)*${overlay.posY.toStringAsFixed(2)}';
        final enableCond = "between(t,${overlay.startTime.toStringAsFixed(2)},${(overlay.startTime + overlay.duration).toStringAsFixed(2)})";

        String pipFilter = "[$pipInIdx:v]scale=$pipW:$pipH";
        if (overlay.chromaKey.enabled) {
          final keyCol = overlay.chromaKey.targetColorHex.replaceAll('#', '0x');
          pipFilter += ",colorkey=$keyCol:${overlay.chromaKey.similarity}:${overlay.chromaKey.smoothness}";
        }
        pipFilter += "[pip_scaled_$pipCounter]";
        filterComplex.add(pipFilter);

        final nextLabel = '[v_pip_$pipCounter]';
        filterComplex.add("$finalVideoOutput[pip_scaled_$pipCounter]overlay=x=$pipX:y=$pipY:enable='$enableCond'$nextLabel");
        finalVideoOutput = nextLabel;
        pipCounter++;
      }
    }

    // Watermark if enabled
    if (project.hasWatermark) {
      final wmText = project.watermarkText.replaceAll("'", "\\'");
      final wmFilter =
          "drawtext=text='$wmText':fontcolor=0xFFFFFF@0.7:fontsize=24:x=w-tw-30:y=h-th-30";
      final nextLabel = '[v_wm_out]';
      filterComplex.add('$finalVideoOutput$wmFilter$nextLabel');
      finalVideoOutput = nextLabel;
    }

    // Step 7: Audio Multi-Track Mixing
    String? finalAudioOutput;
    if (audioInputIndices.isNotEmpty) {
      final List<String> audioLabels = [];
      for (int a = 0; a < audioInputIndices.length; a++) {
        final inIdx = audioInputIndices[a];
        final track = project.audioTracks[a];
        final vol = track.isMuted ? 0.0 : track.volume;
        final aLabel = '[a_mix_$a]';
        filterComplex.add('[$inIdx:a]volume=${vol.toStringAsFixed(2)}$aLabel');
        audioLabels.add(aLabel);
      }
      finalAudioOutput = '[a_final_out]';
      filterComplex.add('${audioLabels.join('')}amix=inputs=${audioLabels.length}:duration=first$finalAudioOutput');
    }

    // Step 8: Assemble Final Arguments
    args.addAll(['-filter_complex', filterComplex.join('; ')]);
    args.addAll(['-map', finalVideoOutput]);
    if (finalAudioOutput != null) {
      args.addAll(['-map', finalAudioOutput, '-c:a', 'aac', '-b:a', '192k']);
    }

    // Video Codec selection from Hardware Acceleration Service (NVENC/QSV/AMF or libx264)
    final encoderCodec = HardwareAccelerationService().getVideoEncoderCodec();
    args.addAll([
      '-c:v',
      encoderCodec,
      if (encoderCodec == 'libx264') ...['-preset', 'medium', '-crf', '18'],
      if (encoderCodec != 'libx264') ...['-b:v', '10M', '-maxrate', '12M'],
      '-pix_fmt',
      'yuv420p',
      '-r',
      '$fps',
      outputPath,
    ]);

    return args;
  }
}
