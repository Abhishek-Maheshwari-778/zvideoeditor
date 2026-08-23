import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../models/project_model.dart';
import '../../models/clip_model.dart';
import '../../models/quick_tool_model.dart';
import '../../state/project_state.dart';
import '../../services/project_storage_service.dart';
import '../widgets/window_title_bar.dart';
import '../workspace/workspace_screen.dart';
import '../quick_tools/quick_tools_dialogs.dart';
import '../drawers/hardware_settings_dialog.dart';
import '../drawers/asset_store_dialog.dart';
import '../drawers/text_to_speech_dialog.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _createNewProject(BuildContext context, WidgetRef ref) {
    ref.read(projectProvider.notifier).loadProject(
          ProjectModel(
            id: 'proj-${const Uuid().v4().substring(0, 8)}',
            title: 'Untitled_Project',
          ),
        );
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const WorkspaceScreen()),
    );
  }

  Future<void> _openProject(BuildContext context, WidgetRef ref) async {
    final project = await ProjectStorageService.openProjectFromFile();
    if (project != null && context.mounted) {
      ref.read(projectProvider.notifier).loadProject(project);
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const WorkspaceScreen()),
      );
    }
  }

  void _openHardwareSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const HardwareSettingsDialog(),
    );
  }

  void _openAssetStore(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AssetStoreDialog(
        onAddAudio: (track) => ref.read(projectProvider.notifier).addAudioTrack(track),
        onAddOverlay: (overlay) => ref.read(projectProvider.notifier).addOverlay(overlay),
      ),
    );
  }

  void _openTtsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => TextToSpeechDialog(
        onAddVoiceover: (track) {
          ref.read(projectProvider.notifier).addAudioTrack(track);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('TTS Voiceover generated! Open project to listen.')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const WindowTitleBar(title: 'Z-Movie Maker (OpenAnimotica) v2.0'),
      body: Row(
        children: [
          // Left Sidebar Navigation & Settings
          Container(
            width: 70,
            color: const Color(0xFF2B2B2B),
            child: Column(
              children: [
                const SizedBox(height: 12),
                IconButton(
                  icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 24),
                  onPressed: () {},
                  tooltip: 'Main Menu',
                ),
                const SizedBox(height: 12),
                IconButton(
                  icon: const Icon(Icons.storefront_rounded, color: Color(0xFF00A2ED), size: 22),
                  onPressed: () => _openAssetStore(context, ref),
                  tooltip: 'Free Asset Store (Music, SFX, Stickers)',
                ),
                IconButton(
                  icon: const Icon(Icons.memory_rounded, color: Color(0xFF00C853), size: 22),
                  onPressed: () => _openHardwareSettings(context),
                  tooltip: 'Hardware Acceleration & 4GB RAM Settings',
                ),
                const Spacer(),
                // Social Links
                _SocialIcon(icon: Icons.facebook, tooltip: 'Facebook'),
                _SocialIcon(icon: Icons.camera_alt_outlined, tooltip: 'Instagram'),
                _SocialIcon(icon: Icons.flutter_dash, tooltip: 'Twitter / X'),
                _SocialIcon(icon: Icons.play_circle_outline, tooltip: 'YouTube'),
                _SocialIcon(icon: Icons.rss_feed_rounded, tooltip: 'Updates', badgeText: 'v2'),
                const SizedBox(height: 12),
                RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    'FOLLOW US',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'v 2.0.0',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 9,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Main Content Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row with App Brand, Hardware Accelerator Badge & Asset Store
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.proGradientStart, AppColors.primary],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.movie_creation_rounded, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Z-MOVIE MAKER',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00C853).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFF00C853)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.speed_rounded, color: Color(0xFF00C853), size: 12),
                                SizedBox(width: 4),
                                Text('CPU+GPU Hybrid (4GB Spec)', style: TextStyle(color: Color(0xFF00C853), fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0078D7),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                            icon: const Icon(Icons.storefront_rounded, size: 16, color: Colors.white),
                            label: const Text('Asset Store', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            onPressed: () => _openAssetStore(context, ref),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Hero Subtitle
                  const Text(
                    'Easy-to-use Video Editor & Movie Maker v2.0',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w300,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Main Action Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 190,
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                ),
                                icon: const Icon(Icons.add, color: Colors.white, size: 20),
                                label: const Text('New project', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                                onPressed: () => _createNewProject(context, ref),
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                ),
                                icon: const Icon(Icons.folder_open_rounded, color: Colors.white, size: 20),
                                label: const Text('Open a project', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                                onPressed: () => _openProject(context, ref),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 36),

                      // 4 Primary Feature Cards
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 18,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 3.4,
                          children: [
                            _FeatureTile(
                              icon: Icons.edit_note_rounded,
                              iconColor: AppColors.editVideoIcon,
                              bgColor: AppColors.editVideoBg,
                              title: 'Edit video',
                              description: 'Multitrack timeline, adjust color, crop, motion, trim & more',
                              onTap: () => _createNewProject(context, ref),
                            ),
                            _FeatureTile(
                              icon: Icons.style_rounded,
                              iconColor: AppColors.slideshowIcon,
                              bgColor: AppColors.slideshowBg,
                              title: 'Slideshow',
                              description: 'Create photo slideshows with 40+ transitions and free music',
                              onTap: () => _createNewProject(context, ref),
                            ),
                            _FeatureTile(
                              icon: Icons.transform_rounded,
                              iconColor: const Color(0xFFB000FF),
                              bgColor: const Color(0xFFF6E8FF),
                              title: 'Convert Video Format',
                              description: 'Transcode between MP4, MKV, WebM, AVI, MOV & Animated GIF',
                              onTap: () => QuickToolsDialogs.showPrepareDialog(context),
                            ),
                            _FeatureTile(
                              icon: Icons.record_voice_over_rounded,
                              iconColor: const Color(0xFFFF5252),
                              bgColor: const Color(0xFFFFEBEE),
                              title: 'Text to Speech (TTS)',
                              description: 'Generate synthetic voiceover narration from text scripts',
                              onTap: () => _openTtsDialog(context, ref),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),

                  // Quick Tools Section Header (Matching Image 1)
                  const Text(
                    'Quick tools (Without watermark)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF666666)),
                  ),
                  const SizedBox(height: 16),

                  // 12 Quick Tools Grid (Matching Image 1)
                  GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 16,
                      childAspectRatio: 3.8,
                    ),
                    itemCount: QuickToolItem.allTools.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final item = QuickToolItem.allTools[index];
                      return _QuickToolTile(
                        item: item,
                        onTap: () {
                          if (item.type == QuickToolType.textToSpeech) {
                            _openTtsDialog(context, ref);
                          } else {
                            QuickToolsDialogs.handleQuickToolTap(context, item.type);
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final String? badgeText;

  const _SocialIcon({
    required this.icon,
    required this.tooltip,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            icon: Icon(icon, color: Colors.white.withOpacity(0.6), size: 18),
            onPressed: () {},
            tooltip: tooltip,
            splashRadius: 18,
          ),
          if (badgeText != null)
            Positioned(
              right: 4,
              top: 4,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: AppColors.trimColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badgeText!,
                  style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _FeatureTile({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      hoverColor: Colors.black.withOpacity(0.02),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(description, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickToolTile extends StatelessWidget {
  final QuickToolItem item;
  final VoidCallback onTap;

  const _QuickToolTile({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      hoverColor: Colors.black.withOpacity(0.02),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, color: item.iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(item.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    if (item.isNew) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.badgeNew,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(item.description, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
