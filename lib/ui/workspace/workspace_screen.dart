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
import '../timeline/multitrack_timeline_widget.dart';
import '../drawers/color_clip_dialog.dart';
import '../drawers/transition_drawer.dart';
import '../drawers/giphy_picker_dialog.dart';
import '../drawers/effects_adjust_dialog.dart';
import '../drawers/save_video_dialog.dart';
import '../drawers/overlay_manager_drawer.dart';
import '../drawers/audio_mixer_drawer.dart';
import '../drawers/text_editor_dialog.dart';
import '../drawers/chroma_key_dialog.dart';
import '../drawers/crop_dialog.dart';
import '../drawers/motion_dialog.dart';

class WorkspaceScreen extends ConsumerStatefulWidget {
  const WorkspaceScreen({super.key});

  @override
  ConsumerState<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends ConsumerState<WorkspaceScreen> {
  bool isLayerDrawerOpen = false;
  bool isAudioMixerOpen = false;

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

  void _openTextDialog() {
    showDialog(
      context: context,
      builder: (_) => TextEditorDialog(
        onSave: (overlay) => ref.read(projectProvider.notifier).addOverlay(overlay),
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
            name: giphy.title,
            content: giphy.originalUrl,
            startTime: ref.read(playbackProvider).currentTime,
            duration: 4.0,
          );
          ref.read(projectProvider.notifier).addOverlay(overlay);
        },
      ),
    );
  }

  Future<void> _openPiPVideoDialog() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null && result.files.single.path != null) {
      final file = result.files.single;
      final overlay = OverlayLayerModel(
        id: 'pip-${const Uuid().v4().substring(0, 8)}',
        name: 'PiP: ${file.name}',
        type: OverlayType.pipVideo,
        content: file.path!,
        startTime: ref.read(playbackProvider).currentTime,
        duration: 5.0,
        scale: 0.6,
        posX: 0.75,
        posY: 0.75,
        maskShape: PiPMaskShape.roundedRectangle,
        cornerRadius: 16.0,
        borderWidth: 2.0,
        borderColorHex: '#FFFFFF',
      );
      ref.read(projectProvider.notifier).addOverlay(overlay);
    }
  }

  void _openChromaKeyDialog() {
    final playback = ref.read(playbackProvider);
    final project = ref.read(projectProvider);
    if (playback.selectedOverlayIndex >= 0 && playback.selectedOverlayIndex < project.overlays.length) {
      final overlay = project.overlays[playback.selectedOverlayIndex];
      showDialog(
        context: context,
        builder: (_) => ChromaKeyDialog(
          initialConfig: overlay.chromaKey,
          onApply: (config) {
            ref.read(projectProvider.notifier).updateOverlay(
                  playback.selectedOverlayIndex,
                  overlay.copyWith(chromaKey: config),
                );
          },
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an overlay layer to apply Chroma Key.')),
      );
    }
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

  void _showCropDialog() {
    showDialog(
      context: context,
      builder: (_) => CropDialog(
        onApplyCrop: (l, t, w, h) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Crop area applied to active clip.')),
          );
        },
      ),
    );
  }

  void _showMotionDialog() {
    showDialog(
      context: context,
      builder: (_) => MotionDialog(
        onApplyMotion: (preset) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Applied Ken Burns camera motion: ${preset.name}')),
          );
        },
      ),
    );
  }

  void _flipCurrentClip() {
    final playback = ref.read(playbackProvider);
    final project = ref.read(projectProvider);
    if (playback.selectedClipIndex >= 0 && playback.selectedClipIndex < project.clips.length) {
      final clip = project.clips[playback.selectedClipIndex];
      ref.read(projectProvider.notifier).updateClip(
            playback.selectedClipIndex,
            clip.copyWith(isFlippedHorizontal: !clip.isFlippedHorizontal),
          );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Flipped clip horizontally.')),
      );
    }
  }

  void _rotateCurrentClip() {
    final playback = ref.read(playbackProvider);
    final project = ref.read(projectProvider);
    if (playback.selectedClipIndex >= 0 && playback.selectedClipIndex < project.clips.length) {
      final clip = project.clips[playback.selectedClipIndex];
      final newRot = (clip.rotation + 90) % 360;
      ref.read(projectProvider.notifier).updateClip(
            playback.selectedClipIndex,
            clip.copyWith(rotation: newRot),
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
            2.0,
          );
    }
  }

  void _openSaveVideoDialog() {
    final project = ref.read(projectProvider);
    if (project.clips.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one clip before saving video.')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => SaveVideoDialog(project: project),
    );
  }

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(projectProvider);
    final playback = ref.watch(playbackProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: WindowTitleBar(
        title: '${project.title} - Movie Maker: Video Editor',
        showBackButton: true,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: Row(
        children: [
          // Mini Sidebar (Matching Images 1 & 2)
          Container(
            width: 46,
            color: const Color(0xFF1F1F1F),
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
                const Divider(color: Colors.white24, height: 16),
                IconButton(
                  icon: Icon(Icons.layers_rounded, color: isLayerDrawerOpen ? const Color(0xFF0078D7) : Colors.white70, size: 20),
                  onPressed: () => setState(() {
                    isLayerDrawerOpen = !isLayerDrawerOpen;
                    if (isLayerDrawerOpen) isAudioMixerOpen = false;
                  }),
                  tooltip: 'Overlays & Layers',
                ),
                IconButton(
                  icon: Icon(Icons.music_note_rounded, color: isAudioMixerOpen ? AppColors.musicColor : Colors.white70, size: 20),
                  onPressed: () => setState(() {
                    isAudioMixerOpen = !isAudioMixerOpen;
                    if (isAudioMixerOpen) isLayerDrawerOpen = false;
                  }),
                  tooltip: 'Audio Mixer',
                ),
                IconButton(
                  icon: const Icon(Icons.auto_fix_high_rounded, color: Colors.white70, size: 20),
                  onPressed: _openChromaKeyDialog,
                  tooltip: 'Chroma Key',
                ),
                const Spacer(),
              ],
            ),
          ),

          // Main Workspace
          Expanded(
            child: Column(
              children: [
                // Top Pro Banner & Contact (Matching Image 2)
                Container(
                  color: const Color(0xFF1A1A1A),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Row(
                          children: [
                            Icon(Icons.chevron_left, size: 14),
                            Text('ALL PROJECTS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        ),
                        icon: const Icon(Icons.contact_support_rounded, size: 14, color: Color(0xFFFF9500)),
                        label: const Text('Contact', style: TextStyle(fontSize: 11)),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFFF9500).withOpacity(0.5)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.diamond_rounded, color: Color(0xFFFF9500), size: 14),
                            SizedBox(width: 4),
                            Text('Premium', style: TextStyle(color: Color(0xFFFF9500), fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Center Content: Viewport with optional side drawers
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Expanded(
                        child: CanvasViewport(
                          onAddVideo: _addVideoPhotoClip,
                          onAddColorClip: _openColorClipDialog,
                          onAddGiphy: _openGiphyDialog,
                          onAddCamera: () {},
                        ),
                      ),
                      if (isLayerDrawerOpen)
                        OverlayManagerDrawer(
                          onAddText: _openTextDialog,
                          onAddSticker: _openGiphyDialog,
                          onAddPiP: _openPiPVideoDialog,
                        ),
                      if (isAudioMixerOpen)
                        const AudioMixerDrawer(),
                    ],
                  ),
                ),

                // Transition Drawer (Screenshot 6)
                if (playback.isTransitionDrawerOpen && playback.activeTransitionClipIndex >= 0)
                  TransitionDrawer(
                    currentTransition: project.clips[playback.activeTransitionClipIndex].transitionAfter,
                    onSelectTransition: (trans) {
                      ref.read(projectProvider.notifier).setTransition(playback.activeTransitionClipIndex, trans);
                    },
                    onClose: () => ref.read(playbackProvider.notifier).closeTransitionDrawer(),
                  ),

                // Multitrack 5-Track Timeline & Action Shelf (Matching Image 2)
                Expanded(
                  flex: 2,
                  child: MultitrackTimelineWidget(
                    onAddMedia: _openColorClipDialog,
                    onSplit: _splitCurrentClip,
                    onDuration: _showDurationDialog,
                    onEffect: _openEffectsDialog,
                    onCrop: _showCropDialog,
                    onMotion: _showMotionDialog,
                    onTransform: () {},
                    onRotate: _rotateCurrentClip,
                    onFlip: _flipCurrentClip,
                    onSaveVideo: _openSaveVideoDialog,
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
