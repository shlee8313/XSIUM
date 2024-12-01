// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import 'app.dart';
import 'config/app_config.dart';
import 'core/session/user_session.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 화면 방향 설정 따로 처리
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // UI 스타일 설정
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  // 앱 초기화 로직
  try {
    // 필수적인 초기화 작업
    await Future.wait<void>([
      dotenv.load(fileName: ".env"),
      AppConfig.initialize(),
    ]);

    // 나머지 초기화는 마이크로태스크로 백그라운드에서 수행
    Future.microtask(() async {
      await UserSession().initialize();
      if (kDebugMode) {
        await AppConfig.checkStorage();
      }
    });
  } catch (e, stackTrace) {
    if (kDebugMode) {
      developer.log('Critical error in main: $e', stackTrace: stackTrace);
    }
    await AppConfig.clearStorage();
  }

  // 글로벌 에러 핸들러 설정
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      developer.log('Flutter error: ${details.exception}');
      developer.log('Stack trace: ${details.stack}');
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      developer.log('Platform error: $error');
      developer.log('Stack trace: $stack');
    }
    return true;
  };

  runApp(const XsiumChatApp());
}
