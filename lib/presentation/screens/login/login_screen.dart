// lib/presentation/screens/login/login_screen.dart

import 'package:flutter/material.dart';
import '../../controller/login_controller.dart';
import '../../widgets/login_interrupt_error_dialog.dart';
import '../../widgets/xumm_terminated_error_dialog.dart';
import '../../widgets/error_dialog.dart';
import './qr_login_dialog.dart';
import '../home_screen.dart';
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
    return Scaffold(
      backgroundColor: Colors.white,
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
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 60),
                    // 기존 버튼
                    /*
                    ElevatedButton(
                      onPressed: () {
                        _controller.cleanupLoginState();
                        _controller.loginWithLocalXumm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(220, 70),
                      ),
                      child: const Text(
                        'Login on This Device',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    */
                    // 새로운 버튼 (로딩 상태 포함)
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              _controller.cleanupLoginState();
                              _controller.loginWithLocalXumm();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(220, 70),
                        // 로딩 중일 때 버튼 비활성화
                        disabledBackgroundColor: Colors.blue.withOpacity(0.7),
                        disabledForegroundColor: Colors.white70,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Login on This Device',
                              style: TextStyle(fontSize: 20),
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
                        side: const BorderSide(color: Colors.blueAccent),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(220, 70),
                      ),
                      child: const Text(
                        'Login on Another Device',
                        style: TextStyle(fontSize: 18),
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
