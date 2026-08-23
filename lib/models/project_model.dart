import 'clip_model.dart';
import 'overlay_layer_model.dart';

enum CanvasAspectRatio {
  ratio16_9,
  ratio9_16,
  ratio1_1,
  ratio4_5,
  ratio21_9,
}

extension CanvasAspectRatioExtension on CanvasAspectRatio {
  double get value {
    switch (this) {
      case CanvasAspectRatio.ratio16_9:
        return 16.0 / 9.0;
      case CanvasAspectRatio.ratio9_16:
        return 9.0 / 16.0;
      case CanvasAspectRatio.ratio1_1:
        return 1.0;
      case CanvasAspectRatio.ratio4_5:
        return 4.0 / 5.0;
      case CanvasAspectRatio.ratio21_9:
        return 21.0 / 9.0;
    }
  }

  String get displayName {
    switch (this) {
      case CanvasAspectRatio.ratio16_9:
        return '16:9 (YouTube / Landscape)';
      case CanvasAspectRatio.ratio9_16:
        return '9:16 (TikTok / Reels / Shorts)';
      case CanvasAspectRatio.ratio1_1:
        return '1:1 (Square)';
      case CanvasAspectRatio.ratio4_5:
        return '4:5 (Portrait)';
      case CanvasAspectRatio.ratio21_9:
        return '21:9 (Cinematic)';
    }
  }

  int get defaultWidth {
    switch (this) {
      case CanvasAspectRatio.ratio16_9:
        return 1920;
      case CanvasAspectRatio.ratio9_16:
        return 1080;
      case CanvasAspectRatio.ratio1_1:
        return 1080;
      case CanvasAspectRatio.ratio4_5:
        return 1080;
      case CanvasAspectRatio.ratio21_9:
        return 2560;
    }
  }

  int get defaultHeight {
    switch (this) {
      case CanvasAspectRatio.ratio16_9:
        return 1080;
      case CanvasAspectRatio.ratio9_16:
        return 1920;
      case CanvasAspectRatio.ratio1_1:
        return 1080;
      case CanvasAspectRatio.ratio4_5:
        return 1350;
      case CanvasAspectRatio.ratio21_9:
        return 1080;
    }
  }
}

class ProjectModel {
  final String id;
  final String title;
  final String version;
  final CanvasAspectRatio aspectRatio;
  final int exportWidth;
  final int exportHeight;
  final int fps;
  final String backgroundColorHex;
  final bool hasBlurBackground;
  final bool hasWatermark;
  final String watermarkText;

  final List<ClipModel> clips;
  final List<OverlayLayerModel> overlays;
  final List<AudioTrackModel> audioTracks;

  const ProjectModel({
    required this.id,
    this.title = 'Untitled_Project',
    this.version = '1.0.0',
    this.aspectRatio = CanvasAspectRatio.ratio16_9,
    this.exportWidth = 1920,
    this.exportHeight = 1080,
    this.fps = 60,
    this.backgroundColorHex = '#000000',
    this.hasBlurBackground = false,
    this.hasWatermark = false,
    this.watermarkText = 'MADE IN Z-MOVIE MAKER',
    this.clips = const [],
    this.overlays = const [],
    this.audioTracks = const [],
  });

  /// Computes the exact total project duration taking transitions into account
  double get totalDuration {
    if (clips.isEmpty) return 0.0;
    double duration = 0.0;
    for (int i = 0; i < clips.length; i++) {
      duration += clips[i].duration;
      // If there is a transition with the next clip, overlap reduces total timeline duration
      if (i < clips.length - 1 && clips[i].transitionAfter != null) {
        duration -= (clips[i].transitionAfter!.duration / 2.0);
      }
    }
    return duration > 0.0 ? duration : 0.0;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'version': version,
        'aspectRatio': aspectRatio.name,
        'exportWidth': exportWidth,
        'exportHeight': exportHeight,
        'fps': fps,
        'backgroundColorHex': backgroundColorHex,
        'hasBlurBackground': hasBlurBackground,
        'hasWatermark': hasWatermark,
        'watermarkText': watermarkText,
        'clips': clips.map((c) => c.toJson()).toList(),
        'overlays': overlays.map((o) => o.toJson()).toList(),
        'audioTracks': audioTracks.map((a) => a.toJson()).toList(),
      };

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    final aspectName = json['aspectRatio'] as String?;
    final aspectRatio = CanvasAspectRatio.values.firstWhere(
      (e) => e.name == aspectName,
      orElse: () => CanvasAspectRatio.ratio16_9,
    );

    return ProjectModel(
      id: json['id'] as String? ?? 'proj-default',
      title: json['title'] as String? ?? 'Untitled_Project',
      version: json['version'] as String? ?? '1.0.0',
      aspectRatio: aspectRatio,
      exportWidth: json['exportWidth'] as int? ?? aspectRatio.defaultWidth,
      exportHeight: json['exportHeight'] as int? ?? aspectRatio.defaultHeight,
      fps: json['fps'] as int? ?? 60,
      backgroundColorHex: json['backgroundColorHex'] as String? ?? '#000000',
      hasBlurBackground: json['hasBlurBackground'] as bool? ?? false,
      hasWatermark: json['hasWatermark'] as bool? ?? false,
      watermarkText: json['watermarkText'] as String? ?? 'MADE IN Z-MOVIE MAKER',
      clips: (json['clips'] as List<dynamic>?)
              ?.map((c) => ClipModel.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      overlays: (json['overlays'] as List<dynamic>?)
              ?.map((o) => OverlayLayerModel.fromJson(o as Map<String, dynamic>))
              .toList() ??
          [],
      audioTracks: (json['audioTracks'] as List<dynamic>?)
              ?.map((a) => AudioTrackModel.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  ProjectModel copyWith({
    String? id,
    String? title,
    String? version,
    CanvasAspectRatio? aspectRatio,
    int? exportWidth,
    int? exportHeight,
    int? fps,
    String? backgroundColorHex,
    bool? hasBlurBackground,
    bool? hasWatermark,
    String? watermarkText,
    List<ClipModel>? clips,
    List<OverlayLayerModel>? overlays,
    List<AudioTrackModel>? audioTracks,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      title: title ?? this.title,
      version: version ?? this.version,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      exportWidth: exportWidth ?? this.exportWidth,
      exportHeight: exportHeight ?? this.exportHeight,
      fps: fps ?? this.fps,
      backgroundColorHex: backgroundColorHex ?? this.backgroundColorHex,
      hasBlurBackground: hasBlurBackground ?? this.hasBlurBackground,
      hasWatermark: hasWatermark ?? this.hasWatermark,
      watermarkText: watermarkText ?? this.watermarkText,
      clips: clips ?? this.clips,
      overlays: overlays ?? this.overlays,
      audioTracks: audioTracks ?? this.audioTracks,
    );
  }
}
