// lib/presentation/screens/login/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:async';
// import '../../../config/theme.dart';
import '../controllers/login_controller.dart';
import '../../widgets/alert/login_interrupt_error_dialog.dart';
import '../../widgets/alert/xumm_terminated_error_dialog.dart';
import '../../widgets/alert/error_dialog.dart';
import 'qr_login_dialog.dart';
import '../../home/home_screen.dart';
import 'dart:developer' as developer;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with WidgetsBindingObserver {
  late final LoginController _controller;
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  final ValueNotifier<String> _errorMessage = ValueNotifier('');
  final ValueNotifier<bool> _showLoginInterruptError = ValueNotifier(false);
  final ValueNotifier<bool> _showXummTerminated = ValueNotifier(false);
  final ValueNotifier<bool> _showError = ValueNotifier(false);

  Timer? _stateResetTimer;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _initializeSecurity();
    _initializeController();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _initializeSecurity() async {
    // 스크린샷 방지
    await SystemChannels.platform.invokeMethod<void>(
      'SystemChrome.setPreventScreenCapture',
      true,
    );
  }

  void _initializeController() {
    _controller = Get.put(LoginController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) {
        _controller.checkXummInstallation();
      }
    });

    _setupControllerCallbacks();
  }

  void _setupControllerCallbacks() {
    _controller
      ..onLoadingChanged = (value) {
        if (!_disposed) _isLoading.value = value;
      }
      // ..onLoginSuccess = _handleLoginSuccess
      ..onShowLoginInterruptError = () {
        _showTemporaryDialog(_showLoginInterruptError);
      }
      ..onShowXummTerminated = () {
        _showTemporaryDialog(_showXummTerminated);
      }
      ..onShowError = (message) {
        _errorMessage.value = message;
        _showTemporaryDialog(_showError);
      };
  }

  Future<void> _handleLoginSuccess(String account) async {
    if (_disposed) return;

    try {
      await Get.off(
        () => HomeScreen(userAddress: account),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      developer.log('Error navigating to home screen: $e', error: e);
      _errorMessage.value = 'navigation_error'.tr;
      _showTemporaryDialog(_showError);
    }
  }

  void _showTemporaryDialog(ValueNotifier<bool> dialogState,
      {Duration duration = const Duration(seconds: 3)}) {
    dialogState.value = true;
    Future.delayed(duration, () {
      if (!_disposed) dialogState.value = false;
    });
  }

  void _showQRLoginDialog() {
    if (_disposed) return;

    Get.dialog(
      QRLoginDialog(
        controller: _controller,
        onLoginInterruptError: (value) =>
            _showTemporaryDialog(_showLoginInterruptError),
        onXummTerminated: (value) => _showTemporaryDialog(_showXummTerminated),
        onError: (show, message) {
          _errorMessage.value = message;
          _showTemporaryDialog(_showError);
        },
      ),
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 200),
      transitionCurve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          _buildMainContent(),
          _buildDialogs(),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return RepaintBoundary(
      child: SafeArea(
        child: CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: _LoginContent(
                controller: _controller,
                isLoading: _isLoading,
                onQRLogin: _showQRLoginDialog,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogs() {
    return Stack(
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: _showLoginInterruptError,
          builder: (_, show, __) {
            return show
                ? LoginInterruptErrorDialog(
                    isOpen: true, // isOpen 추가
                    onClose: () => _showLoginInterruptError.value = false,
                  )
                : const SizedBox.shrink();
          },
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _showXummTerminated,
          builder: (_, show, __) {
            return show
                ? XummTerminatedDialog(
                    isOpen: true, // isOpen 추가
                    onClose: () => _showXummTerminated.value = false,
                  )
                : const SizedBox.shrink();
          },
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _showError,
          builder: (_, show, __) {
            return show
                ? ErrorDialog(
                    message: _errorMessage.value,
                    onClose: () => _showError.value = false,
                  )
                : const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _stateResetTimer?.cancel();
    _isLoading.dispose();
    _errorMessage.dispose();
    _showLoginInterruptError.dispose();
    _showXummTerminated.dispose();
    _showError.dispose();
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_disposed) return;

    if (state == AppLifecycleState.resumed && _controller.isLoading) {
      _showTemporaryDialog(_showLoginInterruptError);
    }
  }
}

class _LoginContent extends StatelessWidget {
  final LoginController controller;
  final ValueNotifier<bool> isLoading;
  final VoidCallback onQRLogin;

  const _LoginContent({
    required this.controller,
    required this.isLoading,
    required this.onQRLogin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Welcome to Xsium', style: theme.textTheme.headlineLarge),
          const SizedBox(height: 60),
          ValueListenableBuilder<bool>(
            valueListenable: isLoading,
            builder: (_, loading, __) {
              return ElevatedButton(
                onPressed: loading
                    ? null
                    : () async {
                        // Start loading when the button is pressed
                        // isLoading.value = true;

                        // Trigger the login logic

                        try {
                          // 로그인 로직 실행
                          controller.cleanupLoginState();
                          await controller.loginWithLocalXumm();
                        } catch (e) {
                          // 에러 발생 시 로딩 종료
                          // isLoading.value = false;
                          developer.log('Login error: $e');
                        }
                        // 주의: 성공 시에는 여기서 isLoading을 false로 설정하지 않음
                        // 로그인 컨트롤러에서 처리함
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  // 비활성화 상태의 색상 추가
                  disabledBackgroundColor:
                      colorScheme.primary, // 로딩 중에도 같은 배경색 유지
                  disabledForegroundColor:
                      colorScheme.onPrimary, // 로딩 중에도 같은 텍스트/아이콘 색상 유지
                  minimumSize: const Size(220, 70),
                ),
                child: loading
                    ? CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      )
                    : Text(
                        'login_this_device'.tr,
                        style: const TextStyle(fontSize: 20),
                      ),
              );
            },
          ),
          const SizedBox(height: 30),
          OutlinedButton(
            onPressed: onQRLogin,
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
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
