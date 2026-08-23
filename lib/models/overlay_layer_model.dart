enum OverlayType {
  text,
  sticker,
  gif,
  pipVideo,
  watermark,
}

enum TextAnimationStyle {
  none,
  fadeIn,
  typewriter,
  slideUp,
  pop,
  glow,
}

enum PiPMaskShape {
  rectangle,
  roundedRectangle,
  circle,
  heart,
  star,
  splitLeft,
  splitRight,
}

class ChromaKeyConfig {
  final bool enabled;
  final String targetColorHex;
  final double similarity; // 0.0 to 1.0 (default 0.3)
  final double smoothness; // 0.0 to 1.0 (default 0.1)

  const ChromaKeyConfig({
    this.enabled = false,
    this.targetColorHex = '#00FF00',
    this.similarity = 0.3,
    this.smoothness = 0.1,
  });

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'targetColorHex': targetColorHex,
        'similarity': similarity,
        'smoothness': smoothness,
      };

  factory ChromaKeyConfig.fromJson(Map<String, dynamic> json) => ChromaKeyConfig(
        enabled: json['enabled'] as bool? ?? false,
        targetColorHex: json['targetColorHex'] as String? ?? '#00FF00',
        similarity: (json['similarity'] as num?)?.toDouble() ?? 0.3,
        smoothness: (json['smoothness'] as num?)?.toDouble() ?? 0.1,
      );

  ChromaKeyConfig copyWith({
    bool? enabled,
    String? targetColorHex,
    double? similarity,
    double? smoothness,
  }) {
    return ChromaKeyConfig(
      enabled: enabled ?? this.enabled,
      targetColorHex: targetColorHex ?? this.targetColorHex,
      similarity: similarity ?? this.similarity,
      smoothness: smoothness ?? this.smoothness,
    );
  }
}

class OverlayLayerModel {
  final String id;
  final String name;
  final OverlayType type;
  final String content; // Text content or local asset/file path or remote URL
  final double startTime; // Timeline start offset in seconds
  final double duration; // Duration of visibility in seconds
  final double posX; // Normalized center X (0.0 to 1.0)
  final double posY; // Normalized center Y (0.0 to 1.0)
  final double scale; // Scale factor (0.1 to 5.0)
  final double rotation; // Angle in degrees (0.0 to 360.0)
  final double opacity; // 0.0 to 1.0
  final bool isLocked;
  final bool isVisible;

  // Text specific styling
  final String fontFamily;
  final double fontSize;
  final String fontColorHex;
  final String? backgroundColorHex;
  final String? outlineColorHex;
  final double outlineWidth;
  final bool isBold;
  final bool isItalic;
  final bool hasShadow;
  final TextAnimationStyle animationStyle;

  // PiP Video / Sticker Masking
  final PiPMaskShape maskShape;
  final double cornerRadius;
  final String? borderColorHex;
  final double borderWidth;
  final double volume; // For PiP audio
  final ChromaKeyConfig chromaKey;

