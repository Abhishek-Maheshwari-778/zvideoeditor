import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/project_model.dart';
import '../../models/clip_model.dart';
import '../../models/overlay_layer_model.dart';
import '../../state/project_state.dart';
import '../../state/playback_state.dart';
import '../drawers/add_media_menu.dart';

class CanvasViewport extends ConsumerWidget {
  final VoidCallback onAddVideo;
  final VoidCallback onAddColorClip;
  final VoidCallback onAddGiphy;
  final VoidCallback onAddCamera;

  const CanvasViewport({
    super.key,
    required this.onAddVideo,
    required this.onAddColorClip,
    required this.onAddGiphy,
    required this.onAddCamera,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider);
    final playback = ref.watch(playbackProvider);
    final aspectRatio = project.aspectRatio.value;

    return Center(
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF181818),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background / Active Video Frame
              if (project.clips.isEmpty)
                _buildEmptyDropzone(context)
              else
                _buildActiveClipRender(project, playback),

              // Overlays (Text / Stickers / Watermark)
              ..._buildOverlayLayers(project, playback),

              // Watermark Preview (Matching Screenshot 5)
              if (project.hasWatermark || true)
                Positioned(
                  right: 20,
                  bottom: 16,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'MADE IN',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const Text(
                            'Z-MOVIE MAKER',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.close, color: Colors.white, size: 9),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyDropzone(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Dotted frame & icon (Screenshot 2)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5, strokeAlign: BorderSide.strokeAlignCenter),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.video_library_outlined, color: Colors.white.withOpacity(0.7), size: 48),
          ),
          const SizedBox(height: 16),
          Text(
            'Select one or more video or photo files or drag and drop them here',
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
          ),
          const SizedBox(height: 16),
          // Add button with Popover trigger (Screenshot 2 & 3)
          PopupMenuButton(
            offset: const Offset(0, -220),
            color: Colors.transparent,
            elevation: 0,
            itemBuilder: (context) => [
              PopupMenuItem(
                padding: EdgeInsets.zero,
                child: AddMediaMenu(
                  onAddVideoPhoto: () {
                    Navigator.of(context).pop();
                    onAddVideo();
                  },
                  onAddColorClip: () {
                    Navigator.of(context).pop();
                    onAddColorClip();
                  },
                  onAddGiphy: () {
                    Navigator.of(context).pop();
                    onAddGiphy();
                  },
                  onAddCamera: () {
                    Navigator.of(context).pop();
                    onAddCamera();
                  },
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Add video/photo clips',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveClipRender(ProjectModel project, PlaybackState playback) {
    // Find active clip corresponding to current playhead timestamp
    double accumulatedTime = 0.0;
    ClipModel? activeClip;

    for (final clip in project.clips) {
      if (playback.currentTime >= accumulatedTime && playback.currentTime <= accumulatedTime + clip.duration) {
        activeClip = clip;
        break;
      }
      accumulatedTime += clip.duration;
    }

    activeClip ??= project.clips.isNotEmpty ? project.clips.first : null;

    if (activeClip == null) return Container(color: Colors.black);

    if (activeClip.type == ClipType.gradient && activeClip.gradientColorsHex != null) {
      final colors = activeClip.gradientColorsHex!.map((hex) {
        final hexClean = hex.replaceAll('#', '');
        return Color(int.parse('FF$hexClean', radix: 16));
      }).toList();

      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors.length >= 2 ? colors : [colors.first, colors.first],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      );
    } else if (activeClip.type == ClipType.solidColor && activeClip.solidColorHex != null) {
      final hexClean = activeClip.solidColorHex!.replaceAll('#', '');
      return Container(color: Color(int.parse('FF$hexClean', radix: 16)));
    }

    // Video / Image Preview with Dark canvas background
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_fill_rounded, color: Colors.white.withOpacity(0.6), size: 54),
            const SizedBox(height: 10),
            Text(
              activeClip.name,
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOverlayLayers(ProjectModel project, PlaybackState playback) {
    final List<Widget> widgets = [];
    for (final overlay in project.overlays) {
      if (playback.currentTime >= overlay.startTime && playback.currentTime <= overlay.startTime + overlay.duration) {
        if (overlay.type == OverlayType.text) {
          final hex = overlay.fontColorHex.replaceAll('#', '');
          final color = Color(int.parse('FF$hex', radix: 16));
          widgets.add(
            Positioned(
              left: overlay.posX * 400,
              top: overlay.posY * 250,
              child: Text(
                overlay.content,
                style: TextStyle(
                  fontSize: overlay.fontSize,
                  color: color,
                  fontWeight: overlay.isBold ? FontWeight.bold : FontWeight.normal,
                  fontStyle: overlay.isItalic ? FontStyle.italic : FontStyle.normal,
                  shadows: overlay.hasShadow ? const [Shadow(color: Colors.black, blurRadius: 4)] : null,
                ),
              ),
            ),
          );
        }
      }
    }
    return widgets;
  }
}
