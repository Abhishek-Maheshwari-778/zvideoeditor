import 'package:flutter/material.dart';

class AddMediaMenu extends StatelessWidget {
  final VoidCallback onAddVideoPhoto;
  final VoidCallback onAddColorClip;
  final VoidCallback onAddGiphy;
  final VoidCallback onAddCamera;

  const AddMediaMenu({
    super.key,
    required this.onAddVideoPhoto,
    required this.onAddColorClip,
    required this.onAddGiphy,
    required this.onAddCamera,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: const Color(0xFFE5E5E5)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(
                'Video clip',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF888888),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            _MenuItem(
              icon: Icons.add_circle,
              iconColor: const Color(0xFF00C853),
              title: 'Video or photo clips',
              onTap: onAddVideoPhoto,
            ),
            _MenuItem(
              icon: Icons.palette_rounded,
              iconColor: const Color(0xFFE91E63),
              title: 'Color clip & Background color',
              onTap: onAddColorClip,
            ),
            _MenuItem(
              icon: Icons.grid_view_rounded,
              iconColor: const Color(0xFF000000),
              title: 'GIPHY',
              onTap: onAddGiphy,
            ),
            _MenuItem(
              icon: Icons.camera_alt_rounded,
              iconColor: const Color(0xFF9C27B0),
              title: 'Take a photo/video',
              onTap: onAddCamera,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      hoverColor: const Color(0xFFF0F0F0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF222222),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
