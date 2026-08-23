import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/clip_model.dart';
import '../../state/project_state.dart';
import '../../state/playback_state.dart';

class StoryboardWidget extends ConsumerWidget {
  final VoidCallback onAddClip;

  const StoryboardWidget({super.key, required this.onAddClip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider);
    final playback = ref.watch(playbackProvider);

    return Container(
      height: 120,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (int i = 0; i < project.clips.length; i++) ...[
                _buildClipThumbnail(context, ref, project.clips[i], i, playback.selectedClipIndex == i),
                // Transition '+' Connector between clips (Screenshot 5)
                _buildTransitionConnector(context, ref, i, project.clips[i]),
              ],
              // Add New Clip '+' Button at the end of storyboard
              InkWell(
                onTap: onAddClip,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: const Icon(Icons.add, color: AppColors.primary, size: 28),
                ),
              ),
              if (project.clips.isNotEmpty) ...[
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Duration: ${PlaybackState.formatTimecode(project.totalDuration)}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF555555)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClipThumbnail(BuildContext context, WidgetRef ref, ClipModel clip, int index, bool isSelected) {
    List<Color> gradientColors = [const Color(0xFF8A2387), const Color(0xFFE94057)];
    if (clip.gradientColorsHex != null && clip.gradientColorsHex!.isNotEmpty) {
      gradientColors = clip.gradientColorsHex!.map((h) {
        final c = h.replaceAll('#', '');
        return Color(int.parse('FF$c', radix: 16));
      }).toList();
    } else if (clip.solidColorHex != null) {
      final c = clip.solidColorHex!.replaceAll('#', '');
      gradientColors = [Color(int.parse('FF$c', radix: 16)), Color(int.parse('FF$c', radix: 16))];
    }

    final durationSecs = clip.duration.toInt();
    final durationStr = '00:${durationSecs.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: () => ref.read(playbackProvider.notifier).selectClip(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: gradientColors.length >= 2 ? gradientColors : [gradientColors.first, gradientColors.first],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: isSelected ? 3 : 0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                if (isSelected)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: InkWell(
                      onTap: () => ref.read(projectProvider.notifier).removeClipAt(index),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.delete_outline, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.access_time_rounded, size: 10, color: Colors.grey),
              const SizedBox(width: 2),
              Text(
                durationStr,
                style: const TextStyle(fontSize: 10, color: Color(0xFF666666), fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransitionConnector(BuildContext context, WidgetRef ref, int index, ClipModel clip) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: () => ref.read(playbackProvider.notifier).openTransitionDrawer(index),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: clip.transitionAfter != null ? AppColors.primary : const Color(0xFFFF9500),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.add, color: Colors.white, size: 16),
          ),
        ),
      ),
    );
  }
}
