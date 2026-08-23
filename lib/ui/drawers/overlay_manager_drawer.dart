import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/overlay_layer_model.dart';
import '../../state/project_state.dart';
import '../../state/playback_state.dart';
import 'text_editor_dialog.dart';

class OverlayManagerDrawer extends ConsumerWidget {
  final VoidCallback onAddText;
  final VoidCallback onAddSticker;
  final VoidCallback onAddPiP;

  const OverlayManagerDrawer({
    super.key,
    required this.onAddText,
    required this.onAddSticker,
    required this.onAddPiP,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider);
    final playback = ref.watch(playbackProvider);

    return Container(
      width: 320,
      color: const Color(0xFF252526),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF1E1E1E),
            child: Row(
              children: [
                const Icon(Icons.layers_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Layers & Overlays',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${project.overlays.length} active',
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),

          // Quick Add Row
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(Icons.text_fields, size: 16, color: Colors.white),
                    label: const Text('Text', style: TextStyle(fontSize: 12, color: Colors.white)),
                    onPressed: onAddText,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9C27B0),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(Icons.emoji_emotions_outlined, size: 16, color: Colors.white),
                    label: const Text('Sticker', style: TextStyle(fontSize: 12, color: Colors.white)),
                    onPressed: onAddSticker,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0078D7),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(Icons.picture_in_picture, size: 16, color: Colors.white),
                    label: const Text('PiP', style: TextStyle(fontSize: 12, color: Colors.white)),
                    onPressed: onAddPiP,
                  ),
                ),
              ],
            ),
          ),

          // Layer List
          Expanded(
            child: project.overlays.isEmpty
                ? const Center(
                    child: Text('No overlay layers added yet.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  )
                : ReorderableListView.builder(
                    itemCount: project.overlays.length,
                    onReorder: (oldIdx, newIdx) {
                      ref.read(projectProvider.notifier).reorderOverlays(oldIdx, newIdx);
                    },
                    itemBuilder: (context, index) {
                      final overlay = project.overlays[index];
                      final isSelected = playback.selectedOverlayIndex == index;

                      return Container(
                        key: ValueKey(overlay.id),
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withOpacity(0.15) : const Color(0xFF2E2E2E),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                          ),
                        ),
                        child: ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          leading: Icon(
                            _getOverlayIcon(overlay.type),
                            color: isSelected ? AppColors.primary : Colors.white70,
                            size: 18,
                          ),
                          title: Text(
                            overlay.type == OverlayType.text ? overlay.content : overlay.name,
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '⏱ ${overlay.startTime.toStringAsFixed(1)}s - ${(overlay.startTime + overlay.duration).toStringAsFixed(1)}s',
                            style: const TextStyle(color: Colors.grey, fontSize: 10),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Visibility toggle
                              IconButton(
                                icon: Icon(
                                  overlay.isVisible ? Icons.visibility : Icons.visibility_off,
                                  size: 16,
                                  color: overlay.isVisible ? Colors.white70 : Colors.grey,
                                ),
                                onPressed: () => ref.read(projectProvider.notifier).toggleOverlayVisibility(index),
                              ),
                              // Delete button
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                                onPressed: () => ref.read(projectProvider.notifier).removeOverlayAt(index),
                              ),
                            ],
                          ),
                          onTap: () {
                            ref.read(playbackProvider.notifier).selectOverlay(index);
                            if (overlay.type == OverlayType.text) {
                              showDialog(
                                context: context,
                                builder: (_) => TextEditorDialog(
                                  initialOverlay: overlay,
                                  onSave: (updated) => ref.read(projectProvider.notifier).updateOverlay(index, updated),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  IconData _getOverlayIcon(OverlayType type) {
    switch (type) {
      case OverlayType.text:
        return Icons.text_fields_rounded;
      case OverlayType.sticker:
        return Icons.emoji_emotions_rounded;
      case OverlayType.gif:
        return Icons.gif_box_rounded;
      case OverlayType.pipVideo:
        return Icons.picture_in_picture_rounded;
      case OverlayType.watermark:
        return Icons.branding_watermark_rounded;
    }
  }
}
