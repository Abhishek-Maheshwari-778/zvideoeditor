import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/project_model.dart';
import '../../state/project_state.dart';
import '../../state/playback_state.dart';

class TimelineScrubBar extends ConsumerWidget {
  const TimelineScrubBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider);
    final playback = ref.watch(playbackProvider);
    final totalDuration = project.totalDuration > 0 ? project.totalDuration : 4.0;
    final currentFormatted = PlaybackState.formatTimecode(playback.currentTime);
    final totalFormatted = PlaybackState.formatTimecode(totalDuration);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: [
          // Top Transport & Utility Control Bar (Screenshot 4 & 5)
          Row(
            children: [
              // Canvas Aspect Ratio / Settings Cog
              PopupMenuButton<CanvasAspectRatio>(
                icon: const Icon(Icons.settings_outlined, size: 20, color: Color(0xFF555555)),
                tooltip: 'Aspect Ratio & Canvas Settings',
                onSelected: (ratio) => ref.read(projectProvider.notifier).updateAspectRatio(ratio),
                itemBuilder: (_) => CanvasAspectRatio.values.map((ratio) {
                  return PopupMenuItem(
                    value: ratio,
                    child: Text(ratio.displayName),
                  );
                }).toList(),
              ),
              const SizedBox(width: 8),

              // Timecode Text (Screenshot 4: 0:00:0.00 / 0:00:4.00)
              Text(
                '$currentFormatted / $totalFormatted',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const Spacer(),

              // Central Transport Buttons
              IconButton(
                icon: const Icon(Icons.skip_previous_rounded, size: 20),
                tooltip: 'Jump to Start',
                onPressed: () => ref.read(playbackProvider.notifier).seekTo(0.0, totalDuration),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_left_rounded, size: 26),
                tooltip: 'Step 1 Frame Backward',
                onPressed: () => ref.read(playbackProvider.notifier).stepFrameBackward(),
              ),
              IconButton(
                icon: Icon(
                  playback.isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_arrow_rounded,
                  size: 28,
                  color: AppColors.textPrimary,
                ),
                tooltip: 'Play / Pause',
                onPressed: () => ref.read(playbackProvider.notifier).togglePlay(),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_right_rounded, size: 26),
                tooltip: 'Step 1 Frame Forward',
                onPressed: () => ref.read(playbackProvider.notifier).stepFrameForward(totalDuration),
              ),
              IconButton(
                icon: const Icon(Icons.skip_next_rounded, size: 20),
                tooltip: 'Jump to End',
                onPressed: () => ref.read(playbackProvider.notifier).seekTo(totalDuration, totalDuration),
              ),
              IconButton(
                icon: Icon(
                  playback.isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  size: 20,
                ),
                tooltip: 'Mute / Unmute',
                onPressed: () => ref.read(playbackProvider.notifier).toggleMute(),
              ),

              const Spacer(),

              // Right Utility Buttons (Undo, Redo, Grid, Layers, Fullscreen)
              IconButton(
                icon: const Icon(Icons.undo_rounded, size: 18),
                tooltip: 'Undo',
                onPressed: () => ref.read(projectProvider.notifier).undo(),
              ),
              IconButton(
                icon: const Icon(Icons.redo_rounded, size: 18),
                tooltip: 'Redo',
                onPressed: () => ref.read(projectProvider.notifier).redo(),
              ),
              IconButton(
                icon: const Icon(Icons.grid_on_rounded, size: 18),
                tooltip: 'Canvas Grid / Background',
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 18),
                tooltip: 'Duplicate',
                onPressed: () {
                  if (playback.selectedClipIndex >= 0) {
                    ref.read(projectProvider.notifier).duplicateClipAt(playback.selectedClipIndex);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.layers_outlined, size: 18),
                tooltip: 'Overlays & Layers',
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.fullscreen_rounded, size: 20),
                tooltip: 'Fullscreen View',
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Interactive Timeline Scrubber with Orange Playhead (Screenshot 4 & 5)
          SizedBox(
            height: 32,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Base Timeline Track
                Container(
                  height: 4,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Orange Progress Bar
                LayoutBuilder(
                  builder: (context, constraints) {
                    final progress = (playback.currentTime / totalDuration).clamp(0.0, 1.0);
                    final playheadX = constraints.maxWidth * progress;

                    return Stack(
                      children: [
                        Container(
                          height: 4,
                          width: playheadX,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        // Orange Playhead Knob with Stem & Ring (Screenshot 4 & 5)
                        Positioned(
                          left: (playheadX - 10).clamp(0.0, constraints.maxWidth - 20),
                          top: 2,
                          child: GestureDetector(
                            onHorizontalDragUpdate: (details) {
                              final newPos = (playheadX + details.delta.dx) / constraints.maxWidth;
                              final newTime = newPos * totalDuration;
                              ref.read(playbackProvider.notifier).seekTo(newTime, totalDuration);
                            },
                            child: Column(
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [AppColors.proGradientStart, AppColors.proGradientMid],
                                    ),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                Container(
                                  width: 2,
                                  height: 10,
                                  color: AppColors.playheadOrange,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
