// lib/presentation/screens/login/qr_login_dialog.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  // 새로 추가: QR URL을 저장할 상태 변수
  String? _qrImageUrl;
  bool _isLoading = true;

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
    _initializeQRLogin();
  }

  // 새로 추가: QR 로그인 초기화 함수
  Future<void> _initializeQRLogin() async {
    try {
      setState(() => _isLoading = true);
      await widget.controller.loginWithQR();

      // QR URL이 생성되면 상태 업데이트
      setState(() {
        _qrImageUrl = widget.controller.qrImageUrl;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      widget.onError(true, 'Failed to generate QR code');
    }
  }

  void _setupController() {
    widget.controller.onLoadingChanged = (value) {
      if (mounted) setState(() => _isLoading = value);
    };

    // 나머지 콜백 함수들은 동일하게 유지
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
        Navigator.of(context, rootNavigator: true).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeScreen(userAddress: account),
          ),
        );
      }
    };
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
          'qr_login_title'.tr,
          style: theme.textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'qr_login_instruction'.tr,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            // 수정된 부분: QR 이미지 표시 로직
            if (_isLoading)
              SizedBox(
                width: 200,
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(
                    color: colorScheme.primary,
                  ),
                ),
              )
            else if (_qrImageUrl != null)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.surfaceContainer),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.network(
                  _qrImageUrl!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 200,
                      height: 200,
                      color: colorScheme.surfaceVariant,
                      child: Center(
                        child: Text(
                          'Failed to load QR code'.tr,
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
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
              'Cancel'.tr,
              style: TextStyle(color: colorScheme.primary),
            ),
          ),
        ],
      ),
    );
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
                'qr_login_cancel_title'.tr,
                style: theme.textTheme.titleLarge,
              ),
              content: Text(
                'qr_login_cancel_message'.tr,
                style: theme.textTheme.bodyLarge,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Text(
                    'Continue'.tr,
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    widget.controller.cleanupLoginState();
                    Navigator.pop(context, true);
                  },
                  child: Text(
                    'Cancel'.tr,
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
  void dispose() {
    widget.controller.onLoadingChanged = _originalLoadingCallback;
    widget.controller.onShowLoginInterruptError =
        _originalLoginInterruptCallback;
    widget.controller.onShowXummTerminated = _originalXummTerminatedCallback;
    widget.controller.onShowError = _originalErrorCallback;
    widget.controller.onLoginSuccess = _originalSuccessCallback;
    super.dispose();
  }
}
