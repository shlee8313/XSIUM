// lib/presentation/screens/login/login_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../../config/theme.dart';
import '../controllers/login_controller.dart';
import '../../widgets/alert/login_interrupt_error_dialog.dart';
import '../../widgets/alert/xumm_terminated_error_dialog.dart';
import '../../widgets/alert/error_dialog.dart';
import 'qr_login_dialog.dart';
import '../../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with WidgetsBindingObserver {
  // 개선된 상태 관리
  final LoginController _controller = LoginController();
  final RxBool _showLoginInterruptError = false.obs;
  final RxBool _showXummTerminated = false.obs;
  final RxBool _showError = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxBool _isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupController();
    _controller.checkXummInstallation();
  }

  void _setupController() {
    _controller.onLoadingChanged = (value) {
      if (mounted) _isLoading.value = value;
    };

    _controller.onXummOpenedChanged = (value) {
      if (mounted) _isLoading.value = false;
    };

    _controller.onLoginSuccess = (account) {
      if (mounted) {
        Get.off(
          () => HomeScreen(userAddress: account),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    };

    _controller.onShowLoginInterruptError = () {
      if (mounted) {
        _showLoginInterruptError.value = true;
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) _showLoginInterruptError.value = false;
        });
      }
    };

    _controller.onShowXummTerminated = () {
      if (mounted) {
        _showXummTerminated.value = true;
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) _showXummTerminated.value = false;
        });
      }
    };

    _controller.onShowError = (message) {
      if (mounted) {
        _errorMessage.value = message;
        _showError.value = true;
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) _showError.value = false;
        });
      }
    };
  }

  void _showQRLoginDialog() {
    Get.dialog(
      QRLoginDialog(
        controller: _controller,
        onLoginInterruptError: (value) {
          _showLoginInterruptError.value = value;
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              _showLoginInterruptError.value = false;
            }
          });
        },
        onXummTerminated: (value) {
          _showXummTerminated.value = value;
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              _showXummTerminated.value = false;
            }
          });
        },
        onError: (show, message) {
          _errorMessage.value = message;
          _showError.value = show;
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              _showError.value = false;
            }
          });
        },
      ),
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 200),
      transitionCurve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome to XSIUM',
                      style: theme.textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 60),
                    Obx(() => ElevatedButton(
                          onPressed: _isLoading.value
                              ? null
                              : () {
                                  _controller.cleanupLoginState();
                                  _controller.loginWithLocalXumm();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            disabledBackgroundColor: colorScheme.primary
                                .withAlpha(178), // 70% opacity
                            disabledForegroundColor: colorScheme.onPrimary
                                .withAlpha(178), // 70% opacity
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            minimumSize: const Size(220, 70),
                          ),
                          child: _isLoading.value
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: colorScheme.onPrimary,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'login_this_device'.tr,
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                        )),
                    const SizedBox(height: 30),
                    OutlinedButton(
                      onPressed: () => _showQRLoginDialog(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                        side: BorderSide(color: colorScheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(220, 70),
                      ),
                      child: Text(
                        'login_other_device'.tr,
                        style: TextStyle(
                          fontSize: 18,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Obx(() => Stack(
                children: [
                  if (_showLoginInterruptError.value)
                    LoginInterruptErrorDialog(
                      isOpen: _showLoginInterruptError.value,
                      onClose: () => _showLoginInterruptError.value = false,
                    ),
                  if (_showXummTerminated.value)
                    XummTerminatedDialog(
                      isOpen: _showXummTerminated.value,
                      onClose: () => _showXummTerminated.value = false,
                    ),
                  if (_showError.value)
                    ErrorDialog(
                      message: _errorMessage.value,
                      onClose: () => _showError.value = false,
                    ),
                ],
              )),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _showLoginInterruptError.close();
    _showXummTerminated.close();
    _showError.close();
    _errorMessage.close();
    _isLoading.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (!mounted) return;

    switch (state) {
      case AppLifecycleState.resumed:
        if (_controller.isLoading) {
          _showLoginInterruptError.value = true;
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              _showLoginInterruptError.value = false;
            }
          });
        }
        break;
      case AppLifecycleState.paused:
        _showLoginInterruptError.value = false;
        _showXummTerminated.value = false;
        _showError.value = false;
        _errorMessage.value = '';
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
      case AppLifecycleState.detached:
        _controller.cleanupLoginState();
        break;
    }
  }
}
