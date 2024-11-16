// lib/app.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/session/user_session.dart';
import 'presentation/screens/login/login_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'dart:developer' as developer;

class XsiumChatApp extends StatefulWidget {
  const XsiumChatApp({super.key});

  @override
  State<XsiumChatApp> createState() => _XsiumChatAppState();
}

class _XsiumChatAppState extends State<XsiumChatApp>
    with WidgetsBindingObserver {
  final _userSession = UserSession();
  bool _isInitialized = false;
  String? _initialRoute;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));

      if (!mounted) return;

      final sessionState = _userSession.getSessionState();
      developer.log('Initial session state: $sessionState');

      setState(() {
        _isInitialized = true;
        _initialRoute = '/login'; // 항상 로그인 화면부터 시작
      });
    } catch (e) {
      developer.log('Error initializing app: $e');
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _initialRoute = '/login';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 초기화 중일 때 보여줄 화면
    if (!_isInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 로딩 인디케이터
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                // 로딩 메시지
                Text(
                  '앱을 초기화하는 중입니다...',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Xsium Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
        ),
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const LoginScreen(), // 직접 홈 화면 지정
      builder: (context, child) {
        // null 체크 추가
        if (child == null) {
          return const LoginScreen();
        }

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child,
        );
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _userSession.onAppForeground();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _userSession.onAppBackground();
        break;
      case AppLifecycleState.detached:
        _userSession.clear();
        break;
    }
  }
}
