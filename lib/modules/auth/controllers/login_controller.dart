// lib/presentation/controller/login_controller.dart

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/xumm_service.dart';
import '../../../core/session/user_session.dart';

class LoginController {
  final XummService _xummService = XummService();
  final _userSession = UserSession();
  static const platform = MethodChannel('com.example.xsium_chat/app_lifecycle');

  static const int maxPollingDuration = 60;
  static const int warningThreshold = 45;
  static const int initialPollingInterval = 2000;
  static const int maxPollingInterval = 5000;
  static const int maxConsecutiveOpened = 5;

  Timer? _timer;
  Timer? _preAuthTimer;
  Timer? _xummLaunchTimer;
  Timer? _timeoutTimer;

  DateTime? _lastStateChangeTime;
  DateTime? _pollingStartTime;

  bool _isCancelled = false;
  bool _isProcessingSuccess = false;
  bool isLoginInterrupted = false;
  bool isLoading = false;
  bool isXummOpened = false;
  bool isXummInstalled = false;

  int retryCount = 0;
  int _consecutiveOpenedCount = 0;
  int currentPollingInterval = initialPollingInterval;

  String? requestId;
  String? qrImageUrl;
  String _lastPollingStatus = '';

  final Map<String, bool> _hasProcessedPayload = {};

  void Function(bool)? onLoadingChanged;
  void Function(bool)? onXummOpenedChanged;
  void Function(String)? onLoginSuccess;
  void Function()? onShowLoginInterruptError;
  void Function()? onShowXummTerminated;
  void Function(String)? onShowError;

  LoginController() {
    _setupMethodCallHandler();
    _initializeStateTracking();
  }

  void _initializeStateTracking() {
    _lastStateChangeTime = DateTime.now();
  }

  void _setupMethodCallHandler() {
    platform.setMethodCallHandler((call) async {
      final now = DateTime.now();

      if (_lastStateChangeTime != null &&
          now.difference(_lastStateChangeTime!) <
              const Duration(milliseconds: 500)) {
        return;
      }
      _lastStateChangeTime = now;

      switch (call.method) {
        case 'showLoginInterruptError':
          if (!isLoginInterrupted) {
            isLoginInterrupted = true;
            onShowLoginInterruptError?.call();
            await Future.delayed(const Duration(seconds: 2));
            isLoginInterrupted = false;
          }
          break;

        case 'showXummTerminatedDialog':
          await _xummService.closeXummAndSwitchToChat();
          cleanupLoginState();
          onShowXummTerminated?.call();
          break;

        case 'showErrorDialog':
          if (!isLoginInterrupted) {
            final String errorMessage = call.arguments as String;
            cleanupLoginState();
            onShowError?.call(errorMessage);
          }
          break;
      }
    });
  }

  Future<bool> checkXummInstallation() async {
    try {
      final uri = Uri.parse('xumm://');
      final canLaunch = await canLaunchUrl(uri);
      isXummInstalled = canLaunch;
      return canLaunch;
    } catch (e) {
      isXummInstalled = false;
      return false;
    }
  }

  Future<void> loginWithLocalXumm() async {
    if (isLoading) return;

    try {
      _setLoading(true);
      _setXummOpened(false);
      _resetLoginState();

      final isInstalled = await checkXummInstallation();
      if (!isInstalled) {
        throw Exception('XUMM is not installed');
      }

      final loginData = await _xummService.createLoginRequest();
      _validateLoginData(loginData);

      requestId = loginData['requestId'];

      final result = await platform.invokeMethod('openXummLogin', {
        'deepLink': loginData['deepLink'],
      });

      if (result == true) {
        _setXummOpened(true);
        startPolling();
      } else {
        throw Exception('Failed to launch XUMM');
      }
    } catch (e) {
      await handleLoginFailure('XUMM 앱을 실행할 수 없습니다. 다시 시도해주세요.');
    }
  }

  Future<void> loginWithQR() async {
    if (isLoading) return;

    try {
      _setLoading(true);
      _resetLoginState();

      final loginData = await _xummService.createLoginRequest();
      _validateLoginData(loginData);

      requestId = loginData['requestId'];
      qrImageUrl = loginData['qrUrl'];

      startPolling();
    } catch (e) {
      await handleLoginFailure('QR 코드 생성 중 오류가 발생했습니다.');
    } finally {
      _setLoading(false);
    }
  }

