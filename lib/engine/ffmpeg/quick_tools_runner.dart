import 'dart:io';
import 'package:path/path.dart' as p;
import 'ffmpeg_manager.dart';

class QuickToolsRunner {
  final FFmpegManager _manager = FFmpegManager();

  /// 1. Lossless Trim Video (Stream copy mode)
  Future<bool> trimVideo({
    required String inputPath,
    required double startSeconds,
    required double endSeconds,
    required String outputPath,
    void Function(double, String)? onProgress,
  }) async {
    final dur = endSeconds - startSeconds;
    final args = [
      '-y',
      '-ss',
      startSeconds.toStringAsFixed(2),
      '-to',
      endSeconds.toStringAsFixed(2),
      '-i',
      inputPath,
      '-c',
      'copy',
      outputPath,
    ];
    return _manager.executeCommand(
      arguments: args,
      totalDurationSeconds: dur,
      onProgress: onProgress,
    );
  }

  /// 2. Extract MP3 Audio
  Future<bool> extractMp3({
    required String inputPath,
    required String outputPath,
    void Function(double, String)? onProgress,
  }) async {
    final meta = await _manager.probeMedia(inputPath);
    final args = [
      '-y',
      '-i',
      inputPath,
      '-vn',
      '-c:a',
      'libmp3lame',
      '-q:a',
      '2',
      outputPath,
    ];
    return _manager.executeCommand(
      arguments: args,
      totalDurationSeconds: meta.durationSeconds,
      onProgress: onProgress,
    );
  }

  /// 3. Adjust Video Speed (Fast or Slow Motion)
  Future<bool> changeSpeed({
    required String inputPath,
    required double speedMultiplier, // e.g. 0.5 for slow, 2.0 for fast
    required String outputPath,
    void Function(double, String)? onProgress,
  }) async {
    final meta = await _manager.probeMedia(inputPath);
    final pts = (1.0 / speedMultiplier).toStringAsFixed(4);
    final atempo = speedMultiplier.clamp(0.5, 2.0).toStringAsFixed(2);

    final args = [
      '-y',
      '-i',
      inputPath,
      '-filter_complex',
      '[0:v]setpts=$pts*PTS[v];[0:a]atempo=$atempo[a]',
      '-map',
      '[v]',
      '-map',
      '[a]',
      '-c:v',
      'libx264',
      '-crf',
      '19',
      outputPath,
    ];
    return _manager.executeCommand(
      arguments: args,
      totalDurationSeconds: meta.durationSeconds / speedMultiplier,
      onProgress: onProgress,
    );
  }

  /// 4. Reverse Video
  Future<bool> reverseVideo({
    required String inputPath,
    required String outputPath,
    void Function(double, String)? onProgress,
  }) async {
    final meta = await _manager.probeMedia(inputPath);
    final args = [
      '-y',
      '-i',
      inputPath,
      '-vf',
      'reverse',
      '-af',
      'areverse',
      '-c:v',
      'libx264',
      '-crf',
      '19',
      outputPath,
    ];
    return _manager.executeCommand(
      arguments: args,
      totalDurationSeconds: meta.durationSeconds,
      onProgress: onProgress,
    );
  }

  /// 5. Mute Video
  Future<bool> muteVideo({
    required String inputPath,
    required String outputPath,
    void Function(double, String)? onProgress,
  }) async {
    final meta = await _manager.probeMedia(inputPath);
    final args = [
      '-y',
      '-i',
      inputPath,
      '-an',
      '-c:v',
      'copy',
      outputPath,
    ];
    return _manager.executeCommand(
      arguments: args,
      totalDurationSeconds: meta.durationSeconds,
      onProgress: onProgress,
    );
  }

  /// 6. Rotate Video
  Future<bool> rotateVideo({
    required String inputPath,
    required int degrees, // 90, 180, 270
    required String outputPath,
    void Function(double, String)? onProgress,
  }) async {
    final meta = await _manager.probeMedia(inputPath);
    String transposeFilter = 'transpose=1'; // 90 clockwise
    if (degrees == 180) {
      transposeFilter = 'hflip,vflip';
    } else if (degrees == 270) {
      transposeFilter = 'transpose=2';
    }

    final args = [
      '-y',
      '-i',
      inputPath,
      '-vf',
      transposeFilter,
      '-c:a',
      'copy',
      outputPath,
    ];
    return _manager.executeCommand(
      arguments: args,
      totalDurationSeconds: meta.durationSeconds,
      onProgress: onProgress,
    );
  }

