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
  WidgetsFlutterBinding.ensureInitialized();

  // 화면 방향 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 초기화 작업 병렬 실행
  try {
    await Future.wait([
      dotenv.load(fileName: ".env"),
      AppConfig.initialize(),
      AppConfig.checkStorage(),
      UserSession().initialize(),
    ]);
  } catch (e, stackTrace) {
    developer.log('Critical error in main: $e', stackTrace: stackTrace);
    // 초기화 실패 시 스토리지 초기화
    await AppConfig.clearStorage();
  }

  // UI 설정
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  // 글로벌 에러 핸들러 설정
  FlutterError.onError = (FlutterErrorDetails details) {
    developer.log('Flutter error: ${details.exception}');
    developer.log('Stack trace: ${details.stack}');
    if (details.stack.toString().contains('setState') ||
        details.stack.toString().contains('build')) {
      UserSession().clear();
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    developer.log('Platform error: $error');
    developer.log('Stack trace: $stack');
    return true;
  };

  runApp(const XsiumChatApp());
}
