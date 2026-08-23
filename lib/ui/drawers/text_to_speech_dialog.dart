import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../models/overlay_layer_model.dart';

class TextToSpeechDialog extends StatefulWidget {
  final void Function(AudioTrackModel) onAddVoiceover;

  const TextToSpeechDialog({super.key, required this.onAddVoiceover});

  @override
  State<TextToSpeechDialog> createState() => _TextToSpeechDialogState();
}

class _TextToSpeechDialogState extends State<TextToSpeechDialog> {
  final TextEditingController _textController = TextEditingController(
    text: 'Welcome to Z-Movie Maker! Create stunning videos with powerful tools.',
  );
  String selectedVoice = 'English (US) - Neural Natural (Female)';
  double pitch = 1.0;
  double speechRate = 1.0;
  bool isGenerating = false;

  final List<String> voices = [
    'English (US) - Neural Natural (Female)',
    'English (US) - Studio Voice (Male)',
    'English (UK) - British Narrator',
    'Spanish (ES) - Voiceover Pro',
    'French (FR) - Elegant Accent',
    'German (DE) - Deep Voice',
    'Hindi (IN) - Standard Voice',
  ];

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
                    Icon(Icons.record_voice_over_rounded, color: Color(0xFFFF5252), size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Text to Speech (TTS) Studio',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close, color: Colors.white70, size: 20), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
            const SizedBox(height: 16),

            // Script Textarea
            TextField(
              controller: _textController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Enter Voiceover Script',
                labelStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
              ),
            ),
            const SizedBox(height: 16),

            // Voice Selector
            const Text('Voice Model', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: selectedVoice,
              dropdownColor: const Color(0xFF2A2A2A),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
              ),
              items: voices.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (v) => setState(() => selectedVoice = v!),
            ),
            const SizedBox(height: 16),

            // Pitch & Rate Sliders
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Pitch', style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text(pitch.toStringAsFixed(1), style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            Slider(
              value: pitch,
              min: 0.5,
              max: 1.5,
              activeColor: const Color(0xFFFF5252),
              onChanged: (v) => setState(() => pitch = v),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Speed Rate', style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text('${speechRate.toStringAsFixed(1)}x', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            Slider(
              value: speechRate,
              min: 0.5,
              max: 2.0,
              activeColor: const Color(0xFFFF5252),
              onChanged: (v) => setState(() => speechRate = v),
            ),
            const SizedBox(height: 20),

            // Generate & Add Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5252)),
                icon: const Icon(Icons.mic_rounded, color: Colors.white, size: 18),
                label: const Text('Generate Voiceover Track', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: () {
                  final track = AudioTrackModel(
                    id: 'tts-${const Uuid().v4().substring(0, 8)}',
                    name: 'TTS Voice: ${_textController.text.substring(0, _textController.text.length.clamp(0, 20))}...',
                    filePath: 'tts_audio.wav',
                    startTime: 0.0,
                    duration: (_textController.text.length * 0.08).clamp(2.0, 60.0),
                    isVoiceover: true,
                    autoDucking: true,
                  );
                  widget.onAddVoiceover(track);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
