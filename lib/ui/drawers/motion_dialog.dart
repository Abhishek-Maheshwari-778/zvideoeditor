import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum MotionPreset {
  none,
  zoomInCenter,
  zoomOutCenter,
  panLeftToRight,
  panRightToLeft,
  zoomInTopLeft,
  zoomOutBottomRight,
}

class MotionDialog extends StatefulWidget {
  final void Function(MotionPreset) onApplyMotion;

  const MotionDialog({super.key, required this.onApplyMotion});

  @override
  State<MotionDialog> createState() => _MotionDialogState();
}

class _MotionDialogState extends State<MotionDialog> {
  MotionPreset selectedMotion = MotionPreset.zoomInCenter;

  final List<Map<String, dynamic>> motionOptions = [
    {'preset': MotionPreset.none, 'label': 'None (Static)', 'icon': Icons.block_rounded},
    {'preset': MotionPreset.zoomInCenter, 'label': 'Zoom In Center', 'icon': Icons.zoom_in_rounded},
    {'preset': MotionPreset.zoomOutCenter, 'label': 'Zoom Out Center', 'icon': Icons.zoom_out_rounded},
    {'preset': MotionPreset.panLeftToRight, 'label': 'Pan Left to Right', 'icon': Icons.arrow_forward_rounded},
    {'preset': MotionPreset.panRightToLeft, 'label': 'Pan Right to Left', 'icon': Icons.arrow_back_rounded},
    {'preset': MotionPreset.zoomInTopLeft, 'label': 'Zoom In Top-Left', 'icon': Icons.north_west_rounded},
    {'preset': MotionPreset.zoomOutBottomRight, 'label': 'Zoom Out Bottom-Right', 'icon': Icons.south_east_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.directions_run_rounded, color: Color(0xFF0078D7), size: 22),
                    SizedBox(width: 8),
                    Text('Motion & Pan-Zoom (Ken Burns)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close, color: Colors.white70, size: 20), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
            const SizedBox(height: 16),

            // Motion Presets Grid
            GridView.builder(
              shrinkWrap: true,
              itemCount: motionOptions.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 3.2,
              ),
              itemBuilder: (context, index) {
                final opt = motionOptions[index];
                final isSelected = selectedMotion == opt['preset'];

                return InkWell(
                  onTap: () => setState(() => selectedMotion = opt['preset'] as MotionPreset),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF0078D7).withOpacity(0.2) : const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF0078D7) : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(opt['icon'] as IconData, color: isSelected ? const Color(0xFF0078D7) : Colors.white70, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            opt['label'] as String,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Apply Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0078D7)),
                onPressed: () {
                  widget.onApplyMotion(selectedMotion);
                  Navigator.of(context).pop();
                },
                child: const Text('Apply Camera Motion', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
