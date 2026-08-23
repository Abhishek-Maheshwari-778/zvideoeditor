import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/transition_model.dart';

class TransitionDrawer extends StatelessWidget {
  final TransitionModel? currentTransition;
  final void Function(TransitionModel?) onSelectTransition;
  final VoidCallback onClose;

  const TransitionDrawer({
    super.key,
    required this.currentTransition,
    required this.onSelectTransition,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final transitions = [
      const TransitionModel(id: 'none', type: TransitionType.none),
      const TransitionModel(id: 'cross_fade', type: TransitionType.crossFade),
      const TransitionModel(id: 'fade_black', type: TransitionType.fadeBlack),
      const TransitionModel(id: 'fade_white', type: TransitionType.fadeWhite),
      const TransitionModel(id: 'blur', type: TransitionType.blur),
      const TransitionModel(id: 'luma_a', type: TransitionType.lumaFadeA, isPro: false),
      const TransitionModel(id: 'luma_b', type: TransitionType.lumaFadeB, isPro: false),
      const TransitionModel(id: 'glow', type: TransitionType.glow, isPro: false),
      const TransitionModel(id: 'lens_flare', type: TransitionType.lensFlare, isPro: false),
      const TransitionModel(id: 'wipe_left', type: TransitionType.wipeLeft),
      const TransitionModel(id: 'wipe_right', type: TransitionType.wipeRight),
      const TransitionModel(id: 'slide_left', type: TransitionType.slideLeft),
      const TransitionModel(id: 'slide_right', type: TransitionType.slideRight),
      const TransitionModel(id: 'zoom_in', type: TransitionType.zoomIn),
      const TransitionModel(id: 'dissolve', type: TransitionType.dissolve),
      const TransitionModel(id: 'pixelize', type: TransitionType.pixelize),
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select a transition',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF444444)),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: onClose,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: transitions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final item = transitions[index];
                final isSelected = currentTransition?.type == item.type ||
                    (currentTransition == null && item.type == TransitionType.none);

                return InkWell(
                  onTap: () => onSelectTransition(item.type == TransitionType.none ? null : item),
                  child: Column(
                    children: [
                      Container(
                        width: 110,
                        height: 65,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : const Color(0xFFDDDDDD),
                            width: isSelected ? 2.5 : 1,
                          ),
                          gradient: LinearGradient(
                            colors: [
                              Colors.red.shade900,
                              Colors.red.shade600,
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Icon(
                                _getTransitionIcon(item.type),
                                color: Colors.white.withOpacity(0.9),
                                size: 28,
                              ),
                            ),
                            if (item.displayName.contains('Luma') || item.displayName.contains('Glow'))
                              Positioned(
                                right: 4,
                                top: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.badgeNew,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: const Text(
                                    'NEW',
                                    style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 110,
                        child: Text(
                          item.displayName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? AppColors.primary : const Color(0xFF333333),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTransitionIcon(TransitionType type) {
    switch (type) {
      case TransitionType.none:
        return Icons.block_rounded;
      case TransitionType.crossFade:
        return Icons.join_inner_rounded;
      case TransitionType.fadeBlack:
        return Icons.exposure_rounded;
      case TransitionType.fadeWhite:
        return Icons.brightness_7_rounded;
      case TransitionType.blur:
        return Icons.blur_on_rounded;
      case TransitionType.wipeLeft:
      case TransitionType.wipeRight:
        return Icons.swipe_rounded;
      case TransitionType.slideLeft:
      case TransitionType.slideRight:
        return Icons.view_carousel_rounded;
      case TransitionType.zoomIn:
      case TransitionType.zoomOut:
        return Icons.zoom_in_rounded;
      case TransitionType.pixelize:
        return Icons.grid_4x4_rounded;
      default:
        return Icons.auto_fix_high_rounded;
    }
  }
}