  const OverlayLayerModel({
    required this.id,
    this.name = 'Overlay Layer',
    required this.type,
    required this.content,
    required this.startTime,
    required this.duration,
    this.posX = 0.5,
    this.posY = 0.5,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.opacity = 1.0,
    this.isLocked = false,
    this.isVisible = true,
    this.fontFamily = 'Montserrat',
    this.fontSize = 36.0,
    this.fontColorHex = '#FFFFFF',
    this.backgroundColorHex,
    this.outlineColorHex,
    this.outlineWidth = 0.0,
    this.isBold = false,
    this.isItalic = false,
    this.hasShadow = true,
    this.animationStyle = TextAnimationStyle.none,
    this.maskShape = PiPMaskShape.rectangle,
    this.cornerRadius = 12.0,
    this.borderColorHex,
    this.borderWidth = 0.0,
    this.volume = 1.0,
    this.chromaKey = const ChromaKeyConfig(),
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'content': content,
        'startTime': startTime,
        'duration': duration,
        'posX': posX,
        'posY': posY,
        'scale': scale,
        'rotation': rotation,
        'opacity': opacity,
        'isLocked': isLocked,
        'isVisible': isVisible,
        'fontFamily': fontFamily,
        'fontSize': fontSize,
        'fontColorHex': fontColorHex,
        'backgroundColorHex': backgroundColorHex,
        'outlineColorHex': outlineColorHex,
        'outlineWidth': outlineWidth,
        'isBold': isBold,
        'isItalic': isItalic,
        'hasShadow': hasShadow,
        'animationStyle': animationStyle.name,
        'maskShape': maskShape.name,
        'cornerRadius': cornerRadius,
        'borderColorHex': borderColorHex,
        'borderWidth': borderWidth,
        'volume': volume,
        'chromaKey': chromaKey.toJson(),
      };

  factory OverlayLayerModel.fromJson(Map<String, dynamic> json) => OverlayLayerModel(
        id: json['id'] as String,
        name: json['name'] as String? ?? 'Overlay Layer',
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
        isLocked: json['isLocked'] as bool? ?? false,
        isVisible: json['isVisible'] as bool? ?? true,
        fontFamily: json['fontFamily'] as String? ?? 'Montserrat',
        fontSize: (json['fontSize'] as num?)?.toDouble() ?? 36.0,
        fontColorHex: json['fontColorHex'] as String? ?? '#FFFFFF',
        backgroundColorHex: json['backgroundColorHex'] as String?,
        outlineColorHex: json['outlineColorHex'] as String?,
        outlineWidth: (json['outlineWidth'] as num?)?.toDouble() ?? 0.0,
        isBold: json['isBold'] as bool? ?? false,
        isItalic: json['isItalic'] as bool? ?? false,
        hasShadow: json['hasShadow'] as bool? ?? true,
        animationStyle: TextAnimationStyle.values.firstWhere(
          (e) => e.name == json['animationStyle'],
          orElse: () => TextAnimationStyle.none,
        ),
        maskShape: PiPMaskShape.values.firstWhere(
          (e) => e.name == json['maskShape'],
          orElse: () => PiPMaskShape.rectangle,
        ),
        cornerRadius: (json['cornerRadius'] as num?)?.toDouble() ?? 12.0,
        borderColorHex: json['borderColorHex'] as String?,
        borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 0.0,
        volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
        chromaKey: json['chromaKey'] != null
            ? ChromaKeyConfig.fromJson(json['chromaKey'] as Map<String, dynamic>)
            : const ChromaKeyConfig(),
      );

  OverlayLayerModel copyWith({
    String? id,
    String? name,
    OverlayType? type,
    String? content,
    double? startTime,
    double? duration,
    double? posX,
    double? posY,
    double? scale,
    double? rotation,
    double? opacity,
    bool? isLocked,
    bool? isVisible,
    String? fontFamily,
    double? fontSize,
    String? fontColorHex,
    String? backgroundColorHex,
    String? outlineColorHex,
    double? outlineWidth,
    bool? isBold,
    bool? isItalic,
    bool? hasShadow,
    TextAnimationStyle? animationStyle,
    PiPMaskShape? maskShape,
    double? cornerRadius,
    String? borderColorHex,
    double? borderWidth,
    double? volume,
    ChromaKeyConfig? chromaKey,
  }) {
    return OverlayLayerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      content: content ?? this.content,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      posX: posX ?? this.posX,
      posY: posY ?? this.posY,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      opacity: opacity ?? this.opacity,
      isLocked: isLocked ?? this.isLocked,
      isVisible: isVisible ?? this.isVisible,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      fontColorHex: fontColorHex ?? this.fontColorHex,
      backgroundColorHex: backgroundColorHex ?? this.backgroundColorHex,
      outlineColorHex: outlineColorHex ?? this.outlineColorHex,
      outlineWidth: outlineWidth ?? this.outlineWidth,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      hasShadow: hasShadow ?? this.hasShadow,
      animationStyle: animationStyle ?? this.animationStyle,
      maskShape: maskShape ?? this.maskShape,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      borderColorHex: borderColorHex ?? this.borderColorHex,
      borderWidth: borderWidth ?? this.borderWidth,
      volume: volume ?? this.volume,
      chromaKey: chromaKey ?? this.chromaKey,
    );
  }
}

class AudioTrackModel {
  final String id;
  final String name;
  final String filePath;
  final double startTime; // Offset in timeline (seconds)
  final double duration; // In seconds
  final double volume; // 0.0 to 2.0
  final bool isMuted;
  final bool isSolo;
  final bool isVoiceover;
  final double fadeInDuration;
  final double fadeOutDuration;
  final bool autoDucking;

  const AudioTrackModel({
    required this.id,
    required this.name,
    required this.filePath,
    required this.startTime,
    required this.duration,
    this.volume = 1.0,
    this.isMuted = false,
    this.isSolo = false,
    this.isVoiceover = false,
    this.fadeInDuration = 0.0,
    this.fadeOutDuration = 0.0,
    this.autoDucking = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'filePath': filePath,
        'startTime': startTime,
        'duration': duration,
        'volume': volume,
        'isMuted': isMuted,
        'isSolo': isSolo,
        'isVoiceover': isVoiceover,
        'fadeInDuration': fadeInDuration,
        'fadeOutDuration': fadeOutDuration,
        'autoDucking': autoDucking,
      };

  factory AudioTrackModel.fromJson(Map<String, dynamic> json) => AudioTrackModel(
        id: json['id'] as String,
        name: json['name'] as String? ?? 'Audio Track',
        filePath: json['filePath'] as String? ?? '',
        startTime: (json['startTime'] as num?)?.toDouble() ?? 0.0,
        duration: (json['duration'] as num?)?.toDouble() ?? 5.0,
        volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
        isMuted: json['isMuted'] as bool? ?? false,
        isSolo: json['isSolo'] as bool? ?? false,
        isVoiceover: json['isVoiceover'] as bool? ?? false,
        fadeInDuration: (json['fadeInDuration'] as num?)?.toDouble() ?? 0.0,
        fadeOutDuration: (json['fadeOutDuration'] as num?)?.toDouble() ?? 0.0,
        autoDucking: json['autoDucking'] as bool? ?? false,
      );

  AudioTrackModel copyWith({
    String? id,
    String? name,
    String? filePath,
    double? startTime,
    double? duration,
    double? volume,
    bool? isMuted,
    bool? isSolo,
    bool? isVoiceover,
    double? fadeInDuration,
    double? fadeOutDuration,
    bool? autoDucking,
  }) {
    return AudioTrackModel(
      id: id ?? this.id,
      name: name ?? this.name,
      filePath: filePath ?? this.filePath,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      isMuted: isMuted ?? this.isMuted,
      isSolo: isSolo ?? this.isSolo,
      isVoiceover: isVoiceover ?? this.isVoiceover,
      fadeInDuration: fadeInDuration ?? this.fadeInDuration,
      fadeOutDuration: fadeOutDuration ?? this.fadeOutDuration,
      autoDucking: autoDucking ?? this.autoDucking,
    );
  }
}
