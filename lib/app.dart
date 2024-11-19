// lib/app.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:flutter/services.dart';
import 'config/theme.dart';
import 'core/session/user_session.dart';
import 'core/controllers/theme_controller.dart';
import 'modules/auth/views/login_screen.dart';
// import 'modules/home/home_screen.dart';
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
  late final ThemeController themeController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    themeController = Get.put(ThemeController());
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
        _initialRoute = '/login';
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
    if (!_isInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          backgroundColor: AppColors.surfaceLight,
          body: Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryLight,
            ),
          ),
        ),
      );
    }

    return GetMaterialApp(
      title: 'Xsium Chat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const LoginScreen(),
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
