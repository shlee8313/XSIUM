// lib/presentation/screens/login/qr_login_dialog.dart

import 'package:flutter/material.dart';

import '../../../config/theme.dart';
import '../controllers/login_controller.dart';
import '../../home/home_screen.dart';

class QRLoginDialog extends StatefulWidget {
  final LoginController controller;
  final Function(bool) onLoginInterruptError;
  final Function(bool) onXummTerminated;
  final Function(bool, String) onError;

  const QRLoginDialog({
    Key? key,
    required this.controller,
    required this.onLoginInterruptError,
    required this.onXummTerminated,
    required this.onError,
  }) : super(key: key);

  @override
  State<QRLoginDialog> createState() => _QRLoginDialogState();
}

class _QRLoginDialogState extends State<QRLoginDialog> {
  void Function(bool)? _originalLoadingCallback;
  void Function()? _originalLoginInterruptCallback;
  void Function()? _originalXummTerminatedCallback;
  void Function(String)? _originalErrorCallback;
  void Function(String)? _originalSuccessCallback;

  @override
  void initState() {
    super.initState();
    _originalLoadingCallback = widget.controller.onLoadingChanged;
    _originalLoginInterruptCallback =
        widget.controller.onShowLoginInterruptError;
    _originalXummTerminatedCallback = widget.controller.onShowXummTerminated;
    _originalErrorCallback = widget.controller.onShowError;
    _originalSuccessCallback = widget.controller.onLoginSuccess;

    _setupController();
    widget.controller.loginWithQR();
  }

  void _setupController() {
    widget.controller.onLoadingChanged = (value) {
      if (mounted) setState(() {});
    };

    widget.controller.onShowLoginInterruptError = () {
      if (mounted) {
        Navigator.pop(context);
        widget.onLoginInterruptError(true);
      }
    };

    widget.controller.onShowXummTerminated = () {
      if (mounted) {
        Navigator.pop(context);
        widget.onXummTerminated(true);
      }
    };

    widget.controller.onShowError = (message) {
      if (mounted) {
        Navigator.pop(context);
        widget.onError(true, message);
      }
    };

    widget.controller.onLoginSuccess = (account) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => HomeScreen(userAddress: account),
          ),
          (route) => false,
        );
      }
    };
  }

  Future<bool> _showExitDialog() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: colorScheme.surface,
              title: Text(
                'Cancel Login',
                style: theme.textTheme.titleLarge,
              ),
              content: Text(
                'Do you want to cancel the QR login?',
                style: theme.textTheme.bodyLarge,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Text(
                    'Continue',
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    widget.controller.cleanupLoginState();
                    Navigator.pop(context, true);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showExitDialog();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(
          'QR Code Login',
          style: theme.textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Scan the QR code below with the XUMM app on another device.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            if (widget.controller.isLoading &&
                widget.controller.qrImageUrl == null)
              SizedBox(
                width: 200,
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(
                    color: colorScheme.primary,
                  ),
                ),
              )
            else if (widget.controller.qrImageUrl != null)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.surfaceContainer),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.network(
                  widget.controller.qrImageUrl!,
                  width: 200,
                  height: 200,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      width: 200,
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: colorScheme.primary,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              widget.controller.cleanupLoginState();
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // 기존 콜백 복원
    /*
    widget.controller.onLoadingChanged = _originalLoadingCallback;
    widget.controller.onError = _originalErrorCallback;
    widget.controller.onLoginSuccess = _originalSuccessCallback;
    */

    // 새로운 콜백 복원
    widget.controller.onLoadingChanged = _originalLoadingCallback;
    widget.controller.onShowLoginInterruptError =
        _originalLoginInterruptCallback;
    widget.controller.onShowXummTerminated = _originalXummTerminatedCallback;
    widget.controller.onShowError = _originalErrorCallback;
    widget.controller.onLoginSuccess = _originalSuccessCallback;
    super.dispose();
  }
}
