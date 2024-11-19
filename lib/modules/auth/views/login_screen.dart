// lib/presentation/screens/login/login_screen.dart

import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../controllers/login_controller.dart';
import '../../widgets/alert/login_interrupt_error_dialog.dart';
import '../../widgets/alert/xumm_terminated_error_dialog.dart';
import '../../widgets/alert/error_dialog.dart';
import 'qr_login_dialog.dart';
import '../../home/home_screen.dart';
import 'dart:async';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with WidgetsBindingObserver {
  final LoginController _controller = LoginController();
  bool _showLoginInterruptError = false;
  bool _showXummTerminated = false;
  bool _showError = false;
  String _errorMessage = '';
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupController();
    _controller.checkXummInstallation();
  }

  // 기존 컨트롤러 설정
  /*
  void _setupController() {
    _controller.onLoadingChanged = (value) {
      if (mounted) setState(() {});
    };

    _controller.onXummOpenedChanged = (value) {
      if (mounted) setState(() {});
    };

    _controller.onError = (message) {
      if (mounted) _showError(message);
    };

    _controller.onLoginSuccess = (account) {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => HomeScreen(userAddress: account),
          ),
          (route) => false,
        );
      }
    };

    _controller.onLoginInterruption = () {
      if (mounted) {
        _handleLoginInterruption();
      }
    };
  }
  */

  // 새로운 컨트롤러 설정
  void _setupController() {
    _controller.onLoadingChanged = (value) {
      if (mounted) {
        setState(() {
          _isLoading = value;
        });
      }
    };

    _controller.onXummOpenedChanged = (value) {
      if (mounted) {
        setState(() {
          _isLoading = false; // Xumm이 열리면 로딩 중단
        });
      }
    };

    _controller.onLoginSuccess = (account) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                HomeScreen(userAddress: account),
            transitionDuration: Duration.zero, // 전환 애니메이션 제거
            reverseTransitionDuration: Duration.zero,
          ),
        );
      }
    };

    _controller.onShowLoginInterruptError = () {
      if (mounted) {
        setState(() {
          _showLoginInterruptError = true;
        });
        Timer(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _showLoginInterruptError = false;
            });
          }
        });
      }
    };

    _controller.onShowXummTerminated = () {
      if (mounted) {
        setState(() {
          _showXummTerminated = true;
        });
        Timer(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _showXummTerminated = false;
            });
          }
        });
      }
    };

    _controller.onShowError = (message) {
      if (mounted) {
        setState(() {
          _showError = true;
          _errorMessage = message;
        });
        Timer(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _showError = false;
            });
          }
        });
      }
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
                      'Welcome to Xsium',
                      style: theme.textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 60),
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              _controller.cleanupLoginState();
                              _controller.loginWithLocalXumm();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        disabledBackgroundColor:
                            colorScheme.primary.withOpacity(0.7),
                        disabledForegroundColor:
                            colorScheme.onPrimary.withOpacity(0.7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(220, 70),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: colorScheme.onPrimary,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Login on This Device',
                              style: TextStyle(
                                fontSize: 20,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                    ),
                    const SizedBox(height: 30),
                    OutlinedButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => QRLoginDialog(
                          controller: _controller,
                          onLoginInterruptError: (value) {
                            setState(() {
                              _showLoginInterruptError = value;
                            });
                            Timer(const Duration(seconds: 3), () {
                              if (mounted) {
                                setState(() {
                                  _showLoginInterruptError = false;
                                });
                              }
                            });
                          },
                          onXummTerminated: (value) {
                            setState(() {
                              _showXummTerminated = value;
                            });
                            Timer(const Duration(seconds: 3), () {
                              if (mounted) {
                                setState(() {
                                  _showXummTerminated = false;
                                });
                              }
                            });
                          },
                          onError: (show, message) {
                            setState(() {
                              _showError = show;
                              _errorMessage = message;
                            });
                            Timer(const Duration(seconds: 3), () {
                              if (mounted) {
                                setState(() {
                                  _showError = false;
                                });
                              }
                            });
                          },
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                        side: BorderSide(color: colorScheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(220, 70),
                      ),
                      child: Text(
                        'Login on Another Device',
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
          if (_showLoginInterruptError)
            LoginInterruptErrorDialog(
              isOpen: _showLoginInterruptError,
              onClose: () {
                setState(() {
                  _showLoginInterruptError = false;
                });
              },
            ),
          if (_showXummTerminated)
            XummTerminatedDialog(
              isOpen: _showXummTerminated,
              onClose: () {
                setState(() {
                  _showXummTerminated = false;
                });
              },
            ),
          if (_showError)
            ErrorDialog(
              message: _errorMessage,
              onClose: () {
                setState(() {
                  _showError = false;
                });
              },
            ),
        ],
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      if (_controller.isLoading) {
        // 로딩 중일 때만 인터럽트 다이얼로그 표시
        setState(() {
          _showLoginInterruptError = true;
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _showLoginInterruptError = false;
            });
          }
        });
      }
    } else if (state == AppLifecycleState.paused) {
      setState(() {
        _showLoginInterruptError = false;
        _showXummTerminated = false;
        _showError = false;
      });
    }
  }
}
