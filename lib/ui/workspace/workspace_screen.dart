import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../models/clip_model.dart';
import '../../models/overlay_layer_model.dart';
import '../../state/project_state.dart';
import '../../state/playback_state.dart';
import '../../services/project_storage_service.dart';
import '../widgets/window_title_bar.dart';
import '../canvas/canvas_viewport.dart';
import '../timeline/timeline_scrub_bar.dart';
import '../timeline/storyboard_widget.dart';
import '../drawers/color_clip_dialog.dart';
import '../drawers/transition_drawer.dart';
import '../drawers/giphy_picker_dialog.dart';
import '../drawers/effects_adjust_dialog.dart';
import '../drawers/export_dialog.dart';

class WorkspaceScreen extends ConsumerStatefulWidget {
  const WorkspaceScreen({super.key});

  @override
  ConsumerState<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends ConsumerState<WorkspaceScreen> {
  Future<void> _addVideoPhotoClip() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.media,
      allowMultiple: true,
      dialogTitle: 'Select Videos or Photos',
    );

    if (result != null && result.files.isNotEmpty) {
      for (final file in result.files) {
        if (file.path != null) {
          final isImg = file.extension?.toLowerCase() == 'jpg' ||
              file.extension?.toLowerCase() == 'jpeg' ||
              file.extension?.toLowerCase() == 'png';

          final clip = ClipModel(
            id: 'clip-${const Uuid().v4().substring(0, 8)}',
            type: isImg ? ClipType.image : ClipType.video,
            name: file.name,
            filePath: file.path,
            duration: isImg ? 4.0 : 8.0,
          );
          ref.read(projectProvider.notifier).addClip(clip);
        }
      }
    }
  }

  void _openColorClipDialog() {
    showDialog(
      context: context,
      builder: (_) => ColorClipDialog(
        onAddClip: (clip) => ref.read(projectProvider.notifier).addClip(clip),
      ),
    );
  }

  void _openGiphyDialog() {
    showDialog(
      context: context,
      builder: (_) => GiphyPickerDialog(
        onSelectGiphy: (giphy) {
          final overlay = OverlayLayerModel(
            id: 'giphy-${const Uuid().v4().substring(0, 8)}',
            type: giphy.isSticker ? OverlayType.sticker : OverlayType.gif,
            content: giphy.originalUrl,
            startTime: ref.read(playbackProvider).currentTime,
            duration: 3.0,
          );
          ref.read(projectProvider.notifier).addOverlay(overlay);
        },
      ),
    );
  }

  void _openEffectsDialog() {
    final playback = ref.read(playbackProvider);
    final project = ref.read(projectProvider);
    if (playback.selectedClipIndex >= 0 && playback.selectedClipIndex < project.clips.length) {
      final clip = project.clips[playback.selectedClipIndex];
      showDialog(
        context: context,
        builder: (_) => EffectsAdjustDialog(
          initialAdjustments: clip.colorAdjustments,
          onApply: (updated) {
            ref.read(projectProvider.notifier).updateClip(
                  playback.selectedClipIndex,
                  clip.copyWith(colorAdjustments: updated),
                );
          },
        ),
      );
    }
  }

  void _showDurationDialog() {
    final playback = ref.read(playbackProvider);
    final project = ref.read(projectProvider);
    if (playback.selectedClipIndex >= 0 && playback.selectedClipIndex < project.clips.length) {
      final clip = project.clips[playback.selectedClipIndex];
      double curDur = clip.duration;

      showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setDState) => AlertDialog(
            title: const Text('Clip Duration'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${curDur.toInt()} seconds', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Slider(
                  value: curDur,
                  min: 1.0,
                  max: 60.0,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setDState(() => curDur = val),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () {
                  ref.read(projectProvider.notifier).updateClip(
                        playback.selectedClipIndex,
                        clip.copyWith(duration: curDur),
                      );
                  Navigator.of(ctx).pop();
                },
                child: const Text('Apply', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _splitCurrentClip() {
    final playback = ref.read(playbackProvider);
    final project = ref.read(projectProvider);
    if (playback.selectedClipIndex >= 0 && playback.selectedClipIndex < project.clips.length) {
      ref.read(projectProvider.notifier).splitClipAt(
            playback.selectedClipIndex,
            2.0, // Split halfway
          );
    }
  }

  void _openExportDialog() {
    final project = ref.read(projectProvider);
    if (project.clips.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one clip before exporting.')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => ExportDialog(project: project),
    );
  }

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(projectProvider);
    final playback = ref.watch(playbackProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: WindowTitleBar(
        title: '${project.title} - Z-Movie Maker',
        showBackButton: true,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: Row(
        children: [
          // Mini Sidebar (Left Menu & Save Icon from Screenshot 4)
          Container(
            width: 44,
            color: const Color(0xFF252526),
            child: Column(
              children: [
                const SizedBox(height: 8),
                IconButton(
                  icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 20),
                  onPressed: () {},
                  tooltip: 'Menu',
                ),
                IconButton(
                  icon: const Icon(Icons.save_rounded, color: Colors.white, size: 20),
                  onPressed: () => ProjectStorageService.saveProjectToFile(project),
                  tooltip: 'Save Project',
                ),
                const Spacer(),
              ],
            ),
          ),

          // Main Workspace Layout
          Expanded(
            child: Column(
              children: [
                // Top Pro Banner & Feedback Heart (Screenshot 4 & 5)
                Container(
                  color: const Color(0xFF181818),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.proPurple,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Upgrade to Pro version',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.close, color: Colors.white70, size: 12),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Feedback Heart Icon
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                ),

                // Canvas Preview Area
                Expanded(
                  child: CanvasViewport(
                    onAddVideo: _addVideoPhotoClip,
                    onAddColorClip: _openColorClipDialog,
                    onAddGiphy: _openGiphyDialog,
                    onAddCamera: () {},
                  ),
                ),

                // Transition Drawer (When open matching Screenshot 6)
                if (playback.isTransitionDrawerOpen && playback.activeTransitionClipIndex >= 0)
                  TransitionDrawer(
                    currentTransition: project.clips[playback.activeTransitionClipIndex].transitionAfter,
                    onSelectTransition: (trans) {
                      ref.read(projectProvider.notifier).setTransition(playback.activeTransitionClipIndex, trans);
                    },
                    onClose: () => ref.read(playbackProvider.notifier).closeTransitionDrawer(),
                  ),

                // Timeline Transport & Scrubbing Bar (Screenshot 4 & 5)
                const TimelineScrubBar(),

                // Multi-Clip Storyboard Tray (Screenshot 5)
                if (project.clips.isNotEmpty)
                  StoryboardWidget(onAddClip: _openColorClipDialog),

                // Bottom Action Bar (Screenshot 4 & 5)
                Container(
                  height: 56,
                  color: const Color(0xFFF7F7F7),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // Orange "Go back" Button on bottom left (Screenshot 4 & 5)
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          color: AppColors.primary,
                          child: const Row(
                            children: [
                              Icon(Icons.arrow_back, color: Colors.white, size: 18),
                              SizedBox(width: 6),
                              Text('Go back', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),

                      // Tool Actions (Split, Duration, Color, Duplicate, Delete)
                      _BottomActionItem(
                        icon: Icons.content_cut_rounded,
                        label: 'Split',
                        onTap: _splitCurrentClip,
                      ),
                      _BottomActionItem(
                        icon: Icons.access_time_rounded,
                        label: 'Duration',
                        onTap: _showDurationDialog,
                      ),
                      _BottomActionItem(
                        icon: Icons.palette_outlined,
                        label: 'Color',
                        onTap: _openEffectsDialog,
                      ),
                      _BottomActionItem(
                        icon: Icons.copy_rounded,
                        label: 'Duplicate',
                        onTap: () {
                          if (playback.selectedClipIndex >= 0) {
                            ref.read(projectProvider.notifier).duplicateClipAt(playback.selectedClipIndex);
                          }
                        },
                      ),
                      _BottomActionItem(
                        icon: Icons.delete_outline_rounded,
                        label: 'Delete',
                        onTap: () {
                          if (playback.selectedClipIndex >= 0) {
                            ref.read(projectProvider.notifier).removeClipAt(playback.selectedClipIndex);
                          }
                        },
                      ),

                      const Spacer(),

                      // Export Button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        icon: const Icon(Icons.download_rounded, color: Colors.white, size: 18),
                        label: const Text('Export Video', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        onPressed: _openExportDialog,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BottomActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      hoverColor: Colors.black.withOpacity(0.04),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF444444)),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF555555), fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