  void startPolling() {
    if (requestId == null) return;

    _timer?.cancel();
    _timeoutTimer?.cancel();
    retryCount = 0;
    _consecutiveOpenedCount = 0;
    _lastPollingStatus = '';
    _pollingStartTime = DateTime.now();

    _timeoutTimer = Timer(const Duration(seconds: maxPollingDuration), () {
      _handlePollingTimeout();
    });

    Timer(const Duration(seconds: warningThreshold), () {
      if (!_isCancelled && isXummOpened) {
        onShowError?.call('로그인 시간이 곧 만료됩니다. 15초 남았습니다.');
      }
    });

    _timer = Timer.periodic(Duration(milliseconds: currentPollingInterval),
        (timer) async {
      if (_isCancelled) {
        timer.cancel();
        return;
      }

      try {
        final status = await _xummService.checkSignInStatus(requestId!);
        if (status == null) {
          throw Exception('Null status received from XUMM service');
        }

        if (status['status'] != _lastPollingStatus) {
          _lastPollingStatus = status['status'];
        }

        switch (status['status']) {
          case 'opened':
            _handleOpenedStatus();
            break;

          case 'success':
            timer.cancel();
            final String? account = status['account'];
            if (account != null && account.isNotEmpty) {
              await _handleLoginSuccess(account);
            } else {
              throw Exception('Invalid account data received');
            }
            break;

          case 'cancelled':
          case 'expired':
          case 'error':
          case 'invalid':
          case 'user_cancelled':
          case 'server_error':
            timer.cancel();
            if (!isLoginInterrupted) {
              // print('XUMM Error Status: ${status['status']}'); // 상태 로그
              // print('XUMM Error Message: ${status['message']}'); // 메시지 로그
              // print('Full XUMM Response: $status'); // 전체 응답 로그
              await handleXummError(status['message'] ?? '알 수 없는 오류가 발생했습니다.');
            }
            break;
        }
      } catch (e) {
        retryCount++;
        if (retryCount >= 3) {
          timer.cancel();
          await handleLoginFailure('로그인 시도 중 오류가 발생했습니다.');
        }
      }
    });
  }

  void _handleOpenedStatus() {
    if (!isXummOpened) {
      _setXummOpened(true);
    }

    _consecutiveOpenedCount++;
    if (_consecutiveOpenedCount >= maxConsecutiveOpened) {
      currentPollingInterval =
          math.min(currentPollingInterval + 1000, maxPollingInterval);

      _timer?.cancel();
      startPolling();
    }
  }

  void _handlePollingTimeout() {
    _timer?.cancel();
    _timeoutTimer?.cancel();
    handleLoginFailure('로그인 시간이 만료되었습니다.');
  }

  void _validateLoginData(Map<String, dynamic>? loginData) {
    if (loginData == null) {
      throw Exception('Login data is null');
    }
    if (!loginData.containsKey('requestId') ||
        !loginData.containsKey('deepLink')) {
      throw Exception('Invalid login data structure');
    }
  }

  void _resetLoginState() {
    isLoginInterrupted = false;
    _isCancelled = false;
    _isProcessingSuccess = false;
    _hasProcessedPayload.clear();
    currentPollingInterval = initialPollingInterval;
    _consecutiveOpenedCount = 0;
    _lastPollingStatus = '';
  }

  Future<void> _handleLoginSuccess(String account) async {
    if (_isProcessingSuccess || _hasProcessedPayload[requestId] == true) return;
    try {
      // if (_isProcessingSuccess) return;
      // if (_hasProcessedPayload[requestId] == true) return;

      _isProcessingSuccess = true;
      _hasProcessedPayload[requestId!] = true;
      await Future.wait(
          [_userSession.clear(), _userSession.setXummAddress(account)]);
      onLoginSuccess?.call(account);
      await platform.invokeMethod('handleLoginSuccess');
    } catch (e) {
      onShowError?.call('로그인 처리 중 오류가 발생했습니다. 다시 시도해주세요.');
    } finally {
      cleanupLoginState();
    }
  }

  Future<void> handleLoginFailure(String errorMessage) async {
    try {
      await _xummService.closeXummAndSwitchToChat();
      cleanupLoginState();
      onShowError?.call(errorMessage);
    } catch (e) {}
  }

  Future<void> handleXummError(String errorMessage) async {
    try {
      await _xummService.closeXummAndSwitchToChat();
      cleanupLoginState();
      onShowError?.call(errorMessage);
    } catch (e) {}
  }

  void cleanupLoginState() {
    cleanupTimers();
    _setLoading(false);
    _setXummOpened(false);
    isLoginInterrupted = false;
    qrImageUrl = null;
    _isCancelled = true;
    _isProcessingSuccess = false;
    _hasProcessedPayload.clear();
    currentPollingInterval = initialPollingInterval;
    _consecutiveOpenedCount = 0;
    _lastPollingStatus = '';

    try {
      platform.invokeMethod('resetXummState');
    } catch (e) {}
  }

  void cleanupTimers() {
    _timer?.cancel();
    _preAuthTimer?.cancel();
    _xummLaunchTimer?.cancel();
    _timeoutTimer?.cancel();
    _timer = null;
    _preAuthTimer = null;
    _xummLaunchTimer = null;
    _timeoutTimer = null;
  }

  void _setLoading(bool value) {
    if (isLoading != value) {
      isLoading = value;
      onLoadingChanged?.call(value);
    }
  }

  void _setXummOpened(bool value) {
    if (isXummOpened != value) {
      isXummOpened = value;
      onXummOpenedChanged?.call(value);
    }
  }

  void dispose() {
    cleanupTimers();
  }
}
