import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

enum AssetCategory {
  soundFx,
  music,
  stickers,
  stockVideos,
  colorLuts,
  transitions,
}

class MediaAssetItem {
  final String id;
  final String title;
  final AssetCategory category;
  final String previewUrl;
  final String downloadUrl;
  final String duration; // e.g. "0:02" for SFX, "2:30" for Music
  final String fileSize;
  final bool isDownloaded;
  final String? localPath;

  const MediaAssetItem({
    required this.id,
    required this.title,
    required this.category,
    required this.previewUrl,
    required this.downloadUrl,
    this.duration = '',
    this.fileSize = '500 KB',
    this.isDownloaded = false,
    this.localPath,
  });

  MediaAssetItem copyWith({
    String? id,
    String? title,
    AssetCategory? category,
    String? previewUrl,
    String? downloadUrl,
    String? duration,
    String? fileSize,
    bool? isDownloaded,
    String? localPath,
  }) {
    return MediaAssetItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      previewUrl: previewUrl ?? this.previewUrl,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      duration: duration ?? this.duration,
      fileSize: fileSize ?? this.fileSize,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      localPath: localPath ?? this.localPath,
    );
  }
}

class AssetLibraryService {
  static final AssetLibraryService _instance = AssetLibraryService._internal();
  factory AssetLibraryService() => _instance;
  AssetLibraryService._internal();

  /// 1. Built-in Royalty-Free Sound Effects Catalog
  static List<MediaAssetItem> get soundEffects => const [
        MediaAssetItem(
          id: 'sfx_whoosh_01',
          title: 'Fast Cinematic Whoosh',
          category: AssetCategory.soundFx,
          previewUrl: 'https://actions.google.com/sounds/v1/foley/swoosh.ogg',
          downloadUrl: 'https://actions.google.com/sounds/v1/foley/swoosh.ogg',
          duration: '0:01',
          fileSize: '45 KB',
        ),
        MediaAssetItem(
          id: 'sfx_pop_01',
          title: 'Bubble Pop & Ding',
          category: AssetCategory.soundFx,
          previewUrl: 'https://actions.google.com/sounds/v1/cartoon/pop.ogg',
          downloadUrl: 'https://actions.google.com/sounds/v1/cartoon/pop.ogg',
          duration: '0:01',
          fileSize: '32 KB',
        ),
        MediaAssetItem(
          id: 'sfx_camera_01',
          title: 'Camera Shutter Click',
          category: AssetCategory.soundFx,
          previewUrl: 'https://actions.google.com/sounds/v1/household/camera_shutter.ogg',
          downloadUrl: 'https://actions.google.com/sounds/v1/household/camera_shutter.ogg',
          duration: '0:01',
          fileSize: '58 KB',
        ),
        MediaAssetItem(
          id: 'sfx_applause_01',
          title: 'Audience Cheer & Applause',
          category: AssetCategory.soundFx,
          previewUrl: 'https://actions.google.com/sounds/v1/crowds/applause.ogg',
          downloadUrl: 'https://actions.google.com/sounds/v1/crowds/applause.ogg',
          duration: '0:04',
          fileSize: '180 KB',
        ),
        MediaAssetItem(
          id: 'sfx_bell_01',
          title: 'Notification Bell Chime',
          category: AssetCategory.soundFx,
          previewUrl: 'https://actions.google.com/sounds/v1/cartoon/metal_twang.ogg',
          downloadUrl: 'https://actions.google.com/sounds/v1/cartoon/metal_twang.ogg',
          duration: '0:02',
          fileSize: '65 KB',
        ),
        MediaAssetItem(
          id: 'sfx_glitch_01',
          title: 'Digital Glitch & Static',
          category: AssetCategory.soundFx,
          previewUrl: 'https://actions.google.com/sounds/v1/science_fiction/alien_glitch.ogg',
          downloadUrl: 'https://actions.google.com/sounds/v1/science_fiction/alien_glitch.ogg',
          duration: '0:02',
          fileSize: '95 KB',
        ),
      ];

