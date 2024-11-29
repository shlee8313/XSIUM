// lib\modules\widgets\alert\error_dialog.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../../../config/theme.dart';
// import 'package:flutter/material.dart';

class ErrorDialog extends StatefulWidget {
  final String message;
  final VoidCallback onClose;

  const ErrorDialog({
    super.key,
    required this.message,
    required this.onClose,
  });

  @override
  State<ErrorDialog> createState() => _ErrorDialogState();
}

class _ErrorDialogState extends State<ErrorDialog> {
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _startDismissTimer();
  }

  void _startDismissTimer() {
    _dismissTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onClose();
      }
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 32.0),
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context)
                      .shadowColor
                      .withAlpha(51), // 0.2 * 255 ≈ 51,
                  blurRadius: 10.0,
                  offset: const Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error..withAlpha(25), // 0.2 * 255 ≈ 51,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.error,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
