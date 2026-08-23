import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

class MediaMetadata {
  final double durationSeconds;
  final int width;
  final int height;
  final double fps;
  final String videoCodec;
  final String audioCodec;

  const MediaMetadata({
    this.durationSeconds = 0.0,
    this.width = 1920,
    this.height = 1080,
    this.fps = 30.0,
    this.videoCodec = 'h264',
    this.audioCodec = 'aac',
  });
}

class FFmpegManager {
  static final FFmpegManager _instance = FFmpegManager._internal();
  factory FFmpegManager() => _instance;
  FFmpegManager._internal();

  Process? _activeProcess;
  bool get isProcessing => _activeProcess != null;

  /// Resolves the FFmpeg executable path (bundled binary or system PATH)
  Future<String> getFFmpegPath() async {
    // 1. Check local assets/bin folder for bundled Windows binary
    final bundledPath = p.join(Directory.current.path, 'assets', 'bin', 'ffmpeg.exe');
    if (await File(bundledPath).exists()) {
      return bundledPath;
    }

    // 2. Check next to executable (release bundle)
    final execDir = p.dirname(Platform.resolvedExecutable);
    final releasePath = p.join(execDir, 'ffmpeg.exe');
    if (await File(releasePath).exists()) {
      return releasePath;
    }

    // 3. Fallback to system environment PATH
    return 'ffmpeg';
  }

  /// Resolves FFprobe executable path
  Future<String> getFFprobePath() async {
    final bundledPath = p.join(Directory.current.path, 'assets', 'bin', 'ffprobe.exe');
    if (await File(bundledPath).exists()) {
      return bundledPath;
    }
    final execDir = p.dirname(Platform.resolvedExecutable);
    final releasePath = p.join(execDir, 'ffprobe.exe');
    if (await File(releasePath).exists()) {
      return releasePath;
    }
    return 'ffprobe';
  }

  /// Runs an FFmpeg command with real-time percentage progress callback (0.0 to 1.0)
  Future<bool> executeCommand({
    required List<String> arguments,
    double totalDurationSeconds = 0.0,
    void Function(double progress, String statusText)? onProgress,
  }) async {
    final ffmpegExe = await getFFmpegPath();

    try {
      debugPrint('[FFmpeg] Executing: $ffmpegExe ${arguments.join(' ')}');
      final process = await Process.start(ffmpegExe, arguments);
      _activeProcess = process;

      final timeRegex = RegExp(r'time=(\d+):(\d+):(\d+\.\d+)');

      process.stderr.transform(utf8.decoder).listen((line) {
        if (totalDurationSeconds > 0) {
          final match = timeRegex.firstMatch(line);
          if (match != null) {
            final hours = double.tryParse(match.group(1) ?? '0') ?? 0.0;
            final mins = double.tryParse(match.group(2) ?? '0') ?? 0.0;
            final secs = double.tryParse(match.group(3) ?? '0') ?? 0.0;
            final currentSec = (hours * 3600) + (mins * 60) + secs;

            final progress = (currentSec / totalDurationSeconds).clamp(0.0, 1.0);
            onProgress?.call(progress, 'Rendering: ${(progress * 100).toInt()}%');
          }
        }
      });

      final exitCode = await process.exitCode;
      _activeProcess = null;

      if (exitCode == 0) {
        onProgress?.call(1.0, 'Completed');
        return true;
      } else {
        debugPrint('[FFmpeg] Failed with exit code: $exitCode');
        return false;
      }
    } catch (e) {
      debugPrint('[FFmpeg] Error: $e');
      _activeProcess = null;
      return false;
    }
  }

  /// Probes video file for duration, resolution, and fps
  Future<MediaMetadata> probeMedia(String filePath) async {
    final ffprobeExe = await getFFprobePath();
    try {
      final result = await Process.run(ffprobeExe, [
        '-v',
        'error',
        '-show_entries',
        'format=duration:stream=width,height,r_frame_rate,codec_name',
        '-of',
        'json',
        filePath,
      ]);

      if (result.exitCode == 0) {
        final data = jsonDecode(result.stdout.toString()) as Map<String, dynamic>;
        final format = data['format'] as Map<String, dynamic>?;
        final streams = data['streams'] as List<dynamic>?;

        final duration = double.tryParse(format?['duration']?.toString() ?? '0') ?? 0.0;

        int w = 1920;
        int h = 1080;
        double fps = 30.0;
        String vCodec = 'h264';
        String aCodec = 'aac';

        if (streams != null && streams.isNotEmpty) {
          for (final stream in streams) {
            final map = stream as Map<String, dynamic>;
            if (map.containsKey('width')) {
              w = map['width'] as int? ?? 1920;
              h = map['height'] as int? ?? 1080;
              vCodec = map['codec_name'] as String? ?? 'h264';

              final rFps = map['r_frame_rate'] as String?;
              if (rFps != null && rFps.contains('/')) {
                final parts = rFps.split('/');
                final num = double.tryParse(parts[0]) ?? 30.0;
                final den = double.tryParse(parts[1]) ?? 1.0;
                fps = den != 0 ? num / den : 30.0;
              }
            } else if (map.containsKey('codec_name') && !map.containsKey('width')) {
              aCodec = map['codec_name'] as String? ?? 'aac';
            }
          }
        }

        return MediaMetadata(
          durationSeconds: duration,
          width: w,
          height: h,
          fps: fps,
          videoCodec: vCodec,
          audioCodec: aCodec,
        );
      }
    } catch (e) {
      debugPrint('[FFprobe] Probe error: $e');
    }

    return const MediaMetadata();
  }

  /// Cancels any currently executing processing task
  void cancelActiveTask() {
    _activeProcess?.kill(ProcessSignal.sigterm);
    _activeProcess = null;
  }
}