  /// 2. Built-in Royalty-Free Background Music Tracks
  static List<MediaAssetItem> get musicTracks => const [
        MediaAssetItem(
          id: 'mus_lofi_01',
          title: 'Lo-Fi Study Chill Beats',
          category: AssetCategory.music,
          previewUrl: 'https://cdn.pixabay.com/download/audio/2022/05/27/audio_1808fbf07a.mp3',
          downloadUrl: 'https://cdn.pixabay.com/download/audio/2022/05/27/audio_1808fbf07a.mp3',
          duration: '2:15',
          fileSize: '3.2 MB',
        ),
        MediaAssetItem(
          id: 'mus_cinematic_01',
          title: 'Inspirational Cinematic Horizon',
          category: AssetCategory.music,
          previewUrl: 'https://cdn.pixabay.com/download/audio/2022/03/15/audio_c8c8a73467.mp3',
          downloadUrl: 'https://cdn.pixabay.com/download/audio/2022/03/15/audio_c8c8a73467.mp3',
          duration: '3:10',
          fileSize: '4.8 MB',
        ),
        MediaAssetItem(
          id: 'mus_upbeat_01',
          title: 'Energetic Upbeat Summer Pop',
          category: AssetCategory.music,
          previewUrl: 'https://cdn.pixabay.com/download/audio/2022/01/18/audio_d0a13f69d2.mp3',
          downloadUrl: 'https://cdn.pixabay.com/download/audio/2022/01/18/audio_d0a13f69d2.mp3',
          duration: '2:40',
          fileSize: '3.9 MB',
        ),
        MediaAssetItem(
          id: 'mus_acoustic_01',
          title: 'Acoustic Guitar Joy',
          category: AssetCategory.music,
          previewUrl: 'https://cdn.pixabay.com/download/audio/2021/09/06/audio_73138b5523.mp3',
          downloadUrl: 'https://cdn.pixabay.com/download/audio/2021/09/06/audio_73138b5523.mp3',
          duration: '1:55',
          fileSize: '2.8 MB',
        ),
      ];

  /// 3. Built-in Social Media Stickers & Badges
  static List<MediaAssetItem> get stickers => const [
        MediaAssetItem(
          id: 'stk_yt_sub',
          title: 'YouTube Subscribe Button',
          category: AssetCategory.stickers,
          previewUrl: 'https://media.giphy.com/media/du3J3cXyzhj75IOgvA/giphy.gif',
          downloadUrl: 'https://media.giphy.com/media/du3J3cXyzhj75IOgvA/giphy.gif',
          fileSize: '250 KB',
        ),
        MediaAssetItem(
          id: 'stk_like_bell',
          title: 'Like & Notification Bell',
          category: AssetCategory.stickers,
          previewUrl: 'https://media.giphy.com/media/kE8cYhqz2hWn1CT2JG/giphy.gif',
          downloadUrl: 'https://media.giphy.com/media/kE8cYhqz2hWn1CT2JG/giphy.gif',
          fileSize: '320 KB',
        ),
        MediaAssetItem(
          id: 'stk_arrow_red',
          title: 'Animated Glowing Red Arrow',
          category: AssetCategory.stickers,
          previewUrl: 'https://media.giphy.com/media/LpLd2NGvpaiys/giphy.gif',
          downloadUrl: 'https://media.giphy.com/media/LpLd2NGvpaiys/giphy.gif',
          fileSize: '180 KB',
        ),
        MediaAssetItem(
          id: 'stk_flame_fire',
          title: 'Burning Fire Flame 3D',
          category: AssetCategory.stickers,
          previewUrl: 'https://media.giphy.com/media/l41JGlWa1xOjJSsV2/giphy.gif',
          downloadUrl: 'https://media.giphy.com/media/l41JGlWa1xOjJSsV2/giphy.gif',
          fileSize: '410 KB',
        ),
      ];

  /// Downloads an online media asset locally for offline editing
  Future<String?> downloadAssetLocally(MediaAssetItem item) async {
    try {
      final appDir = await getApplicationSupportDirectory();
      final assetsDir = Directory(p.join(appDir.path, 'downloaded_assets', item.category.name));
      if (!await assetsDir.exists()) {
        await assetsDir.create(recursive: true);
      }

      final ext = p.extension(Uri.parse(item.downloadUrl).path);
      final cleanExt = ext.isNotEmpty ? ext : '.mp4';
      final savePath = p.join(assetsDir.path, '${item.id}$cleanExt');

      final file = File(savePath);
      if (await file.exists()) {
        return savePath;
      }

      final response = await http.get(Uri.parse(item.downloadUrl)).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return savePath;
      }
    } catch (e) {
      debugPrint('[AssetLibrary] Download failed: $e');
    }
    return null;
  }
}
