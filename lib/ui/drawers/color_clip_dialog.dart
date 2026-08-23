import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../models/clip_model.dart';

class ColorClipDialog extends StatefulWidget {
  final void Function(ClipModel) onAddClip;

  const ColorClipDialog({super.key, required this.onAddClip});

  @override
  State<ColorClipDialog> createState() => _ColorClipDialogState();
}

class _ColorClipDialogState extends State<ColorClipDialog> {
  bool isGradient = true;
  double duration = 4.0;
  List<Color> gradientColors = [
    const Color(0xFF8A2387),
    const Color(0xFFE94057),
    const Color(0xFFF27121),
  ];
  Color solidColor = const Color(0xFFE91E63);

  final List<List<Color>> gradientPresets = [
    [const Color(0xFF8A2387), const Color(0xFFE94057), const Color(0xFFF27121)], // Animotica Pro Gradient
    [const Color(0xFF4A00E0), const Color(0xFF8E2DE2)], // Neon Violet
    [const Color(0xFF00C9FF), const Color(0xFF92FE9D)], // Cool Cyan/Mint
    [const Color(0xFFFF416C), const Color(0xFFFF4B2B)], // Crimson Sunset
    [const Color(0xFFF12711), const Color(0xFFF5AF19)], // Flame Orange
    [const Color(0xFF11998E), const Color(0xFF38EF7D)], // Emerald Lush
    [const Color(0xFF2C3E50), const Color(0xFF000000)], // Dark Noir
  ];

  final List<Color> solidPresets = [
    const Color(0xFF000000),
    const Color(0xFFFFFFFF),
    const Color(0xFFE91E63),
    const Color(0xFFFF5722),
    const Color(0xFF4CAF50),
    const Color(0xFF2196F3),
    const Color(0xFF9C27B0),
    const Color(0xFFFFC107),
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
                const Text(
                  'Color clip & Background color',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Mode Selector: Gradient vs Solid
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isGradient ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                      side: BorderSide(color: isGradient ? AppColors.primary : Colors.grey.shade300),
                    ),
                    onPressed: () => setState(() => isGradient = true),
                    child: const Text('Gradient Colors'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: !isGradient ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                      side: BorderSide(color: !isGradient ? AppColors.primary : Colors.grey.shade300),
                    ),
                    onPressed: () => setState(() => isGradient = false),
                    child: const Text('Solid Color'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Live Preview Card
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isGradient ? null : solidColor,
                gradient: isGradient
                    ? LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: const Center(
                child: Icon(Icons.palette_rounded, color: Colors.white, size: 36),
              ),
            ),
            const SizedBox(height: 16),

            // Preset Swatches
            const Text('Presets', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            if (isGradient)
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: gradientPresets.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final p = gradientPresets[index];
                    return InkWell(
                      onTap: () => setState(() => gradientColors = p),
                      child: Container(
                        width: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: LinearGradient(colors: p),
                          border: Border.all(
                            color: gradientColors == p ? AppColors.primary : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: solidPresets.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final c = solidPresets[index];
                    return InkWell(
                      onTap: () => setState(() => solidColor = c),
                      child: Container(
                        width: 44,
                        decoration: BoxDecoration(
                          color: c,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: solidColor == c ? AppColors.primary : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),

            // Duration Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Duration', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                Text('${duration.toInt()} seconds', style: const TextStyle(fontSize: 13, color: AppColors.primary)),
              ],
            ),
            Slider(
              value: duration,
              min: 1.0,
              max: 30.0,
              divisions: 29,
              activeColor: AppColors.primary,
              onChanged: (val) => setState(() => duration = val),
            ),
            const SizedBox(height: 16),

            // Add Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: () {
                  final hexList = gradientColors
                      .map((c) => '#${c.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}')
                      .toList();
                  final solidHex =
                      '#${solidColor.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

                  final clip = ClipModel(
                    id: 'clip-${const Uuid().v4().substring(0, 8)}',
                    type: isGradient ? ClipType.gradient : ClipType.solidColor,
                    name: isGradient ? 'Gradient Background' : 'Color Clip',
                    duration: duration,
                    solidColorHex: solidHex,
                    gradientColorsHex: isGradient ? hexList : null,
                  );

                  widget.onAddClip(clip);
                  Navigator.of(context).pop();
                },
                child: const Text('Add to Project', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
