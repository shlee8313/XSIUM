// lib/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async'; // 추가: Timer를 위한 import
import 'dart:developer' as developer;
import '../../core/session/user_session.dart';
import '../screens/login/login_screen.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  final String userAddress;

  const HomeScreen({
    super.key,
    required this.userAddress,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final _userSession = UserSession();
  bool _isReady = false;
  bool _isLoggingOut = false;
  bool _isSessionValid = true;
  Timer? _sessionCheckTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _prepareScreen();
    // [수정 1] 세션 체크 시작 전에 mounted 확인
    if (mounted) {
      _startSessionCheck();
    }
  }

  @override
  void dispose() {
    // [수정 2] Timer 정리
    _sessionCheckTimer?.cancel();
    _sessionCheckTimer = null;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _prepareScreen() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() => _isReady = true);
      }
    } catch (e) {
      developer.log('Error preparing home screen: $e');
    }
  }

  // 추가: 세션 체크 타이머 시작
  // [수정 3] 세션 체크 타이머 로직 개선
  void _startSessionCheck() {
    _sessionCheckTimer?.cancel();
    _sessionCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      // mounted 체크 추가
      if (!mounted) {
        timer.cancel();
        return;
      }
      _validateSession();
    });
  }

  // 추가: 세션 유효성 검사
  Future<void> _validateSession() async {
    if (!mounted) return;

    final isValid = _userSession.validateSession();
    if (!isValid && mounted) {
      setState(() => _isSessionValid = false);
      await _handleLogout();
    }
  }

  // 수정: 로그아웃 처리 개선
  Future<void> _handleLogout() async {
    if (_isLoggingOut || !mounted) return;

    try {
      setState(() => _isLoggingOut = true);
      final wasSessionValid = _isSessionValid;

      // Timer 정리
      _sessionCheckTimer?.cancel();
      _sessionCheckTimer = null;

      // 세션 클리어
      await _userSession.clear();

      if (!mounted) return;

      await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (route) => false,
      );

      if (!wasSessionValid && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('세션이 만료되었습니다. 다시 로그인해주세요.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      developer.log('Error during logout: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그아웃 중 오류가 발생했습니다.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('앱 종료'),
            content: const Text('앱을 종료하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(true);
                  SystemNavigator.pop();
                },
                child: const Text('종료'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final result = await _onWillPop();
        if (result && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: AnimatedOpacity(
          opacity: _isReady ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: SafeArea(
            child: Column(
              children: [
                AppBar(
                  title: const Text('홈'),
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: _isLoggingOut ? null : _handleLogout,
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 24.0,
                    ),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '안녕하세요!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            '지갑 주소: ${widget.userAddress}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 24),
                          // 추가적인 UI 컴포넌트들을 여기에 배치
                          // 예: 채팅 목록, 설정 버튼 등

                          // MessageBubble(
                          //   message: "This is a confidential message.",
                          //   isSentByUser: true,
                          // ),
                          // MessageBubble(
                          //   message: "It's less readable from a camera.",
                          //   isSentByUser: false,
                          // ),
                        ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        if (mounted && !_isReady) {
          _validateSession();
          setState(() => _isReady = true);
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        if (mounted && _isReady) {
          setState(() => _isReady = false);
        }
        break;
      case AppLifecycleState.detached:
        break;
    }
  }
}
