enum TransitionType {
  none,
  crossFade,
  fadeBlack,
  fadeWhite,
  blur,
  lumaFadeA,
  lumaFadeB,
  glow,
  lensFlare,
  wipeLeft,
  wipeRight,
  wipeUp,
  wipeDown,
  slideLeft,
  slideRight,
  slideUp,
  slideDown,
  zoomIn,
  zoomOut,
  dissolve,
  pixelize,
  circleCrop,
  rectCrop,
  radial,
  diagTL,
  diagBR,
  squeezeH,
  squeezeV,
}

class TransitionModel {
  final String id;
  final TransitionType type;
  final double duration; // in seconds (e.g. 1.0)
  final bool isPro;

  const TransitionModel({
    required this.id,
    this.type = TransitionType.crossFade,
    this.duration = 1.0,
    this.isPro = false,
  });

  String get displayName {
    switch (type) {
      case TransitionType.none:
        return 'None';
      case TransitionType.crossFade:
        return 'Opacity | Cross Fade';
      case TransitionType.fadeBlack:
        return 'Fade Black';
      case TransitionType.fadeWhite:
        return 'Fade White';
      case TransitionType.blur:
        return 'Blur';
      case TransitionType.lumaFadeA:
        return 'Luma Fade A';
      case TransitionType.lumaFadeB:
        return 'Luma Fade B';
      case TransitionType.glow:
        return 'Glow 100';
      case TransitionType.lensFlare:
        return 'Lens Flare 100';
      case TransitionType.wipeLeft:
        return 'Wipe Left';
      case TransitionType.wipeRight:
        return 'Wipe Right';
      case TransitionType.wipeUp:
        return 'Wipe Up';
      case TransitionType.wipeDown:
        return 'Wipe Down';
      case TransitionType.slideLeft:
        return 'Slide Left';
      case TransitionType.slideRight:
        return 'Slide Right';
      case TransitionType.slideUp:
        return 'Slide Up';
      case TransitionType.slideDown:
        return 'Slide Down';
      case TransitionType.zoomIn:
        return 'Zoom In';
      case TransitionType.zoomOut:
        return 'Zoom Out';
      case TransitionType.dissolve:
        return 'Dissolve';
      case TransitionType.pixelize:
        return 'Pixelize';
      case TransitionType.circleCrop:
        return 'Circle Crop';
      case TransitionType.rectCrop:
        return 'Rect Crop';
      case TransitionType.radial:
        return 'Radial';
      case TransitionType.diagTL:
        return 'Diagonal TL';
      case TransitionType.diagBR:
        return 'Diagonal BR';
      case TransitionType.squeezeH:
        return 'Squeeze Horizontal';
      case TransitionType.squeezeV:
        return 'Squeeze Vertical';
    }
  }

  String get ffmpegXfadeName {
    switch (type) {
      case TransitionType.none:
        return '';
      case TransitionType.crossFade:
        return 'fade';
      case TransitionType.fadeBlack:
        return 'fadeblack';
      case TransitionType.fadeWhite:
        return 'fadewhite';
      case TransitionType.blur:
        return 'hblur';
      case TransitionType.lumaFadeA:
      case TransitionType.lumaFadeB:
        return 'dissolve';
      case TransitionType.glow:
      case TransitionType.lensFlare:
        return 'radial';
      case TransitionType.wipeLeft:
        return 'wipeleft';
      case TransitionType.wipeRight:
        return 'wiperight';
      case TransitionType.wipeUp:
        return 'wipeup';
      case TransitionType.wipeDown:
        return 'wipedown';
      case TransitionType.slideLeft:
        return 'slideleft';
      case TransitionType.slideRight:
        return 'slideright';
      case TransitionType.slideUp:
        return 'slideup';
      case TransitionType.slideDown:
        return 'slidedown';
      case TransitionType.zoomIn:
        return 'zoomin';
      case TransitionType.zoomOut:
        return 'fade';
      case TransitionType.dissolve:
        return 'dissolve';
      case TransitionType.pixelize:
        return 'pixelize';
      case TransitionType.circleCrop:
        return 'circlecrop';
      case TransitionType.rectCrop:
        return 'rectcrop';
      case TransitionType.radial:
        return 'radial';
      case TransitionType.diagTL:
        return 'diagtl';
      case TransitionType.diagBR:
        return 'diagbr';
      case TransitionType.squeezeH:
        return 'squeezeh';
      case TransitionType.squeezeV:
        return 'squeezev';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'duration': duration,
        'isPro': isPro,
      };

  factory TransitionModel.fromJson(Map<String, dynamic> json) {
    return TransitionModel(
      id: json['id'] as String? ?? 'trans-default',
      type: TransitionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransitionType.crossFade,
      ),
      duration: (json['duration'] as num?)?.toDouble() ?? 1.0,
      isPro: json['isPro'] as bool? ?? false,
    );
  }

  TransitionModel copyWith({
    String? id,
    TransitionType? type,
    double? duration,
    bool? isPro,
  }) {
    return TransitionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      isPro: isPro ?? this.isPro,
    );
  }
}
