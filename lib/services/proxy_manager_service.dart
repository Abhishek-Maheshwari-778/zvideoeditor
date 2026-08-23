import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../engine/ffmpeg/ffmpeg_manager.dart';

class ProxyManagerService {
  static final ProxyManagerService _instance = ProxyManagerService._internal();
  factory ProxyManagerService() => _instance;
  ProxyManagerService._internal();

  final Map<String, String> _proxyCache = {}; // Original Path -> Proxy Path

  /// Checks if a proxy exists for the given video path
  String? getProxyPath(String originalPath) => _proxyCache[originalPath];

  /// Generates a lightweight 540p proxy file in the background for smooth scrubbing on 4GB RAM PCs
  Future<String?> generateProxy({
    required String originalFilePath,
    void Function(double progress)? onProgress,
  }) async {
    if (_proxyCache.containsKey(originalFilePath)) {
      final cached = _proxyCache[originalFilePath]!;
      if (await File(cached).exists()) return cached;
    }

    try {
      final appDir = await getApplicationSupportDirectory();
      final proxyDir = Directory(p.join(appDir.path, 'video_proxies'));
      if (!await proxyDir.exists()) {
        await proxyDir.create(recursive: true);
      }

      final fileName = p.basenameWithoutExtension(originalFilePath);
      final proxyPath = p.join(proxyDir.path, '${fileName}_proxy_540p.mp4');

      final proxyFile = File(proxyPath);
      if (await proxyFile.exists()) {
        _proxyCache[originalFilePath] = proxyPath;
        return proxyPath;
      }

      // FFmpeg Fast 540p Proxy Transcoding (Ultrafast preset, 2 Mbps, low RAM footprint)
      final List<String> args = [
        '-y',
        '-i',
        originalFilePath,
        '-vf',
        'scale=-2:540',
        '-c:v',
        'libx264',
        '-preset',
        'ultrafast',
        '-crf',
        '28',
        '-c:a',
        'aac',
        '-b:a',
        '128k',
        proxyPath,
      ];

      final success = await FFmpegManager().executeCommand(
        arguments: args,
        onProgress: (prog, _) => onProgress?.call(prog),
      );

      if (success && await proxyFile.exists()) {
        _proxyCache[originalFilePath] = proxyPath;
        debugPrint('[ProxyManager] Successfully created 540p proxy: $proxyPath');
        return proxyPath;
      }
    } catch (e) {
      debugPrint('[ProxyManager] Proxy generation failed: $e');
    }
    return null;
  }

  /// Clears temporary proxy video cache
  Future<void> clearProxyCache() async {
    try {
      final appDir = await getApplicationSupportDirectory();
      final proxyDir = Directory(p.join(appDir.path, 'video_proxies'));
      if (await proxyDir.exists()) {
        await proxyDir.delete(recursive: true);
      }
      _proxyCache.clear();
    } catch (_) {}
  }
}
