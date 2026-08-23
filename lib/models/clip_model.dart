import 'transition_model.dart';

enum ClipType {
  video,
  image,
  solidColor,
  gradient,
}

class ColorAdjustments {
  final double brightness; // -1.0 to 1.0 (default 0.0)
  final double contrast; // 0.0 to 2.0 (default 1.0)
  final double saturation; // 0.0 to 3.0 (default 1.0)
  final double temperature; // -1.0 to 1.0 (default 0.0)
  final double hue; // -180 to 180 (default 0.0)
  final String? filterLut; // Preset filter name

  const ColorAdjustments({
    this.brightness = 0.0,
    this.contrast = 1.0,
    this.saturation = 1.0,
    this.temperature = 0.0,
    this.hue = 0.0,
    this.filterLut,
  });

  Map<String, dynamic> toJson() => {
        'brightness': brightness,
        'contrast': contrast,
        'saturation': saturation,
        'temperature': temperature,
        'hue': hue,
        'filterLut': filterLut,
      };

  factory ColorAdjustments.fromJson(Map<String, dynamic> json) => ColorAdjustments(
        brightness: (json['brightness'] as num?)?.toDouble() ?? 0.0,
        contrast: (json['contrast'] as num?)?.toDouble() ?? 1.0,
        saturation: (json['saturation'] as num?)?.toDouble() ?? 1.0,
        temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
        hue: (json['hue'] as num?)?.toDouble() ?? 0.0,
        filterLut: json['filterLut'] as String?,
      );

  ColorAdjustments copyWith({
    double? brightness,
    double? contrast,
    double? saturation,
    double? temperature,
    double? hue,
    String? filterLut,
  }) {
    return ColorAdjustments(
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      saturation: saturation ?? this.saturation,
      temperature: temperature ?? this.temperature,
      hue: hue ?? this.hue,
      filterLut: filterLut ?? this.filterLut,
    );
  }
}

class ClipModel {
  final String id;
  final ClipType type;
  final String name;
  final String? filePath;
  final double duration; // Total active duration in timeline (in seconds)
  final double sourceTrimIn; // Start cut in original source
  final double sourceTrimOut; // End cut in original source
  final double speed; // 1.0 = normal, 0.5 = slow-mo, 2.0 = fast
  final double volume; // 1.0 = 100%, 0.0 = mute
  final int rotation; // 0, 90, 180, 270
  final bool isFlippedHorizontal;
  final bool isFlippedVertical;

  // Solid Color & Gradient Clip Data
  final String? solidColorHex;
  final List<String>? gradientColorsHex;
  final double gradientAngle;

  // Enhancements
  final ColorAdjustments colorAdjustments;
  final bool isStabilized;
  final bool isReversed;
  final bool isMuted;

  // Chroma Key / Green Screen
  final bool isChromaKeyEnabled;
  final String chromaKeyColorHex;
  final double chromaKeySimilarity;
  final double chromaKeySmoothness;

  // Transition to next clip
  final TransitionModel? transitionAfter;

