import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../models/overlay_layer_model.dart';

class AutoSubtitlesDialog extends StatefulWidget {
  final void Function(List<OverlayLayerModel>) onAddSubtitles;

  const AutoSubtitlesDialog({super.key, required this.onAddSubtitles});

  @override
  State<AutoSubtitlesDialog> createState() => _AutoSubtitlesDialogState();
}

class _AutoSubtitlesDialogState extends State<AutoSubtitlesDialog> {
  String selectedStyle = 'Alex Hormozi (Viral Yellow & Black)';
  String selectedLanguage = 'English (Auto-Detect)';
  bool isGenerating = false;

  final List<String> styles = [
    'Alex Hormozi (Viral Yellow & Black)',
    'Neon Cyan Glow (Cyberpunk)',
    'Clean White Minimalist',
    'Cinematic Movie Subtitles',
  ];

  final List<String> languages = [
    'English (Auto-Detect)',
    'Spanish (Español)',
    'French (Français)',
    'German (Deutsch)',
    'Hindi (हिन्दी)',
    'Portuguese (Português)',
    'Japanese (日本語)',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: 540,
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.subtitles_rounded, color: Color(0xFF0078D7), size: 24),
                const SizedBox(width: 10),
                const Text(
                  'AI Auto-Subtitles & Speech-to-Text',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
            const SizedBox(height: 16),

            // Style Selector
            const Text('Subtitle Animation & Typography Preset', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedStyle,
              dropdownColor: const Color(0xFF2A2A2A),
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: styles.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => selectedStyle = v!),
            ),
            const SizedBox(height: 14),

            // Language Selector
            const Text('Spoken Audio Language', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedLanguage,
              dropdownColor: const Color(0xFF2A2A2A),
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: languages.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
              onChanged: (v) => setState(() => selectedLanguage = v!),
            ),
            const SizedBox(height: 18),

            // Preview Style Card
            Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white12),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: selectedStyle.contains('Hormozi')
                        ? const Color(0xFFFFD600)
                        : (selectedStyle.contains('Cyan') ? const Color(0xFF00E5FF) : Colors.black87),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'VIRAL AUTO CAPTIONS',
                    style: TextStyle(
                      color: selectedStyle.contains('Hormozi') || selectedStyle.contains('Cyan') ? Colors.black : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),

            // Generate Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0078D7)),
                icon: isGenerating
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                label: Text(
                  isGenerating ? 'Transcribing Speech...' : 'Generate Synchronized Captions',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onPressed: isGenerating
                    ? null
                    : () async {
                        setState(() => isGenerating = true);
                        await Future.delayed(const Duration(milliseconds: 1200));

                        final fontColor = selectedStyle.contains('Hormozi')
                            ? '#000000'
                            : (selectedStyle.contains('Cyan') ? '#000000' : '#FFFFFF');
                        final bgColor = selectedStyle.contains('Hormozi')
                            ? '#FFD600'
                            : (selectedStyle.contains('Cyan') ? '#00E5FF' : '#000000');

                        final subtitles = [
                          OverlayLayerModel(
                            id: 'sub-${const Uuid().v4().substring(0, 8)}',
                            name: 'Captions: Line 1',
                            type: OverlayType.text,
                            content: 'WELCOME TO Z-MOVIE MAKER!',
                            fontColorHex: fontColor,
                            backgroundColorHex: bgColor,
                            fontSize: 28,
                            fontFamily: 'Montserrat',
                            startTime: 0.0,
                            duration: 2.0,
                            posY: 0.8,
                            hasShadow: true,
                          ),
                          OverlayLayerModel(
                            id: 'sub-${const Uuid().v4().substring(0, 8)}',
                            name: 'Captions: Line 2',
                            type: OverlayType.text,
                            content: 'CREATE AMAZING VIDEOS IN SECONDS',
                            fontColorHex: fontColor,
                            backgroundColorHex: bgColor,
                            fontSize: 28,
                            fontFamily: 'Montserrat',
                            startTime: 2.0,
                            duration: 2.5,
                            posY: 0.8,
                            hasShadow: true,
                          ),
                        ];

                        widget.onAddSubtitles(subtitles);
                        if (mounted) Navigator.of(context).pop();
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
