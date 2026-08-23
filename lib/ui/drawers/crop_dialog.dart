import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CropDialog extends StatefulWidget {
  final void Function(double left, double top, double width, double height) onApplyCrop;

  const CropDialog({super.key, required this.onApplyCrop});

  @override
  State<CropDialog> createState() => _CropDialogState();
}

class _CropDialogState extends State<CropDialog> {
  String selectedPreset = '16:9';
  double cropScale = 0.85;

  final List<String> aspectPresets = ['Freeform', '16:9 (Landscape)', '9:16 (Vertical)', '1:1 (Square)', '4:3 (Classic)'];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 500,
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
                    Icon(Icons.crop_rounded, color: Color(0xFF0078D7), size: 22),
                    SizedBox(width: 8),
                    Text('Crop Video Canvas', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close, color: Colors.white70, size: 20), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
            const SizedBox(height: 16),

            // Live Interactive Crop Frame
            Center(
              child: Container(
                width: 320,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Container(
                    width: 320 * cropScale,
                    height: 180 * cropScale,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF0078D7), width: 2),
                    ),
                    child: const Center(
                      child: Icon(Icons.grid_3x3_rounded, color: Colors.white24, size: 48),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Aspect Presets
            const Text('Aspect Ratio Preset', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: aspectPresets.map((p) {
                final isSelected = selectedPreset == p;
                return ChoiceChip(
                  label: Text(p, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 11)),
                  selected: isSelected,
                  selectedColor: const Color(0xFF0078D7),
                  backgroundColor: const Color(0xFF2A2A2A),
                  onSelected: (_) => setState(() => selectedPreset = p),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Crop Scale Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Crop Zoom Level', style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text('${(cropScale * 100).toInt()}%', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            Slider(
              value: cropScale,
              min: 0.3,
              max: 1.0,
              activeColor: const Color(0xFF0078D7),
              onChanged: (v) => setState(() => cropScale = v),
            ),
            const SizedBox(height: 20),

            // Apply Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0078D7)),
                onPressed: () {
                  widget.onApplyCrop(0.1, 0.1, cropScale, cropScale);
                  Navigator.of(context).pop();
                },
                child: const Text('Apply Crop Area', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
