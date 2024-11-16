// lib/config/app_config.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as developer;

class AppConfig {
  static const String baseUrl = 'https://xumm.app/api/v1';
  static const String appScheme = 'xsium';
  static const String callbackPath = 'login-callback';

  static const _storage = FlutterSecureStorage();

  // 메모리 캐시
  static String? _cachedApiKey;
  static String? _cachedApiSecret;
  static Map<String, String>? _cachedHeaders;

  static Future<void> initialize() async {
    try {
      // dotenv 값 확인
      developer.log('Checking dotenv values...');
      final envApiKey = dotenv.env['XUMM_API_KEY'];
      final envApiSecret = dotenv.env['XUMM_API_SECRET'];

      developer.log('Env API Key: $envApiKey');
      developer.log('Env API Secret: $envApiSecret');

      _cachedApiKey = envApiKey;
      _cachedApiSecret = envApiSecret;

      if (_cachedApiKey == null ||
          _cachedApiSecret == null ||
          _cachedApiKey!.isEmpty ||
          _cachedApiSecret!.isEmpty) {
        developer.log('Warning: API Keys are empty or null');
        return;
      }

      // 저장소에 저장
      await Future.wait([
        _storage.write(key: 'XUMM_API_KEY', value: _cachedApiKey),
        _storage.write(key: 'XUMM_API_SECRET', value: _cachedApiSecret),
      ]);

      // 헤더 미리 생성
      _cachedHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-API-Key': _cachedApiKey!,
        'X-API-Secret': _cachedApiSecret!,
      };

      developer.log('AppConfig initialized successfully');
    } catch (e, stackTrace) {
      developer.log('Error in AppConfig initialize: $e');
      developer.log('Stack trace: $stackTrace');
    }
  }

  static Future<String?> get apiKey async {
    if (_cachedApiKey != null) return _cachedApiKey;

    try {
      _cachedApiKey = await _storage.read(key: 'XUMM_API_KEY');
      return _cachedApiKey;
    } catch (e) {
      developer.log('Error getting API key: $e');
      return null;
    }
  }

  static Future<String?> get apiSecret async {
    if (_cachedApiSecret != null) return _cachedApiSecret;

    try {
      _cachedApiSecret = await _storage.read(key: 'XUMM_API_SECRET');
      return _cachedApiSecret;
    } catch (e) {
      developer.log('Error getting API secret: $e');
      return null;
    }
  }

  static Future<Map<String, String>> getApiHeaders() async {
    if (_cachedHeaders != null) return _cachedHeaders!;

    try {
      final apiKey = await AppConfig.apiKey;
      final apiSecret = await AppConfig.apiSecret;

      _cachedHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-API-Key': apiKey ?? '',
        'X-API-Secret': apiSecret ?? '',
      };

      return _cachedHeaders!;
    } catch (e) {
      developer.log('Error creating headers: $e');
      return {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
    }
  }

  // 저장된 모든 값을 확인하는 메서드 추가
  static Future<void> checkStorage() async {
    try {
      final allValues = await _storage.readAll();
      developer.log('All stored values: $allValues');

      final storedApiKey = await _storage.read(key: 'XUMM_API_KEY');
      final storedApiSecret = await _storage.read(key: 'XUMM_API_SECRET');

      developer.log('Stored API Key: $storedApiKey');
      developer.log('Stored API Secret: $storedApiSecret');

      if (storedApiKey != _cachedApiKey ||
          storedApiSecret != _cachedApiSecret) {
        developer.log('Warning: Stored values do not match cached values');
      }
    } catch (e) {
      developer.log('Error checking storage: $e');
    }
  }

  static void clearCache() {
    _cachedApiKey = null;
    _cachedApiSecret = null;
    _cachedHeaders = null;
  }

  static Future<void> clearStorage() async {
    try {
      await _storage.deleteAll();
      clearCache();
      developer.log('Storage and cache cleared');
    } catch (e) {
      developer.log('Error clearing storage: $e');
    }
  }
}
