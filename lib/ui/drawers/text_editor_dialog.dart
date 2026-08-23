import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/overlay_layer_model.dart';

class TextEditorDialog extends StatefulWidget {
  final OverlayLayerModel? initialOverlay;
  final void Function(OverlayLayerModel) onSave;

  const TextEditorDialog({
    super.key,
    this.initialOverlay,
    required this.onSave,
  });

  @override
  State<TextEditorDialog> createState() => _TextEditorDialogState();
}

class _TextEditorDialogState extends State<TextEditorDialog> {
  late TextEditingController _textController;
  String selectedFont = 'Montserrat';
  double fontSize = 36.0;
  Color fontColor = Colors.white;
  Color? backgroundColor;
  bool isBold = false;
  bool isItalic = false;
  bool hasShadow = true;
  TextAnimationStyle animationStyle = TextAnimationStyle.none;

  final List<String> fonts = [
    'Montserrat',
    'Roboto',
    'Poppins',
    'Open Sans',
    'Lato',
    'Oswald',
    'Pacifico',
    'Bebas Neue',
    'Cinzel',
    'Lobster',
  ];

  final List<Color> colorPresets = [
    Colors.white,
    Colors.black,
    const Color(0xFFFFEB3B), // Bright Yellow
    const Color(0xFFFF5722), // Deep Orange
    const Color(0xFFE91E63), // Vibrant Pink
    const Color(0xFF00E676), // Neon Green
    const Color(0xFF00B0FF), // Neon Blue
    const Color(0xFFD500F9), // Purple
  ];

  @override
  void initState() {
    super.initState();
    final init = widget.initialOverlay;
    _textController = TextEditingController(text: init?.content ?? 'YOUR TEXT HERE');
    if (init != null) {
      selectedFont = init.fontFamily;
      fontSize = init.fontSize;
      final hex = init.fontColorHex.replaceAll('#', '');
      fontColor = Color(int.parse('FF$hex', radix: 16));
      if (init.backgroundColorHex != null) {
        final bgHex = init.backgroundColorHex!.replaceAll('#', '');
        backgroundColor = Color(int.parse('FF$bgHex', radix: 16));
      }
      isBold = init.isBold;
      isItalic = init.isItalic;
      hasShadow = init.hasShadow;
      animationStyle = init.animationStyle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 580,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Text Overlay & Titles', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
            const SizedBox(height: 16),

            // Text Input
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: 'Overlay Text',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Live Preview Box
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Container(
                  padding: backgroundColor != null ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6) : null,
                  decoration: backgroundColor != null
                      ? BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(4))
                      : null,
                  child: Text(
                    _textController.text.isEmpty ? 'PREVIEW' : _textController.text,
                    style: GoogleFonts.getFont(
                      selectedFont,
                      fontSize: fontSize * 0.7,
                      color: fontColor,
                      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                      fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
                      shadows: hasShadow ? [const Shadow(color: Colors.black, blurRadius: 4)] : null,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Font Selector & Styling Row
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedFont,
                    decoration: InputDecoration(
                      labelText: 'Font Family',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    items: fonts.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                    onChanged: (val) => setState(() => selectedFont = val!),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: Icon(Icons.format_bold, color: isBold ? AppColors.primary : Colors.grey),
                  onPressed: () => setState(() => isBold = !isBold),
                ),
                IconButton(
                  icon: Icon(Icons.format_italic, color: isItalic ? AppColors.primary : Colors.grey),
                  onPressed: () => setState(() => isItalic = !isItalic),
                ),
                IconButton(
                  icon: Icon(Icons.wb_shade, color: hasShadow ? AppColors.primary : Colors.grey),
                  onPressed: () => setState(() => hasShadow = !hasShadow),
                  tooltip: 'Drop Shadow',
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Color Swatches
            Row(
              children: [
                const Text('Color: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ...colorPresets.map((c) {
                  return GestureDetector(
                    onTap: () => setState(() => fontColor = c),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(color: fontColor == c ? AppColors.primary : Colors.grey.shade400, width: 2),
                      ),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 14),

            // Animation Style Selector
            Row(
              children: [
                const Text('Animation: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                DropdownButton<TextAnimationStyle>(
                  value: animationStyle,
                  items: const [
                    DropdownMenuItem(value: TextAnimationStyle.none, child: Text('None (Static)')),
                    DropdownMenuItem(value: TextAnimationStyle.fadeIn, child: Text('Fade In')),
                    DropdownMenuItem(value: TextAnimationStyle.typewriter, child: Text('Typewriter')),
                    DropdownMenuItem(value: TextAnimationStyle.slideUp, child: Text('Slide Up')),
                    DropdownMenuItem(value: TextAnimationStyle.pop, child: Text('Pop / Bounce')),
                    DropdownMenuItem(value: TextAnimationStyle.glow, child: Text('Neon Glow')),
                  ],
                  onChanged: (val) => setState(() => animationStyle = val!),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Apply Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () {
                  final hex = '#${fontColor.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
                  final bgHex = backgroundColor != null
                      ? '#${backgroundColor!.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}'
                      : null;

                  final overlay = (widget.initialOverlay ??
                          OverlayLayerModel(
                            id: 'txt-${DateTime.now().millisecondsSinceEpoch}',
                            type: OverlayType.text,
                            content: _textController.text,
                            startTime: 0.0,
                            duration: 3.0,
                          ))
                      .copyWith(
                    content: _textController.text,
                    fontFamily: selectedFont,
                    fontSize: fontSize,
                    fontColorHex: hex,
                    backgroundColorHex: bgHex,
                    isBold: isBold,
                    isItalic: isItalic,
                    hasShadow: hasShadow,
                    animationStyle: animationStyle,
                  );

                  widget.onSave(overlay);
                  Navigator.of(context).pop();
                },
                child: const Text('Save Text Layer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