  const ClipModel({
    required this.id,
    required this.type,
    required this.name,
    this.filePath,
    required this.duration,
    this.sourceTrimIn = 0.0,
    this.sourceTrimOut = 0.0,
    this.speed = 1.0,
    this.volume = 1.0,
    this.rotation = 0,
    this.isFlippedHorizontal = false,
    this.isFlippedVertical = false,
    this.solidColorHex,
    this.gradientColorsHex,
    this.gradientAngle = 45.0,
    this.colorAdjustments = const ColorAdjustments(),
    this.isStabilized = false,
    this.isReversed = false,
    this.isMuted = false,
    this.isChromaKeyEnabled = false,
    this.chromaKeyColorHex = '#00FF00',
    this.chromaKeySimilarity = 0.3,
    this.chromaKeySmoothness = 0.1,
    this.transitionAfter,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'name': name,
        'filePath': filePath,
        'duration': duration,
        'sourceTrimIn': sourceTrimIn,
        'sourceTrimOut': sourceTrimOut,
        'speed': speed,
        'volume': volume,
        'rotation': rotation,
        'isFlippedHorizontal': isFlippedHorizontal,
        'isFlippedVertical': isFlippedVertical,
        'solidColorHex': solidColorHex,
        'gradientColorsHex': gradientColorsHex,
        'gradientAngle': gradientAngle,
        'colorAdjustments': colorAdjustments.toJson(),
        'isStabilized': isStabilized,
        'isReversed': isReversed,
        'isMuted': isMuted,
        'isChromaKeyEnabled': isChromaKeyEnabled,
        'chromaKeyColorHex': chromaKeyColorHex,
        'chromaKeySimilarity': chromaKeySimilarity,
        'chromaKeySmoothness': chromaKeySmoothness,
        'transitionAfter': transitionAfter?.toJson(),
      };

  factory ClipModel.fromJson(Map<String, dynamic> json) {
    return ClipModel(
      id: json['id'] as String,
      type: ClipType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ClipType.video,
      ),
      name: json['name'] as String? ?? 'Untitled Clip',
      filePath: json['filePath'] as String?,
      duration: (json['duration'] as num?)?.toDouble() ?? 4.0,
      sourceTrimIn: (json['sourceTrimIn'] as num?)?.toDouble() ?? 0.0,
      sourceTrimOut: (json['sourceTrimOut'] as num?)?.toDouble() ?? 0.0,
      speed: (json['speed'] as num?)?.toDouble() ?? 1.0,
      volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
      rotation: json['rotation'] as int? ?? 0,
      isFlippedHorizontal: json['isFlippedHorizontal'] as bool? ?? false,
      isFlippedVertical: json['isFlippedVertical'] as bool? ?? false,
      solidColorHex: json['solidColorHex'] as String?,
      gradientColorsHex: (json['gradientColorsHex'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      gradientAngle: (json['gradientAngle'] as num?)?.toDouble() ?? 45.0,
      colorAdjustments: json['colorAdjustments'] != null
          ? ColorAdjustments.fromJson(json['colorAdjustments'] as Map<String, dynamic>)
          : const ColorAdjustments(),
      isStabilized: json['isStabilized'] as bool? ?? false,
      isReversed: json['isReversed'] as bool? ?? false,
      isMuted: json['isMuted'] as bool? ?? false,
      isChromaKeyEnabled: json['isChromaKeyEnabled'] as bool? ?? false,
      chromaKeyColorHex: json['chromaKeyColorHex'] as String? ?? '#00FF00',
      chromaKeySimilarity: (json['chromaKeySimilarity'] as num?)?.toDouble() ?? 0.3,
      chromaKeySmoothness: (json['chromaKeySmoothness'] as num?)?.toDouble() ?? 0.1,
      transitionAfter: json['transitionAfter'] != null
          ? TransitionModel.fromJson(json['transitionAfter'] as Map<String, dynamic>)
          : null,
    );
  }

  ClipModel copyWith({
    String? id,
    ClipType? type,
    String? name,
    String? filePath,
    double? duration,
    double? sourceTrimIn,
    double? sourceTrimOut,
    double? speed,
    double? volume,
    int? rotation,
    bool? isFlippedHorizontal,
    bool? isFlippedVertical,
    String? solidColorHex,
    List<String>? gradientColorsHex,
    double? gradientAngle,
    ColorAdjustments? colorAdjustments,
    bool? isStabilized,
    bool? isReversed,
    bool? isMuted,
    bool? isChromaKeyEnabled,
    String? chromaKeyColorHex,
    double? chromaKeySimilarity,
    double? chromaKeySmoothness,
    TransitionModel? transitionAfter,
  }) {
    return ClipModel(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      filePath: filePath ?? this.filePath,
      duration: duration ?? this.duration,
      sourceTrimIn: sourceTrimIn ?? this.sourceTrimIn,
      sourceTrimOut: sourceTrimOut ?? this.sourceTrimOut,
      speed: speed ?? this.speed,
      volume: volume ?? this.volume,
      rotation: rotation ?? this.rotation,
      isFlippedHorizontal: isFlippedHorizontal ?? this.isFlippedHorizontal,
      isFlippedVertical: isFlippedVertical ?? this.isFlippedVertical,
      solidColorHex: solidColorHex ?? this.solidColorHex,
      gradientColorsHex: gradientColorsHex ?? this.gradientColorsHex,
      gradientAngle: gradientAngle ?? this.gradientAngle,
      colorAdjustments: colorAdjustments ?? this.colorAdjustments,
      isStabilized: isStabilized ?? this.isStabilized,
      isReversed: isReversed ?? this.isReversed,
      isMuted: isMuted ?? this.isMuted,
      isChromaKeyEnabled: isChromaKeyEnabled ?? this.isChromaKeyEnabled,
      chromaKeyColorHex: chromaKeyColorHex ?? this.chromaKeyColorHex,
      chromaKeySimilarity: chromaKeySimilarity ?? this.chromaKeySimilarity,
      chromaKeySmoothness: chromaKeySmoothness ?? this.chromaKeySmoothness,
      transitionAfter: transitionAfter ?? this.transitionAfter,
    );
  }
}
