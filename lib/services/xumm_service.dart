// lib/services/xumm_service.dart

import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<Map<String, dynamic>> createLoginRequest(
      {bool launchDeepLink = true}) async {
    if (_isProcessingLogin) {
      developer.log('Login process already in progress');
      throw Exception('login_in_progress'.tr);
    }

    try {
      _isProcessingLogin = true;
      developer.log('Creating new login request');

      final apiKey = await AppConfig.apiKey;
      final apiSecret = await AppConfig.apiSecret;

      if (apiKey == null || apiSecret == null) {
        throw Exception('api_credentials_unavailable'.tr);
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
          'instruction': 'Xsium Login'
        }
      };

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
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('api_request_failed'.tr);
      }

      final data = jsonDecode(response.body);
      payloadId = data['uuid'];

      final deepLink = Platform.isAndroid
          ? 'xumm://xumm.app/sign/${data['uuid']}'
          : data['next']['always'];

      if (launchDeepLink) {
        developer.log('Launching XUMM with deepLink: $deepLink');
        // Native channel을 통해 XUMM 실행
        try {
          await platform.invokeMethod('openXummLogin', {'deepLink': deepLink});
        } catch (e) {
          developer.log('Error launching XUMM via platform channel: $e');
          // fallback으로 url_launcher 시도
          final uri = Uri.parse(deepLink);
          if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
            throw Exception('xumm_launch_failed'.tr);
          }
        }
      }

      return {
        'requestId': data['uuid'],
        'qrUrl': data['refs']['qr_png'],
        'deepLink': deepLink,
        'wsUrl': data['refs']['websocket_status'],
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

      // [수정전 코드]
      // final response = await http.get(
      //   Uri.parse('${AppConfig.baseUrl}/platform/payload/$payloadId'),
      //   headers: {
      //     'Accept': 'application/json',
      //     'X-API-Key': apiKey,
      //     'X-API-Secret': apiSecret,
      //   },
      // ).timeout(const Duration(seconds: 10));

      // [수정후 코드]
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

      // [수정전 코드]
      // if (meta['signed'] == true && responseData['account'] != null) {
      //   return {
      //     'status': 'success',
      //     'account': responseData['account'],
      //   };
      // }

      // [수정후 코드]
      if (meta['signed'] == true) {
        if (responseData['account'] != null &&
            responseData['account'].toString().isNotEmpty) {
          return {
            'status': 'success',
            'account': responseData['account'],
          };
        } else {
          developer.log('Account data missing in signed payload');
          return {'status': 'error', 'message': 'missing_account_data'.tr};
        }
      }

      if (meta['resolved'] == true) {
        return {
          'status': 'success',
          'account': responseData['account'] ?? meta['resolved_account'],
        };
      }

      if (meta['cancelled'] == true) {
        return {'status': 'cancelled', 'message': 'login_cancelled'.tr};
      } else if (meta['expired'] == true) {
        return {'status': 'expired', 'message': 'login_expired'.tr};
      } else if (meta['invalid'] == true) {
        return {'status': 'invalid', 'message': 'invalid_login_request'.tr};
      } else if (meta['user_cancelled'] == true) {
        return {
          'status': 'user_cancelled',
          'message': 'user_cancelled_login'.tr
        };
      } else if (meta['server_error'] == true) {
        return {
          'status': 'server_error',
          'message': 'server_error_occurred'.tr
        };
      } else if (meta['pushed']) {
        return {'status': 'pushed', 'message': 'request_pushed'.tr};
      } else if (meta['app_opened'] || meta['opened_by_deeplink']) {
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
