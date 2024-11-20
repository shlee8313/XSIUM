// lib/app.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      await Future.delayed(const Duration(milliseconds: 100));
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
      locale: Locale(
        languageController.currentLanguage.split('_')[0],
        languageController.currentLanguage.split('_')[1],
      ),
      fallbackLocale: const Locale('en', 'US'),
      theme: AppTheme.lightTheme.copyWith(
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
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.themeMode,
      home: !_isInitialized ? _buildLoadingScreen() : const LoginScreen(),
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
        _userSession.onAppBackground();
        break;
      case AppLifecycleState.detached:
        _userSession.clear();
        break;
    }
  }
}
