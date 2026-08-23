import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/project_model.dart';
import '../../models/clip_model.dart';
import '../../state/project_state.dart';
import '../../state/playback_state.dart';

class MultitrackTimelineWidget extends ConsumerStatefulWidget {
  final VoidCallback onAddMedia;
  final VoidCallback onSplit;
  final VoidCallback onDuration;
  final VoidCallback onEffect;
  final VoidCallback onCrop;
  final VoidCallback onMotion;
  final VoidCallback onTransform;
  final VoidCallback onRotate;
  final VoidCallback onFlip;
  final VoidCallback onSaveVideo;

  const MultitrackTimelineWidget({
    super.key,
    required this.onAddMedia,
    required this.onSplit,
    required this.onDuration,
    required this.onEffect,
    required this.onCrop,
    required this.onMotion,
    required this.onTransform,
    required this.onRotate,
    required this.onFlip,
    required this.onSaveVideo,
  });

  @override
  ConsumerState<MultitrackTimelineWidget> createState() => _MultitrackTimelineWidgetState();
}

class _MultitrackTimelineWidgetState extends ConsumerState<MultitrackTimelineWidget> {
  double zoomFactor = 1.0; // 0.5x to 3.0x timeline scale

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(projectProvider);
    final playback = ref.watch(playbackProvider);
    final totalDuration = project.totalDuration > 0 ? project.totalDuration : 3.0;

