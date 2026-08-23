import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AudioCleanupDialog extends StatefulWidget {
  final void Function({
    required bool enableDenoise,
    required double noiseFloorDb,
    required bool enableSilenceRemoval,
    required double silenceThresholdDb,
  }) onApply;

  const AudioCleanupDialog({super.key, required this.onApply});

  @override
  State<AudioCleanupDialog> createState() => _AudioCleanupDialogState();
}

class _AudioCleanupDialogState extends State<AudioCleanupDialog> {
  bool enableDenoise = true;
  double noiseFloorDb = -25.0; // -50 dB to -10 dB
  bool enableSilenceRemoval = true;
  double silenceThresholdDb = -35.0; // -60 dB to -20 dB

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.graphic_eq_rounded, color: Color(0xFF0078D7), size: 24),
                const SizedBox(width: 10),
                const Text(
                  'AI Audio Denoise & Silence Remover',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
            const SizedBox(height: 16),

            // 1. AI Noise Reduction
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'AI FFT Noise Suppression',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      Switch(
                        value: enableDenoise,
                        activeColor: const Color(0xFF0078D7),
                        onChanged: (v) => setState(() => enableDenoise = v),
                      ),
                    ],
                  ),
                  const Text(
                    'Removes background hum, fan noise, microphone hiss, and ambient static.',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  if (enableDenoise) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Noise Reduction Floor', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        Text('${noiseFloorDb.toInt()} dB', style: const TextStyle(color: Color(0xFF0078D7), fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Slider(
                      value: noiseFloorDb,
                      min: -50,
                      max: -10,
                      activeColor: const Color(0xFF0078D7),
                      onChanged: (v) => setState(() => noiseFloorDb = v),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 2. Smart Silence Remover
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Smart Silence Remover',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      Switch(
                        value: enableSilenceRemoval,
                        activeColor: const Color(0xFF0078D7),
                        onChanged: (v) => setState(() => enableSilenceRemoval = v),
                      ),
                    ],
                  ),
                  const Text(
                    'Automatically detects dead air pauses and trims them out for fast-paced videos.',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  if (enableSilenceRemoval) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Silence Threshold', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        Text('${silenceThresholdDb.toInt()} dB', style: const TextStyle(color: Color(0xFF0078D7), fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Slider(
                      value: silenceThresholdDb,
                      min: -60,
                      max: -20,
                      activeColor: const Color(0xFF0078D7),
                      onChanged: (v) => setState(() => silenceThresholdDb = v),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Apply Button
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0078D7)),
                onPressed: () {
                  widget.onApply(
                    enableDenoise: enableDenoise,
                    noiseFloorDb: noiseFloorDb,
                    enableSilenceRemoval: enableSilenceRemoval,
                    silenceThresholdDb: silenceThresholdDb,
                  );
                  Navigator.of(context).pop();
                },
                child: const Text('Apply AI Audio Cleanup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
