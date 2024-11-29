// lib\modules\widgets\alert\xumm_terminated_error_dialog.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import '../../../config/theme.dart';

class XummTerminatedDialog extends StatefulWidget {
  final bool isOpen;
  final VoidCallback onClose;

  const XummTerminatedDialog({
    Key? key,
    required this.isOpen,
    required this.onClose,
  }) : super(key: key);

  @override
  State<XummTerminatedDialog> createState() => _XummTerminatedDialogState();
}

class _XummTerminatedDialogState extends State<XummTerminatedDialog> {
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
                    color: AppColors.error..withAlpha(25), // 0.1 * 255 ≈ 25,
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
                  'xaman_connection_error'.tr,
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
