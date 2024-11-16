// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart'; // 추가: PlatformDispatcher를 위한 import
import 'dart:developer' as developer;
import 'app.dart';
import 'config/app_config.dart';
import 'core/session/user_session.dart'; // 추가: UserSession import

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // 화면 방향 고정
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    developer.log('Starting app initialization');

    // 환경 설정 로드
    await dotenv.load(fileName: ".env");
    developer.log('.env file loaded');

    // AppConfig 초기화
    await AppConfig.initialize();
    await AppConfig.checkStorage();

    // 추가: UserSession 초기화
    final userSession = UserSession();
    await userSession.initialize();

    // 추가: 시스템 UI 설정
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // 글로벌 에러 핸들러 설정
    FlutterError.onError = (FlutterErrorDetails details) {
      developer.log('Flutter error: ${details.exception}');
      developer.log('Stack trace: ${details.stack}');
      // 추가: 심각한 에러 발생 시 세션 클리어
      if (details.stack.toString().contains('setState') ||
          details.stack.toString().contains('build')) {
        UserSession().clear();
      }
    };

    // 플랫폼 에러 핸들러 설정
    PlatformDispatcher.instance.onError = (error, stack) {
      developer.log('Platform error: $error');
      developer.log('Stack trace: $stack');
      return true;
    };

    developer.log('App initialization completed');
    runApp(const XsiumChatApp());
  } catch (e, stackTrace) {
    developer.log('Critical error in main: $e');
    developer.log('Stack trace: $stackTrace');
    // 추가: 심각한 에러 발생 시 초기화 진행
    await AppConfig.clearStorage();
    runApp(const XsiumChatApp());
  }
}
