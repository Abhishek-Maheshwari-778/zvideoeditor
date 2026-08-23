import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/overlay_layer_model.dart';

class ChromaKeyDialog extends StatefulWidget {
  final ChromaKeyConfig initialConfig;
  final void Function(ChromaKeyConfig) onApply;

  const ChromaKeyDialog({
    super.key,
    required this.initialConfig,
    required this.onApply,
  });

  @override
  State<ChromaKeyDialog> createState() => _ChromaKeyDialogState();
}

class _ChromaKeyDialogState extends State<ChromaKeyDialog> {
  late bool enabled;
  late Color selectedColor;
  late double similarity;
  late double smoothness;

  final List<Color> keyColorPresets = [
    const Color(0xFF00FF00), // Standard Green Screen
    const Color(0xFF0000FF), // Standard Blue Screen
    const Color(0xFF00E676), // Bright Green
    const Color(0xFF00B0FF), // Light Blue
    const Color(0xFFFF00FF), // Magenta
    const Color(0xFF000000), // Black
    const Color(0xFFFFFFFF), // White
  ];

  @override
  void initState() {
    super.initState();
    enabled = widget.initialConfig.enabled;
    final hex = widget.initialConfig.targetColorHex.replaceAll('#', '');
    selectedColor = Color(int.parse('FF$hex', radix: 16));
    similarity = widget.initialConfig.similarity;
    smoothness = widget.initialConfig.smoothness;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Chroma Key (Green Screen)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Switch(
                  value: enabled,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => enabled = val),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Key Color Swatches
            const Text('Target Key Color', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: keyColorPresets.map((c) {
                final isPicked = selectedColor == c;
                return GestureDetector(
                  onTap: () => setState(() => selectedColor = c),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: c,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: isPicked ? AppColors.primary : Colors.grey.shade400, width: 2.5),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Similarity Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Similarity / Tolerance', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                Text(similarity.toStringAsFixed(2), style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            Slider(
              value: similarity,
              min: 0.05,
              max: 0.8,
              activeColor: AppColors.primary,
              onChanged: enabled ? (val) => setState(() => similarity = val) : null,
            ),
            const SizedBox(height: 8),

            // Smoothness Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Smoothness / Feathering', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                Text(smoothness.toStringAsFixed(2), style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            Slider(
              value: smoothness,
              min: 0.0,
              max: 0.5,
              activeColor: AppColors.primary,
              onChanged: enabled ? (val) => setState(() => smoothness = val) : null,
            ),
            const SizedBox(height: 20),

            // Apply Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    onPressed: () {
                      final hex =
                          '#${selectedColor.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
                      final config = ChromaKeyConfig(
                        enabled: enabled,
                        targetColorHex: hex,
                        similarity: similarity,
                        smoothness: smoothness,
                      );
                      widget.onApply(config);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Apply Chroma Key', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
