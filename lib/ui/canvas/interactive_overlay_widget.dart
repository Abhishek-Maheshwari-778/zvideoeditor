import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../models/overlay_layer_model.dart';

class InteractiveOverlayWidget extends StatefulWidget {
  final OverlayLayerModel overlay;
  final bool isSelected;
  final Size canvasSize;
  final VoidCallback onSelect;
  final void Function(double posX, double posY, double scale, double rotation) onTransformUpdate;
  final VoidCallback onDoubleTap;

  const InteractiveOverlayWidget({
    super.key,
    required this.overlay,
    required this.isSelected,
    required this.canvasSize,
    required this.onSelect,
    required this.onTransformUpdate,
    required this.onDoubleTap,
  });

  @override
  State<InteractiveOverlayWidget> createState() => _InteractiveOverlayWidgetState();
}

class _InteractiveOverlayWidgetState extends State<InteractiveOverlayWidget> {
  late double _posX;
  late double _posY;
  late double _scale;
  late double _rotation;

  @override
  void initState() {
    super.initState();
    _posX = widget.overlay.posX;
    _posY = widget.overlay.posY;
    _scale = widget.overlay.scale;
    _rotation = widget.overlay.rotation;
  }

  @override
  void didUpdateWidget(covariant InteractiveOverlayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.overlay != widget.overlay) {
      _posX = widget.overlay.posX;
      _posY = widget.overlay.posY;
      _scale = widget.overlay.scale;
      _rotation = widget.overlay.rotation;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.overlay.isVisible) return const SizedBox.shrink();

    final canvasW = widget.canvasSize.width;
    final canvasH = widget.canvasSize.height;
    final centerX = _posX * canvasW;
    final centerY = _posY * canvasH;

    return Positioned(
      left: centerX - 100,
      top: centerY - 100,
      child: GestureDetector(
        onTap: widget.onSelect,
        onDoubleTap: widget.onDoubleTap,
        onPanUpdate: (details) {
          if (widget.overlay.isLocked) return;
          setState(() {
            _posX = (_posX + (details.delta.dx / canvasW)).clamp(0.0, 1.0);
            _posY = (_posY + (details.delta.dy / canvasH)).clamp(0.0, 1.0);
          });
          widget.onTransformUpdate(_posX, _posY, _scale, _rotation);
        },
        child: Transform.rotate(
          angle: _rotation * (math.pi / 180.0),
          child: Transform.scale(
            scale: _scale,
            child: Container(
              width: 200,
              height: 200,
              decoration: widget.isSelected
                  ? BoxDecoration(
                      border: Border.all(color: AppColors.primary, width: 2),
                    )
                  : null,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Layer Visual Content
                  Opacity(
                    opacity: widget.overlay.opacity.clamp(0.0, 1.0),
                    child: _buildLayerContent(),
                  ),

                  // Transform Handles (When selected)
                  if (widget.isSelected && !widget.overlay.isLocked) ...[
                    // Top Rotation Knob
                    Positioned(
                      top: -24,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            _rotation = (_rotation + details.delta.dx) % 360.0;
                          });
                          widget.onTransformUpdate(_posX, _posY, _scale, _rotation);
                        },
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                          ),
                          child: const Icon(Icons.rotate_right_rounded, size: 14, color: AppColors.primary),
                        ),
                      ),
                    ),
                    // Bottom-Right Scale Handle
                    Positioned(
                      bottom: -8,
                      right: -8,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            final delta = (details.delta.dx + details.delta.dy) * 0.01;
                            _scale = (_scale + delta).clamp(0.2, 5.0);
                          });
                          widget.onTransformUpdate(_posX, _posY, _scale, _rotation);
                        },
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLayerContent() {
    switch (widget.overlay.type) {
      case OverlayType.text:
        final hex = widget.overlay.fontColorHex.replaceAll('#', '');
        final color = Color(int.parse('FF$hex', radix: 16));

        Widget textWidget = Text(
          widget.overlay.content,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: widget.overlay.fontSize,
            color: color,
            fontWeight: widget.overlay.isBold ? FontWeight.bold : FontWeight.normal,
            fontStyle: widget.overlay.isItalic ? FontStyle.italic : FontStyle.normal,
            shadows: widget.overlay.hasShadow
                ? [const Shadow(color: Colors.black87, blurRadius: 8, offset: Offset(2, 2))]
                : null,
          ),
        );

        if (widget.overlay.backgroundColorHex != null) {
          final bgHex = widget.overlay.backgroundColorHex!.replaceAll('#', '');
          final bgColor = Color(int.parse('FF$bgHex', radix: 16));
          textWidget = Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: textWidget,
          );
        }

        return textWidget;

      case OverlayType.sticker:
      case OverlayType.gif:
        return CachedNetworkImage(
          imageUrl: widget.overlay.content,
          fit: BoxFit.contain,
          placeholder: (_, __) => const Center(
            child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          errorWidget: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white),
        );

      case OverlayType.pipVideo:
        Widget pipWidget = Container(
          color: Colors.black87,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.picture_in_picture_alt_rounded, color: Colors.white, size: 36),
                SizedBox(height: 6),
                Text('PiP Overlay', style: TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
        );

        if (widget.overlay.maskShape == PiPMaskShape.circle) {
          pipWidget = ClipOval(child: pipWidget);
        } else if (widget.overlay.maskShape == PiPMaskShape.roundedRectangle) {
          pipWidget = ClipRRect(
            borderRadius: BorderRadius.circular(widget.overlay.cornerRadius),
            child: pipWidget,
          );
        }

        if (widget.overlay.borderWidth > 0 && widget.overlay.borderColorHex != null) {
          final bHex = widget.overlay.borderColorHex!.replaceAll('#', '');
          final bColor = Color(int.parse('FF$bHex', radix: 16));
          pipWidget = Container(
            decoration: BoxDecoration(
              border: Border.all(color: bColor, width: widget.overlay.borderWidth),
              shape: widget.overlay.maskShape == PiPMaskShape.circle ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: widget.overlay.maskShape == PiPMaskShape.roundedRectangle
                  ? BorderRadius.circular(widget.overlay.cornerRadius)
                  : null,
            ),
            child: pipWidget,
          );
        }

        return pipWidget;

      case OverlayType.watermark:
        return Text(
          widget.overlay.content,
          style: TextStyle(
            fontSize: widget.overlay.fontSize,
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.bold,
          ),
        );
    }
  }
}
