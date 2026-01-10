import 'package:flutter/material.dart';

class NotificationHelper {
  static void showSuccess(
    BuildContext context,
    String message, {
    VoidCallback? onTap,
  }) {
    _showNotification(
      context,
      message,
      Colors.green,
      Icons.check_circle,
      onTap,
    );
  }

  static void showError(BuildContext context, String message) {
    _showNotification(context, message, Colors.red, Icons.error, null);
  }

  static void showInfo(BuildContext context, String message) {
    _showNotification(context, message, Colors.blue, Icons.info, null);
  }

  static void _showNotification(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
    VoidCallback? onTap,
  ) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder:
          (context) => _NotificationWidget(
            message: message,
            color: color,
            icon: icon,
            onTap: onTap,
          ),
    );

    overlay.insert(overlayEntry);

    // Auto remove after delay
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}

class _NotificationWidget extends StatefulWidget {
  final String message;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  const _NotificationWidget({
    required this.message,
    required this.color,
    required this.icon,
    this.onTap,
  });

  @override
  State<_NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<_NotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slide = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _opacity,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border(
                    left: BorderSide(color: widget.color, width: 4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(widget.icon, color: widget.color),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
