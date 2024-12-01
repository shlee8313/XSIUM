// lib\modules\widgets\alert\login_interrupt_error_dialog.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import '../../../config/theme.dart';

class LoginInterruptErrorDialog extends StatefulWidget {
  final bool isOpen;
  final VoidCallback onClose;

  const LoginInterruptErrorDialog({
    Key? key,
    required this.isOpen,
    required this.onClose,
  }) : super(key: key);

  @override
  State<LoginInterruptErrorDialog> createState() =>
      _LoginInterruptErrorDialogState();
}

class _LoginInterruptErrorDialogState extends State<LoginInterruptErrorDialog> {
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _startDismissTimer();
  }

  void _startDismissTimer() {
    _dismissTimer = Timer(const Duration(seconds: 5), () {
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
    if (!widget.isOpen) return const SizedBox.shrink();

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
                  color: Theme.of(context).shadowColor
                    ..withAlpha(51), // 0.2 * 255 ≈ 51,
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
                  decoration: const BoxDecoration(
                    // color: AppColors.warning..withAlpha(25), // 0.2 * 255 ≈ 51,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_outlined,
                    color: AppColors.warning,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'login_incomplete'.tr,
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
