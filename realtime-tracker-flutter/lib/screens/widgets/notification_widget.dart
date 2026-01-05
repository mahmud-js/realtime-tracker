import 'package:flutter/material.dart';

class NotificationWidget extends StatefulWidget {
  const NotificationWidget({Key? key}) : super(key: key);

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String _message = '';
  String _type = 'info';
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  void showNotification(String message, String type) {
    setState(() {
      _message = message;
      _type = type;
      _isVisible = true;
    });

    _animationController.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _animationController.reverse();
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() => _isVisible = false);
          }
        });
      }
    });
  }

  Color _getBackgroundColor() {
    switch (_type) {
      case 'success':
        return Colors.green;
      case 'error':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.0).animate(_animationController),
      child: Material(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            _message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
