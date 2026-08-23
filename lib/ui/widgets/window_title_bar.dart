import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../../core/constants/app_colors.dart';

class WindowTitleBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBack;
  final bool showSaveButton;
  final VoidCallback? onSave;

  const WindowTitleBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.onBack,
    this.showSaveButton = false,
    this.onSave,
  });

  @override
  Size get preferredSize => const Size.fromHeight(36);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      color: AppColors.windowsTitleBar,
      child: Row(
        children: [
          if (showBackButton)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
              onPressed: onBack,
              tooltip: 'Go back to Home',
              splashRadius: 18,
              padding: EdgeInsets.zero,
            ),
          const SizedBox(width: 8),
          Expanded(
            child: DragToMoveArea(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          // Window Control Buttons (Minimize, Maximize, Close)
          _WindowButton(
            icon: Icons.remove,
            onPressed: () => windowManager.minimize(),
          ),
          _WindowButton(
            icon: Icons.crop_square_rounded,
            onPressed: () async {
              if (await windowManager.isMaximized()) {
                windowManager.restore();
              } else {
                windowManager.maximize();
              }
            },
          ),
          _WindowButton(
            icon: Icons.close,
            isClose: true,
            onPressed: () => windowManager.close(),
          ),
        ],
      ),
    );
  }
}

class _WindowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isClose;

  const _WindowButton({
    required this.icon,
    required this.onPressed,
    this.isClose = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      hoverColor: isClose ? Colors.red : Colors.white.withOpacity(0.2),
      child: SizedBox(
        width: 44,
        height: 36,
        child: Center(
          child: Icon(
            icon,
            size: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
