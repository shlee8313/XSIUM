// lib/services/xumm_service.dart

import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
// import 'package:url_launcher/url_launcher.dart';

enum XummApiStatus {
  success,
  cancelled,
  expired,
  invalid,
  userCancelled,
  serverError,
  pending,
  opened,
  error
}

class XummService {
  static const platform = MethodChannel('com.example.xsium_chat/app_lifecycle');

  bool _isProcessingLogin = false;
  String? payloadId;

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

      // HTTP 요청에 명시적인 timeout 설정
      final response = await http
          .post(
            Uri.parse('${AppConfig.baseUrl}/platform/payload'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'X-API-Key': apiKey,
              'X-API-Secret': apiSecret,
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 5)); // 5초 timeout 추가

      developer.log('Received response with status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to create login request: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      payloadId = data['uuid'];

      final deepLink = Platform.isAndroid
          ? 'xumm://xumm.app/sign/${data['uuid']}'
          : data['next']['always'];

      developer
          .log('Login request created successfully with UUID: ${data['uuid']}');

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
        return {'status': 'error', 'message': 'api_credentials_unavailable'.tr};
      }

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/platform/payload/$payloadId'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-API-Key': apiKey,
          'X-API-Secret': apiSecret,
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        developer.log(
            'API Error - Status: ${response.statusCode}, Body: ${response.body}');
        return {'status': 'error', 'message': 'api_request_failed'.tr};
      }

      final data = jsonDecode(response.body);
      final meta = data['meta'] ?? {};
      final responseData = data['response'] ?? {};

      developer.log('XUMM Sign Status - Meta: $meta');
      developer.log('XUMM Sign Status - Response: $responseData');

      // null 안전 처리 추가
      if (meta is! Map) {
        return {'status': 'error', 'message': 'invalid_meta_data'.tr};
      }

      // boolean 값 안전하게 처리
      bool isSigned = meta['signed'] ?? false;
      bool isResolved = meta['resolved'] ?? false;
      bool isCancelled = meta['cancelled'] ?? false;
      bool isExpired = meta['expired'] ?? false;
      bool isInvalid = meta['invalid'] ?? false;
      bool isUserCancelled = meta['user_cancelled'] ?? false;
      bool isServerError = meta['server_error'] ?? false;
      bool isPushed = meta['pushed'] ?? false;
      bool isAppOpened = meta['app_opened'] ?? false;
      bool isOpenedByDeeplink = meta['opened_by_deeplink'] ?? false;

      if (isSigned || isResolved) {
        final account = responseData['account'] ?? meta['resolved_account'];
        if (account != null && account.toString().isNotEmpty) {
          return {
            'status': 'success',
            'account': account,
          };
        } else {
          return {'status': 'cancelled', 'message': 'login_cancelled'.tr};
        }
      }

      if (isCancelled) {
        return {'status': 'cancelled', 'message': 'login_cancelled'.tr};
      } else if (isExpired) {
        return {'status': 'expired', 'message': 'login_expired'.tr};
      } else if (isInvalid) {
        return {'status': 'invalid', 'message': 'invalid_login_request'.tr};
      } else if (isUserCancelled) {
        return {
          'status': 'user_cancelled',
          'message': 'user_cancelled_login'.tr
        };
      } else if (isServerError) {
        return {
          'status': 'server_error',
          'message': 'server_error_occurred'.tr
        };
      } else if (isPushed) {
        return {'status': 'pushed', 'message': 'request_pushed'.tr};
      } else if (isAppOpened || isOpenedByDeeplink) {
        return {'status': 'opened'};
      }

      return {'status': 'pending'};
    } catch (e) {
      developer.log('Error checking sign-in status: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<bool> cancelLoginRequest(String payloadId) async {
    try {
      final apiKey = await AppConfig.apiKey;
      final apiSecret = await AppConfig.apiSecret;

      if (apiKey == null || apiSecret == null) {
        throw Exception('api_credentials_unavailable'.tr);
      }

      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/platform/payload/$payloadId'),
        headers: {
          'Accept': 'application/json',
          'X-API-Key': apiKey,
          'X-API-Secret': apiSecret,
        },
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      developer.log('Error cancelling login request: $e');
      return false;
    }
  }

  Future<void> closeXummAndSwitchToChat({bool showError = true}) async {
    try {
      if (payloadId != null) {
        await cancelLoginRequest(payloadId!);
        payloadId = null;
      }
      await forceCloseXumm(); // XUMM 앱 강제 종료
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

  void dispose() {
    _isProcessingLogin = false;
    payloadId = null;
  }
}