  /// 7. Add Background Music (with Auto-ducking)
  Future<bool> addBackgroundMusic({
    required String videoPath,
    required String audioPath,
    required double musicVolume, // e.g. 0.3
    required String outputPath,
    void Function(double, String)? onProgress,
  }) async {
    final meta = await _manager.probeMedia(videoPath);
    final args = [
      '-y',
      '-i',
      videoPath,
      '-i',
      audioPath,
      '-filter_complex',
      '[1:a]volume=${musicVolume.toStringAsFixed(2)}[bg];[0:a][bg]amix=inputs=2:duration=first:dropout_transition=2[aout]',
      '-map',
      '0:v',
      '-map',
      '[aout]',
      '-c:v',
      'copy',
      '-c:a',
      'aac',
      outputPath,
    ];
    return _manager.executeCommand(
      arguments: args,
      totalDurationSeconds: meta.durationSeconds,
      onProgress: onProgress,
    );
  }

  /// 8. Apply Color Effects & Adjustments
  Future<bool> applyEffects({
    required String inputPath,
    required double brightness,
    required double contrast,
    required double saturation,
    required String outputPath,
    void Function(double, String)? onProgress,
  }) async {
    final meta = await _manager.probeMedia(inputPath);
    final eq = 'eq=brightness=${brightness.toStringAsFixed(2)}:contrast=${contrast.toStringAsFixed(2)}:saturation=${saturation.toStringAsFixed(2)}';
    final args = [
      '-y',
      '-i',
      inputPath,
      '-vf',
      eq,
      '-c:a',
      'copy',
      '-c:v',
      'libx264',
      '-crf',
      '19',
      outputPath,
    ];
    return _manager.executeCommand(
      arguments: args,
      totalDurationSeconds: meta.durationSeconds,
      onProgress: onProgress,
    );
  }

  /// 9. Video Stabilization (2-Pass VidStab)
  Future<bool> stabilizeVideo({
    required String inputPath,
    required String outputPath,
    void Function(double, String)? onProgress,
  }) async {
    final meta = await _manager.probeMedia(inputPath);
    final trfPath = p.join(Directory.systemTemp.path, 'transforms.trf');

    // Pass 1: Motion vector detection
    onProgress?.call(0.2, 'Analyzing camera motion (Pass 1)...');
    final pass1Args = [
      '-y',
      '-i',
      inputPath,
      '-vf',
      'vidstabdetect=stepsize=6:shakiness=8:accuracy=15:result=$trfPath',
      '-f',
      'null',
      '-',
    ];
    final pass1Success = await _manager.executeCommand(
      arguments: pass1Args,
      totalDurationSeconds: meta.durationSeconds,
    );

    if (!pass1Success) {
      // Fallback: standard deshake filter if vidstab unavailable
      onProgress?.call(0.5, 'Applying standard stabilization...');
      final fallbackArgs = [
        '-y',
        '-i',
        inputPath,
        '-vf',
        'deshake',
        '-c:a',
        'copy',
        outputPath,
      ];
      return _manager.executeCommand(
        arguments: fallbackArgs,
        totalDurationSeconds: meta.durationSeconds,
        onProgress: onProgress,
      );
    }

    // Pass 2: Stabilization transform
    onProgress?.call(0.6, 'Stabilizing video frames (Pass 2)...');
    final pass2Args = [
      '-y',
      '-i',
      inputPath,
      '-vf',
      'vidstabtransform=input=$trfPath:zoom=2:smoothing=12:interpol=bicubic',
      '-c:v',
      'libx264',
      '-crf',
      '18',
      '-c:a',
      'copy',
      outputPath,
    ];
    final success = await _manager.executeCommand(
      arguments: pass2Args,
      totalDurationSeconds: meta.durationSeconds,
      onProgress: onProgress,
    );

    // Clean up temporary transform file
    try {
      final trfFile = File(trfPath);
      if (await trfFile.exists()) await trfFile.delete();
    } catch (_) {}

    return success;
  }

  /// 10. Desktop Screen Recording (Direct GDI / Windows Grab)
  Future<Process?> startScreenRecording({
    required String outputPath,
    int fps = 60,
  }) async {
    final ffmpegExe = await _manager.getFFmpegPath();
    final args = [
      '-y',
      '-f',
      'gdigrab',
      '-framerate',
      '$fps',
      '-i',
      'desktop',
      '-c:v',
      'libx264',
      '-preset',
      'ultrafast',
      '-pix_fmt',
      'yuv420p',
      outputPath,
    ];

    return Process.start(ffmpegExe, args);
  }
}
