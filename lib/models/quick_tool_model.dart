import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

enum QuickToolType {
  playDvds,
  recordScreen,
  convertVideo,
  reverseVideo,
  trimVideo,
  videoStabilization,
  extractMp3,
  rotateVideo,
  textToSpeech,
  addBackgroundMusic,
  effectsAdjust,
  fastSlowVideo,
  muteVideo,
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
          type: QuickToolType.playDvds,
          title: 'Play DVDs',
          description: 'Play DVD discs and local media files directly',
          icon: Icons.album_rounded,
          iconColor: Color(0xFF00A2ED),
          bgColor: Color(0xFFE5F5FC),
        ),
        const QuickToolItem(
          type: QuickToolType.recordScreen,
          title: 'Record Screen',
          description: 'Capture full desktop screen with microphone audio',
          icon: Icons.radio_button_checked_rounded,
          iconColor: Color(0xFFFF2222),
          bgColor: Color(0xFFFFECEE),
          isNew: true,
        ),
        const QuickToolItem(
          type: QuickToolType.convertVideo,
          title: 'Convert Video',
          description: 'Transcode between MP4, MKV, WebM, AVI, MOV & GIF',
          icon: Icons.transform_rounded,
          iconColor: Color(0xFFB000FF),
          bgColor: Color(0xFFF6E8FF),
        ),
        const QuickToolItem(
          type: QuickToolType.reverseVideo,
          title: 'Reverse Video',
          description: 'Make your video play backwards with audio',
          icon: Icons.swap_horiz_rounded,
          iconColor: Color(0xFFE040FB),
          bgColor: Color(0xFFFDE8F7),
        ),
        const QuickToolItem(
          type: QuickToolType.trimVideo,
          title: 'Trim Video',
          description: 'Fast lossless cut from start and end points',
          icon: Icons.content_cut_rounded,
          iconColor: Color(0xFF0078D7),
          bgColor: Color(0xFFEBF3FF),
        ),
        const QuickToolItem(
          type: QuickToolType.videoStabilization,
          title: 'Stabilize Video',
          description: 'Eliminate shaky camera movements with VidStab',
          icon: Icons.videocam_rounded,
          iconColor: Color(0xFF7C4DFF),
          bgColor: Color(0xFFEDE7F6),
        ),
        const QuickToolItem(
          type: QuickToolType.extractMp3,
          title: 'Extract MP3',
          description: 'Extract audio stream to high quality 320kbps MP3',
          icon: Icons.music_note_rounded,
          iconColor: Color(0xFFFF9800),
          bgColor: Color(0xFFFFF3E0),
        ),
        const QuickToolItem(
          type: QuickToolType.rotateVideo,
          title: 'Rotate Video',
          description: 'Rotate orientation 90°, 180°, or 270° degrees',
          icon: Icons.rotate_right_rounded,
          iconColor: Color(0xFF2979FF),
          bgColor: Color(0xFFE3F2FD),
        ),
        const QuickToolItem(
          type: QuickToolType.textToSpeech,
          title: 'Text to Speech',
          description: 'Generate synthetic voiceover audio from text scripts',
          icon: Icons.record_voice_over_rounded,
          iconColor: Color(0xFFFF5252),
          bgColor: Color(0xFFFFEBEE),
          isNew: true,
        ),
        const QuickToolItem(
          type: QuickToolType.addBackgroundMusic,
          title: 'Add Background Music',
          description: 'Mix background music with voice auto-ducking',
          icon: Icons.library_music_rounded,
          iconColor: AppColors.musicColor,
          bgColor: Color(0xFFEBF3FF),
        ),
        const QuickToolItem(
          type: QuickToolType.effectsAdjust,
          title: 'Effects & Adjust',
          description: 'Apply color filters, LUTs, and exposure adjustments',
          icon: Icons.tune_rounded,
          iconColor: AppColors.effectsColor,
          bgColor: Color(0xFFE6FAF8),
        ),
        const QuickToolItem(
          type: QuickToolType.fastSlowVideo,
          title: 'Fast or Slow Video',
          description: 'Change video speed for slow-mo or hyperlapse',
          icon: Icons.speed_rounded,
          iconColor: AppColors.speedColor,
          bgColor: Color(0xFFFFEEEE),
        ),
      ];
}
