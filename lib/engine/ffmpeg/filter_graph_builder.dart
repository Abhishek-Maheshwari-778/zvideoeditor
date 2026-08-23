import 'dart:io';
import '../../models/project_model.dart';
import '../../models/clip_model.dart';
import '../../models/transition_model.dart';
import '../../models/overlay_layer_model.dart';

class FilterGraphBuilder {
  /// Builds a complete FFmpeg command array for exporting the entire project timeline
  static List<String> buildProjectExportCommand({
    required ProjectModel project,
    required String outputPath,
    String? ffmpegPath,
  }) {
    final List<String> args = ['-y'];
    final List<String> filterComplex = [];
    final List<String> inputFiles = [];
    final int outW = project.exportWidth;
    final int outH = project.exportHeight;
    final int fps = project.fps;

    if (project.clips.isEmpty) {
      throw Exception('Cannot export an empty timeline without clips.');
    }

    // Step 1: Add inputs for all clips
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
        // Gradient synthetic input via lavfi or fallback color
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
      inputFiles.add('[$i:v]');
    }

    // Step 2: Scale, Pad, Frame-rate, and Color filter normalization per clip
    for (int i = 0; i < project.clips.length; i++) {
      final clip = project.clips[i];
      final List<String> vf = [];

      // Aspect ratio scale & center pad
      vf.add('scale=$outW:$outH:force_original_aspect_ratio=decrease');
      vf.add('pad=$outW:$outH:(ow-iw)/2:(oh-ih)/2:color=black');
      vf.add('setsar=1');
      vf.add('fps=$fps');

      // Speed adjustment
      if (clip.speed != 1.0) {
        final pts = (1.0 / clip.speed).toStringAsFixed(4);
        vf.add('setpts=$pts*PTS');
      }

      // Color Adjustments (Brightness, Contrast, Saturation)
      final b = clip.colorAdjustments.brightness;
      final c = clip.colorAdjustments.contrast;
      final s = clip.colorAdjustments.saturation;
      if (b != 0.0 || c != 1.0 || s != 1.0) {
        vf.add('eq=brightness=${b.toStringAsFixed(2)}:contrast=${c.toStringAsFixed(2)}:saturation=${s.toStringAsFixed(2)}');
      }

      // Reverse
      if (clip.isReversed) {
        vf.add('reverse');
      }

      filterComplex.add('[$i:v]${vf.join(',')}[v$i]');
    }

    // Step 3: Chain Transitions via xfade
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

    // Step 4: Overlays (Text, Stickers, Watermark)
    String finalVideoOutput = lastVideoLabel;
    int overlayIdx = 0;

    for (final overlay in project.overlays) {
      if (overlay.type == OverlayType.text) {
        final sanitizedText = overlay.content.replaceAll("'", "\\'").replaceAll(":", "\\:");
        final color = overlay.fontColorHex.replaceAll('#', '0x');
        final xPos = '(w-tw)*${overlay.posX.toStringAsFixed(2)}';
        final yPos = '(h-th)*${overlay.posY.toStringAsFixed(2)}';
        final enableCond = "between(t,${overlay.startTime.toStringAsFixed(2)},${(overlay.startTime + overlay.duration).toStringAsFixed(2)})";

        final drawTextFilter =
            "drawtext=text='$sanitizedText':fontcolor=$color:fontsize=${overlay.fontSize.toInt()}:x=$xPos:y=$yPos:enable='$enableCond'";
        final nextLabel = '[v_txt_$overlayIdx]';
        filterComplex.add('$finalVideoOutput$drawTextFilter$nextLabel');
        finalVideoOutput = nextLabel;
        overlayIdx++;
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

    // Step 5: Assemble Final Arguments
    args.addAll(['-filter_complex', filterComplex.join('; ')]);
    args.addAll(['-map', finalVideoOutput]);

    // Video Codec & Quality Encoding Flags
    args.addAll([
      '-c:v',
      'libx264',
      '-preset',
      'medium',
      '-crf',
      '18',
      '-pix_fmt',
      'yuv420p',
      '-r',
      '$fps',
      outputPath,
    ]);

    return args;
  }
}
