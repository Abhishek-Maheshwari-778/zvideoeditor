import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;
import '../../core/constants/app_colors.dart';
import '../../models/overlay_layer_model.dart';
import '../../state/project_state.dart';

class AudioMixerDrawer extends ConsumerWidget {
  const AudioMixerDrawer({super.key});

  Future<void> _addAudioTrack(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      final file = result.files.single;
      final track = AudioTrackModel(
        id: 'audio-${const Uuid().v4().substring(0, 8)}',
        name: file.name,
        filePath: file.path!,
        startTime: 0.0,
        duration: 30.0,
        volume: 0.8,
        autoDucking: true,
      );
      ref.read(projectProvider.notifier).addAudioTrack(track);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider);

    return Container(
      width: 320,
      color: const Color(0xFF252526),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF1E1E1E),
            child: Row(
              children: [
                const Icon(Icons.music_note_rounded, color: AppColors.musicColor, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Multi-Track Audio Mixer',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add, color: AppColors.primary, size: 20),
                  tooltip: 'Add Audio Track',
                  onPressed: () => _addAudioTrack(context, ref),
                ),
              ],
            ),
          ),

          // Master Video Track Audio Channel
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2E2E2E),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.movie_filter_rounded, color: Colors.white70, size: 16),
                    SizedBox(width: 6),
                    Text('Main Video Audio', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.volume_up, color: Colors.grey, size: 16),
                    Expanded(
                      child: Slider(
                        value: 1.0,
                        min: 0.0,
                        max: 2.0,
                        activeColor: AppColors.primary,
                        onChanged: (_) {},
                      ),
                    ),
                    const Text('100%', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),

          // Custom Audio Tracks List
          Expanded(
            child: project.audioTracks.isEmpty
                ? const Center(
                    child: Text('No background audio tracks added.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  )
                : ListView.builder(
                    itemCount: project.audioTracks.length,
                    itemBuilder: (context, index) {
                      final track = project.audioTracks[index];

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E2E2E),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  track.isVoiceover ? Icons.mic : Icons.audiotrack,
                                  color: AppColors.musicColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    track.name,
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                                  onPressed: () => ref.read(projectProvider.notifier).removeAudioTrackAt(index),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Slider(
                                    value: track.volume,
                                    min: 0.0,
                                    max: 2.0,
                                    activeColor: AppColors.musicColor,
                                    onChanged: (val) {
                                      ref.read(projectProvider.notifier).updateAudioTrack(
                                            index,
                                            track.copyWith(volume: val),
                                          );
                                    },
                                  ),
                                ),
                                Text(
                                  '${(track.volume * 100).toInt()}%',
                                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text('Auto-Ducking: ', style: TextStyle(color: Colors.grey, fontSize: 10)),
                                Switch(
                                  value: track.autoDucking,
                                  activeColor: AppColors.musicColor,
                                  onChanged: (val) {
                                    ref.read(projectProvider.notifier).updateAudioTrack(
                                          index,
                                          track.copyWith(autoDucking: val),
                                        );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
