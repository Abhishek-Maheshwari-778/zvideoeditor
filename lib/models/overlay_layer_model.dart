enum OverlayType {
  text,
  sticker,
  gif,
  pipVideo,
  watermark,
}

class OverlayLayerModel {
  final String id;
  final OverlayType type;
  final String content; // Text string or Asset/File URL/Path
  final double startTime; // Offset in timeline (seconds)
  final double duration; // Duration of visibility (seconds)
  final double posX; // Normalized X position (0.0 to 1.0)
  final double posY; // Normalized Y position (0.0 to 1.0)
  final double scale; // Size multiplier (0.1 to 5.0)
  final double rotation; // Angle in degrees (0 to 360)
  final double opacity; // 0.0 to 1.0

  // Text specific properties
  final String fontFamily;
  final double fontSize;
  final String fontColorHex;
  final String? backgroundColorHex;
  final bool isBold;
  final bool isItalic;
  final bool hasShadow;

  const OverlayLayerModel({
    required this.id,
    required this.type,
    required this.content,
    required this.startTime,
    required this.duration,
    this.posX = 0.5,
    this.posY = 0.5,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.opacity = 1.0,
    this.fontFamily = 'Montserrat',
    this.fontSize = 32.0,
    this.fontColorHex = '#FFFFFF',
    this.backgroundColorHex,
    this.isBold = false,
    this.isItalic = false,
    this.hasShadow = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'content': content,
        'startTime': startTime,
        'duration': duration,
        'posX': posX,
        'posY': posY,
        'scale': scale,
        'rotation': rotation,
        'opacity': opacity,
        'fontFamily': fontFamily,
        'fontSize': fontSize,
        'fontColorHex': fontColorHex,
        'backgroundColorHex': backgroundColorHex,
        'isBold': isBold,
        'isItalic': isItalic,
        'hasShadow': hasShadow,
      };

  factory OverlayLayerModel.fromJson(Map<String, dynamic> json) => OverlayLayerModel(
        id: json['id'] as String,
        type: OverlayType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => OverlayType.text,
        ),
        content: json['content'] as String? ?? '',
        startTime: (json['startTime'] as num?)?.toDouble() ?? 0.0,
        duration: (json['duration'] as num?)?.toDouble() ?? 3.0,
        posX: (json['posX'] as num?)?.toDouble() ?? 0.5,
        posY: (json['posY'] as num?)?.toDouble() ?? 0.5,
        scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
        rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
        opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
        fontFamily: json['fontFamily'] as String? ?? 'Montserrat',
        fontSize: (json['fontSize'] as num?)?.toDouble() ?? 32.0,
        fontColorHex: json['fontColorHex'] as String? ?? '#FFFFFF',
        backgroundColorHex: json['backgroundColorHex'] as String?,
        isBold: json['isBold'] as bool? ?? false,
        isItalic: json['isItalic'] as bool? ?? false,
        hasShadow: json['hasShadow'] as bool? ?? true,
      );
}

class AudioTrackModel {
  final String id;
  final String name;
  final String filePath;
  final double startTime; // Offset in timeline (seconds)
  final double duration; // In seconds
  final double volume; // 0.0 to 2.0
  final bool isMuted;
  final bool isVoiceover;
  final double fadeInDuration;
  final double fadeOutDuration;

  const AudioTrackModel({
    required this.id,
    required this.name,
    required this.filePath,
    required this.startTime,
    required this.duration,
    this.volume = 1.0,
    this.isMuted = false,
    this.isVoiceover = false,
    this.fadeInDuration = 0.0,
    this.fadeOutDuration = 0.0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'filePath': filePath,
        'startTime': startTime,
        'duration': duration,
        'volume': volume,
        'isMuted': isMuted,
        'isVoiceover': isVoiceover,
        'fadeInDuration': fadeInDuration,
        'fadeOutDuration': fadeOutDuration,
      };

  factory AudioTrackModel.fromJson(Map<String, dynamic> json) => AudioTrackModel(
        id: json['id'] as String,
        name: json['name'] as String? ?? 'Audio Track',
        filePath: json['filePath'] as String? ?? '',
        startTime: (json['startTime'] as num?)?.toDouble() ?? 0.0,
        duration: (json['duration'] as num?)?.toDouble() ?? 5.0,
        volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
        isMuted: json['isMuted'] as bool? ?? false,
        isVoiceover: json['isVoiceover'] as bool? ?? false,
        fadeInDuration: (json['fadeInDuration'] as num?)?.toDouble() ?? 0.0,
        fadeOutDuration: (json['fadeOutDuration'] as num?)?.toDouble() ?? 0.0,
      );
}