    return Container(
      color: const Color(0xFF181818),
      child: Column(
        children: [
          // 1. Top Transport & Zoom Controls Bar (Matching Image 2)
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: const Color(0xFF1F1F1F),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.save_rounded, color: Colors.white70, size: 16), onPressed: () {}, tooltip: 'Save'),
                IconButton(icon: const Icon(Icons.undo_rounded, color: Colors.white70, size: 16), onPressed: () => ref.read(projectProvider.notifier).undo(), tooltip: 'Undo'),
                IconButton(icon: const Icon(Icons.redo_rounded, color: Colors.white70, size: 16), onPressed: () => ref.read(projectProvider.notifier).redo(), tooltip: 'Redo'),
                const SizedBox(width: 8),

                IconButton(
                  icon: const Icon(Icons.skip_previous_rounded, color: Colors.white70, size: 18),
                  onPressed: () => ref.read(playbackProvider.notifier).seekTo(0, totalDuration),
                ),
                IconButton(
                  icon: Icon(
                    playback.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => ref.read(playbackProvider.notifier).togglePlay(),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next_rounded, color: Colors.white70, size: 18),
                  onPressed: () => ref.read(playbackProvider.notifier).seekTo(totalDuration, totalDuration),
                ),
                IconButton(
                  icon: Icon(playback.isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded, color: Colors.white70, size: 16),
                  onPressed: () => ref.read(playbackProvider.notifier).toggleMute(),
                ),

                const SizedBox(width: 12),
                // Timecode
                Text(
                  '${PlaybackState.formatTimecode(playback.currentTime)} / ${PlaybackState.formatTimecode(totalDuration)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                ),
                const Spacer(),

                // Aspect Ratio Selector
                PopupMenuButton<CanvasAspectRatio>(
                  icon: const Icon(Icons.aspect_ratio_rounded, color: Colors.white70, size: 16),
                  tooltip: 'Canvas Aspect Ratio',
                  onSelected: (r) => ref.read(projectProvider.notifier).updateAspectRatio(r),
                  itemBuilder: (_) => CanvasAspectRatio.values.map((r) => PopupMenuItem(value: r, child: Text(r.displayName))).toList(),
                ),
                const Icon(Icons.fullscreen_rounded, color: Colors.white70, size: 18),
                const SizedBox(width: 12),

                // Zoom Slider Controls (- / + / Fit) (Matching Image 2)
                const Icon(Icons.fit_screen_rounded, color: Colors.white70, size: 14),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.white70, size: 14),
                  onPressed: () => setState(() => zoomFactor = (zoomFactor - 0.2).clamp(0.5, 3.0)),
                ),
                SizedBox(
                  width: 80,
                  child: Slider(
                    value: zoomFactor,
                    min: 0.5,
                    max: 3.0,
                    activeColor: const Color(0xFF0078D7),
                    onChanged: (v) => setState(() => zoomFactor = v),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white70, size: 14),
                  onPressed: () => setState(() => zoomFactor = (zoomFactor + 0.2).clamp(0.5, 3.0)),
                ),
              ],
            ),
          ),

          // 2. 5-Track Multitrack Timeline Area (Matching Image 2)
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: (MediaQuery.of(context).size.width * zoomFactor).clamp(1000.0, 5000.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Time Ruler
                        _buildTimeRuler(totalDuration),

                        // Track 1: Master Video / Clip Track (Image 2)
                        _buildVideoTrack(project, playback),

                        // Track 2: Audio Track (🎵 0)
                        _buildGenericTrackRow(
                          icon: Icons.music_note_rounded,
                          count: project.audioTracks.length,
                          color: const Color(0xFF3B82F6),
                        ),

                        // Track 3: Overlay / PiP Track (🖼️ 0)
                        _buildGenericTrackRow(
                          icon: Icons.image_rounded,
                          count: project.overlays.where((o) => o.type == OverlayType.pipVideo || o.type == OverlayType.sticker).length,
                          color: const Color(0xFF9C27B0),
                        ),

                        // Track 4: Text Track (🔤 0)
                        _buildGenericTrackRow(
                          icon: Icons.text_fields_rounded,
                          count: project.overlays.where((o) => o.type == OverlayType.text).length,
                          color: const Color(0xFFFF9800),
                        ),

                        // Track 5: Effect / Filter Track (🎞️ 0)
                        _buildGenericTrackRow(
                          icon: Icons.movie_filter_rounded,
                          count: 0,
                          color: const Color(0xFF00C853),
                        ),
                      ],
                    ),
                  ),
                ),

                // Floating '+' Quick Add Button (Matching Image 2)
                Positioned(
                  right: 20,
                  top: 40,
                  child: FloatingActionButton.small(
                    backgroundColor: const Color(0xFF6B116A),
                    onPressed: widget.onAddMedia,
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),

          // 3. Bottom Action Shelf (Matching Image 2)
          Container(
            height: 52,
            color: const Color(0xFF1E1E1E),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                // Back Button (Blue square from Image 2)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0078D7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 16),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 14),

                _ShelfAction(icon: Icons.add, label: 'Add', onTap: widget.onAddMedia),
                _ShelfAction(icon: Icons.splitscreen_rounded, label: 'Split', onTap: widget.onSplit),
                _ShelfAction(icon: Icons.access_time_rounded, label: 'Duration', onTap: widget.onDuration),
                _ShelfAction(icon: Icons.palette_outlined, label: 'Effect', onTap: widget.onEffect),
                _ShelfAction(icon: Icons.crop_rounded, label: 'Crop', onTap: widget.onCrop),
                _ShelfAction(icon: Icons.directions_run_rounded, label: 'Motion', onTap: widget.onMotion),
                _ShelfAction(icon: Icons.crop_free_rounded, label: 'Transform', onTap: widget.onTransform),
                _ShelfAction(icon: Icons.rotate_right_rounded, label: 'Rotate', onTap: widget.onRotate),
                _ShelfAction(icon: Icons.flip_rounded, label: 'Flip', onTap: widget.onFlip),
                _ShelfAction(
                  icon: Icons.copy_rounded,
                  label: 'Duplicate',
                  onTap: () {
                    if (playback.selectedClipIndex >= 0) {
                      ref.read(projectProvider.notifier).duplicateClipAt(playback.selectedClipIndex);
                    }
                  },
                ),
                _ShelfAction(
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete',
                  onTap: () {
                    if (playback.selectedClipIndex >= 0) {
                      ref.read(projectProvider.notifier).removeClipAt(playback.selectedClipIndex);
                    }
                  },
                ),

                const Spacer(),

                // Save Video Button (Blue button on bottom right of Image 2)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0078D7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  icon: const Icon(Icons.save_rounded, color: Colors.white, size: 16),
                  label: const Text('Save Video', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  onPressed: widget.onSaveVideo,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRuler(double totalDuration) {
    return Container(
      height: 20,
      color: const Color(0xFF141414),
      child: Row(
        children: List.generate(12, (i) {
          final s = i.toString().padLeft(2, '0');
          return Expanded(
            child: Container(
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: Colors.white24, width: 0.8)),
              ),
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                '00:00:$s.0',
                style: const TextStyle(color: Colors.white38, fontSize: 9),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildVideoTrack(ProjectModel project, PlaybackState playback) {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 2),
      color: const Color(0xFF222222),
      child: Row(
        children: [
          // Volume Speaker Header on left (Image 2)
          Container(
            width: 32,
            height: 48,
            color: const Color(0xFF1A1A1A),
            child: const Icon(Icons.volume_up_rounded, color: Colors.white54, size: 14),
          ),
          const SizedBox(width: 6),

          // Draggable Clustered Filmstrip Clips (Image 2)
          Expanded(
            child: project.clips.isEmpty
                ? const Center(child: Text('Click + to add video or gradient clips', style: TextStyle(color: Colors.white38, fontSize: 11)))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: project.clips.length,
                    itemBuilder: (context, index) {
                      final clip = project.clips[index];
                      final isSelected = playback.selectedClipIndex == index;

                      return GestureDetector(
                        onTap: () => ref.read(playbackProvider.notifier).selectClip(index),
                        child: Container(
                          width: (clip.duration * 60 * zoomFactor).clamp(80.0, 1000.0),
                          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)],
                            ),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Left Bracket Handle [< (Image 2)
                              const Positioned(
                                left: 2,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: Icon(Icons.arrow_left, size: 14, color: Colors.white70),
                                ),
                              ),
                              // Duration Tag
                              Positioned(
                                left: 16,
                                top: 4,
                                child: Text(
                                  '⏱ 00:00:0${clip.duration.toInt()}',
                                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                              // Right Bracket Handle >] (Image 2)
                              const Positioned(
                                right: 2,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: Icon(Icons.arrow_right, size: 14, color: Colors.white70),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenericTrackRow({
    required IconData icon,
    required int count,
    required Color color,
  }) {
    return Container(
      height: 28,
      margin: const EdgeInsets.symmetric(vertical: 2),
      color: const Color(0xFF222222),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 28,
            color: const Color(0xFF1A1A1A),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white54, size: 13),
                const SizedBox(width: 2),
                Text('$count', style: const TextStyle(color: Colors.white38, fontSize: 8)),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShelfAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ShelfAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      hoverColor: Colors.white.withOpacity(0.06),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
