// lib/services/xumm_service.dart

import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/services.dart';
// import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class XummService {
  static const platform = MethodChannel('com.example.xsium_chat/app_lifecycle');

  bool _isProcessingLogin = false;
  String? payloadId; // payloadId 변수 추가
  Future<bool> isXummRunning() async {
    try {
      final bool result = await platform.invokeMethod('isXummRunning');
      developer.log('XUMM running status: $result');
      return result;
    } catch (e) {
      developer.log('Error checking XUMM status: $e');
      return false;
    }
  }

  Future<Map<String, String>> createLoginRequest() async {
    if (_isProcessingLogin) {
      throw Exception('Login process already in progress');
    }

    try {
      _isProcessingLogin = true;

      final apiKey = await AppConfig.apiKey;
      final apiSecret = await AppConfig.apiSecret;

      if (apiKey == null || apiSecret == null) {
        throw Exception('API credentials not available');
      }

      final payload = {
        'txjson': {
          'TransactionType': 'SignIn',
        },
        'options': {
          'submit': true,
          'multisign': false,
          'expire': 1,
        },
        'custom_meta': {
          'identifier': 'xsium_login_${DateTime.now().millisecondsSinceEpoch}',
          'blob': {'app': 'xsium', 'purpose': 'authentication'},
          'instruction': 'Xsium 로그인'
        }
      };

      developer
          .log('Creating login request with payload: ${jsonEncode(payload)}');

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/platform/payload'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-Key': apiKey,
          'X-API-Secret': apiSecret,
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to create login request: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      payloadId = data['uuid']; // payloadId 설정
      final deepLink = Platform.isAndroid
          ? 'xumm://xumm.app/sign/${data['uuid']}'
          : data['next']['always'];

      return {
        'requestId': data['uuid'],
        'qrUrl': data['refs']['qr_png'],
        'deepLink': deepLink,
        'wsUrl': data['refs']['websocket_status']
      };
    } catch (e) {
      developer.log('Error in createLoginRequest: $e');
      rethrow;
    } finally {
      _isProcessingLogin = false;
    }
  }

  Future<Map<String, dynamic>> checkSignInStatus(String payloadId) async {
    try {
      final apiKey = await AppConfig.apiKey;
      final apiSecret = await AppConfig.apiSecret;

      if (apiKey == null || apiSecret == null) {
        return {'status': 'error', 'message': 'API credentials not available'};
      }

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/platform/payload/$payloadId'),
        headers: {
          'Accept': 'application/json',
          'X-API-Key': apiKey,
          'X-API-Secret': apiSecret,
        },
      );

      if (response.statusCode != 200) {
        return {'status': 'error', 'message': 'Failed to check status'};
      }

      final data = jsonDecode(response.body);
      final meta = data['meta'] ?? {};
      final responseData = data['response'] ?? {};

      print('XUMM Raw Response: ${response.body}'); // 전체 응답 로그
      print('XUMM Meta Data: $meta'); // meta 데이터 로그

      if (meta['signed'] == true && responseData['account'] != null) {
        return {
          'status': 'success',
          'account': responseData['account'],
        };
      }

      // XUMM API 상태 매핑
      if (meta['cancelled'] == true) {
        return {'status': 'cancelled', 'message': '로그인이 취소되었습니다.'};
      } else if (meta['expired'] == true) {
        return {'status': 'expired', 'message': '로그인 시간이 만료되었습니다.'};
      } else if (meta['invalid'] == true) {
        return {'status': 'invalid', 'message': '잘못된 로그인 요청입니다.'};
      } else if (meta['user_cancelled'] == true) {
        return {'status': 'user_cancelled', 'message': '사용자가 로그인을 취소했습니다.'};
      } else if (meta['server_error'] == true) {
        return {'status': 'server_error', 'message': '서버 오류가 발생했습니다.'};
      }

      return {'status': meta['app_opened'] ? 'opened' : 'pending'};
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<bool> cancelLoginRequest(String payloadId) async {
    try {
      final apiKey = await AppConfig.apiKey;
      final apiSecret = await AppConfig.apiSecret;

      if (apiKey == null || apiSecret == null) {
        throw Exception('API credentials not available');
      }

      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/platform/payload/$payloadId'),
        headers: {
          'Accept': 'application/json',
          'X-API-Key': apiKey,
          'X-API-Secret': apiSecret,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to cancel login request');
      }

      return true;
    } catch (e) {
      developer.log('Error cancelling login request: $e');
      return false;
    }
  }

  /*
  Future<void> closeXummAndSwitchToChat({bool showError = true}) async {
    try {
      await platform.invokeMethod(
          'forceStopXummAndHandleClosure', {'showError': showError});
      await Future.delayed(const Duration(milliseconds: 500));
      await platform.invokeMethod('bringToFront');
    } catch (e) {
      developer.log('Error closing XUMM: $e');
    }
  }
  */

  // 새로운 메서드
  Future<void> closeXummAndSwitchToChat({bool showError = true}) async {
    try {
      if (payloadId != null) {
        // payloadId를 클래스 변수로 추가 필요
        await cancelLoginRequest(payloadId!);
        payloadId = null; // payloadId 초기화
      }
      // XUMM 앱 종료 없이 채팅앱으로 전환
      await Future.delayed(const Duration(milliseconds: 500));
      await platform.invokeMethod('bringToFront');
    } catch (e) {
      developer.log('Error switching to chat: $e');
    }
  }

  Future<void> forceCloseXumm() async {
    try {
      await platform.invokeMethod('forceStopXumm');
    } catch (e) {
      developer.log('Error force closing XUMM: $e');
    }
  }

  Future<void> minimizeXumm() async {
    try {
      await platform.invokeMethod('moveToBackground');
    } catch (e) {
      developer.log('Error minimizing XUMM: $e');
    }
  }

  // 리소스 정리
  // void dispose() {
  //   _isProcessingLogin = false;
  //   _isXummInitialized = false;
  //   _wasXummRunning = false;
  //   _lastXummCheck = null;
  //   _resetState();
  // }
}
