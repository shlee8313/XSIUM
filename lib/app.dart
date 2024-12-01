// lib/app.dart

import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'core/session/user_session.dart';
import 'modules/auth/views/login_screen.dart';
import 'config/theme.dart';
import 'core/controllers/theme_controller.dart';
import 'core/controllers/language_controller.dart';
import 'core/translations/app_translations.dart';
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
  late final ThemeController themeController;
  late final LanguageController languageController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    themeController = Get.put(ThemeController());
    languageController = Get.put(LanguageController());
    _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      // await Future.delayed(
      //     const Duration(milliseconds: 100)); // 불필요한 delay 제거 가능
      if (!mounted) return;

      final sessionState = _userSession.getSessionState();
      developer.log('Initial session state: $sessionState');

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      developer.log('Error initializing app: $e');
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'app_name'.tr,
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      // Language 설정 개선: 안정성 검사 추가
      locale: _getLocale(),
      fallbackLocale: const Locale('en', 'US'),
      theme: AppTheme.lightTheme.copyWith(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
        ),
      ),
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.themeMode,
      home: _isInitialized ? const LoginScreen() : _buildLoadingScreen(),
      builder: (context, child) {
        if (child == null) {
          return const LoginScreen();
        }
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child,
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Obx(() => Scaffold(
          backgroundColor: themeController.isDarkMode.value
              ? AppColors.surfaceDark
              : AppColors.surfaceLight,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: themeController.isDarkMode.value
                      ? AppColors.primaryDark
                      : AppColors.primaryLight,
                ),
                const SizedBox(height: 16),
                Text(
                  'initializing_message'.tr,
                  style: TextStyle(
                    color: themeController.isDarkMode.value
                        ? Colors.grey[400]
                        : Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  // Language 설정 안정성 개선
  Locale _getLocale() {
    final languageParts = languageController.currentLanguage.split('_');
    return languageParts.length == 2
        ? Locale(languageParts[0], languageParts[1])
        : const Locale('en', 'US');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _userSession.onAppForeground();
        if (!_isInitialized) {
          _initializeApp();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        // 세션을 완전히 클리어하지 않고 백그라운드 상태만 관리
        _userSession.onAppBackground();
        break;
      case AppLifecycleState.detached:
        // 앱이 완전히 종료될 때만 세션 클리어
        _userSession.clear();
        break;
    }
  }
}
