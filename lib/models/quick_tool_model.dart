import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

enum QuickToolType {
  trimVideo,
  screenRecording,
  addTextStickers,
  reverseVideo,
  addBackgroundMusic,
  effectsAdjust,
  extractMp3,
  fastSlowVideo,
  muteVideo,
  videoStabilization,
}

class QuickToolItem {
  final QuickToolType type;
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final bool isNew;

  const QuickToolItem({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    this.isNew = false,
  });

  static List<QuickToolItem> get allTools => [
        const QuickToolItem(
          type: QuickToolType.trimVideo,
          title: 'Trim video',
          description: 'Trim video from start and end',
          icon: Icons.content_cut_rounded,
          iconColor: AppColors.trimColor,
          bgColor: Color(0xFFFFECEE),
        ),
        const QuickToolItem(
          type: QuickToolType.screenRecording,
          title: 'Screen recording',
          description: 'Open the app to record your screen',
          icon: Icons.radio_button_checked_rounded,
          iconColor: AppColors.screenRecordColor,
          bgColor: Color(0xFFFDE8F3),
          isNew: true,
        ),
        const QuickToolItem(
          type: QuickToolType.addTextStickers,
          title: 'Add text, stickers or logo',
          description: 'Add title, stickers, logo or photos to video',
          icon: Icons.layers_rounded,
          iconColor: AppColors.textStickerColor,
          bgColor: Color(0xFFF4ECFF),
        ),
        const QuickToolItem(
          type: QuickToolType.reverseVideo,
          title: 'Reverse video',
          description: 'Make your video play backwards',
          icon: Icons.swap_horiz_rounded,
          iconColor: AppColors.reverseColor,
          bgColor: Color(0xFFFDE8F7),
        ),
        const QuickToolItem(
          type: QuickToolType.addBackgroundMusic,
          title: 'Add background music',
          description: 'Add background music to video',
          icon: Icons.library_music_rounded,
          iconColor: AppColors.musicColor,
          bgColor: Color(0xFFEBF3FF),
        ),
        const QuickToolItem(
          type: QuickToolType.effectsAdjust,
          title: 'Effects & Adjust',
          description: 'Apply effects or adjust color settings',
          icon: Icons.tune_rounded,
          iconColor: AppColors.effectsColor,
          bgColor: Color(0xFFE6FAF8),
        ),
        const QuickToolItem(
          type: QuickToolType.extractMp3,
          title: 'Extract MP3',
          description: 'Convert video to mp3',
          icon: Icons.music_note_rounded,
          iconColor: AppColors.extractMp3Color,
          bgColor: Color(0xFFFEF4E6),
        ),
        const QuickToolItem(
          type: QuickToolType.fastSlowVideo,
          title: 'Fast or slow video',
          description: 'Change video speed for slow motion or fast motion effect',
          icon: Icons.speed_rounded,
          iconColor: AppColors.speedColor,
          bgColor: Color(0xFFFFEEEE),
        ),
        const QuickToolItem(
          type: QuickToolType.muteVideo,
          title: 'Mute video',
          description: 'Mute audio in the video',
          icon: Icons.volume_off_rounded,
          iconColor: AppColors.muteColor,
          bgColor: Color(0xFFE6F8FA),
        ),
        const QuickToolItem(
          type: QuickToolType.videoStabilization,
          title: 'Video stabilization',
          description: 'Stabilize a shaky video',
          icon: Icons.edgesensor_high_rounded,
          iconColor: AppColors.stabilizeColor,
          bgColor: Color(0xFFE8F9F0),
        ),
      ];
}
