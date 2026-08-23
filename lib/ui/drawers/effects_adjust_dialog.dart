import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/clip_model.dart';

class EffectsAdjustDialog extends StatefulWidget {
  final ColorAdjustments initialAdjustments;
  final void Function(ColorAdjustments) onApply;

  const EffectsAdjustDialog({
    super.key,
    required this.initialAdjustments,
    required this.onApply,
  });

  @override
  State<EffectsAdjustDialog> createState() => _EffectsAdjustDialogState();
}

class _EffectsAdjustDialogState extends State<EffectsAdjustDialog> {
  late double brightness;
  late double contrast;
  late double saturation;
  late double temperature;
  late double hue;

  @override
  void initState() {
    super.initState();
    brightness = widget.initialAdjustments.brightness;
    contrast = widget.initialAdjustments.contrast;
    saturation = widget.initialAdjustments.saturation;
    temperature = widget.initialAdjustments.temperature;
    hue = widget.initialAdjustments.hue;
  }

  void _reset() {
    setState(() {
      brightness = 0.0;
      contrast = 1.0;
      saturation = 1.0;
      temperature = 0.0;
      hue = 0.0;
    });
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
                const Text('Effects & Color Adjust', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: _reset,
                  child: const Text('Reset All', style: TextStyle(color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildSlider('Brightness', brightness, -1.0, 1.0, (val) => setState(() => brightness = val)),
            _buildSlider('Contrast', contrast, 0.0, 2.0, (val) => setState(() => contrast = val)),
            _buildSlider('Saturation', saturation, 0.0, 3.0, (val) => setState(() => saturation = val)),
            _buildSlider('Temperature', temperature, -1.0, 1.0, (val) => setState(() => temperature = val)),
            _buildSlider('Hue', hue, -180.0, 180.0, (val) => setState(() => hue = val)),

            const SizedBox(height: 20),
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
                      final updated = ColorAdjustments(
                        brightness: brightness,
                        contrast: contrast,
                        saturation: saturation,
                        temperature: temperature,
                        hue: hue,
                      );
                      widget.onApply(updated);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Apply Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            Text(value.toStringAsFixed(2), style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          activeColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
