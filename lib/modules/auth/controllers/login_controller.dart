// lib/presentation/controller/login_controller.dart

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/services.dart';
// import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import '../../../services/xumm_service.dart';
import '../../../services/supabase_service.dart';
import '../../../core/session/user_session.dart';
import '../../home/home_screen.dart';
import '../views/onboarding_screen.dart';
// import '../../widgets/loading/loading_screen.dart';
// import '../../home/controllers/home_controller.dart';
import 'dart:developer' as developer;

enum LoginState { idle, loading, opened, success, failed, cancelled, timeout }

class LoginController extends GetxController {
  final XummService _xummService = XummService();
  final _userSession = UserSession();
  static const platform = MethodChannel('com.example.xsium_chat/app_lifecycle');
  final _uiState = RxMap<String, dynamic>({
    'isLoading': false,
  });

  // 상태 관리 최적화: Rx 변수로 변경
  final _currentState = LoginState.idle.obs;
  final _isXummOpened = false.obs;
  final _isLoginInterrupted = false.obs;
  final _isXummInstalled = false.obs;
  final _qrImageUrl = RxString('');
  // String? get qrImageUrl => _qrImageUrl.value;
  final _requestId = RxString('');
  final _isProcessingSuccess = false.obs;

  // Getters
  bool get isLoading => _currentState.value == LoginState.loading;
  bool get isXummOpened => _isXummOpened.value;
  bool get isLoginInterrupted => _isLoginInterrupted.value;
  bool get isXummInstalled => _isXummInstalled.value;
  String? get qrImageUrl =>
      _qrImageUrl.value.isEmpty ? null : _qrImageUrl.value;
  String? get requestId => _requestId.value.isEmpty ? null : _requestId.value;

  // 타이머 관리
  Timer? _timer;
  Timer? _preAuthTimer;
  Timer? _xummLaunchTimer;
  Timer? _timeoutTimer;

  // 성능 최적화: 상태 변경 감지를 위한 workers
  late Worker _stateWorker;
  late Worker _xummOpenedWorker;

  // 상수
  static const int maxPollingDuration = 60;
  static const int warningThreshold = 45;
  static const int initialPollingInterval = 2000;
  static const int maxPollingInterval = 5000;
  static const int maxConsecutiveOpened = 5;
  static const Duration _cacheDuration = Duration(milliseconds: 500);

  // 메모리 최적화: 캐시 관리
  final Map<String, dynamic> _statusCache = {};
  DateTime? _lastStatusCheck;
  DateTime? _lastStateChangeTime;
  int retryCount = 0;
  int _consecutiveOpenedCount = 0;
  int currentPollingInterval = initialPollingInterval;
  String _lastPollingStatus = '';
  final Map<String, bool> _hasProcessedPayload = {};

  // 콜백
  void Function(bool)? onLoadingChanged;
  void Function(bool)? onXummOpenedChanged;
  void Function(String)? onLoginSuccess;
  void Function()? onShowLoginInterruptError;
  void Function()? onShowXummTerminated;
  void Function(String)? onShowError;

  @override
  void onInit() {
    super.onInit();
    _setupWorkers();
    _setupMethodCallHandler();
    _initializeStateTracking();
  }

  void _setupWorkers() {
    _stateWorker = ever(_currentState, (LoginState state) {
      developer.log('Login state changed to: $state');
      onLoadingChanged?.call(state == LoginState.loading); // 직접 호출
    });

    _xummOpenedWorker = ever(_isXummOpened, (bool opened) {
      developer.log('XUMM opened state changed to: $opened');
      if (opened) {
        _setLoginState(LoginState.opened); // opened 상태일 때 로딩 해제
      }
      onXummOpenedChanged?.call(opened);
    });
  }

  void _initializeStateTracking() {
    _lastStateChangeTime = DateTime.now();
    developer.log('State tracking initialized');
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

      developer.log('Method call received: ${call.method}');
      switch (call.method) {
        case 'showLoginInterruptError':
          if (!_isLoginInterrupted.value) {
            _isLoginInterrupted.value = true;
            onShowLoginInterruptError?.call();
            await Future.delayed(const Duration(seconds: 2));
            _isLoginInterrupted.value = false;
          }
          break;

        case 'showXummTerminatedDialog':
          await _xummService.closeXummAndSwitchToChat();
          cleanupLoginState();
          onShowXummTerminated?.call();
          break;

        case 'showErrorDialog':
          if (!_isLoginInterrupted.value) {
            final String errorMessage = call.arguments as String;
            cleanupLoginState();
            onShowError?.call(errorMessage.tr);
          }
          break;
        case 'showXummError': // 추가된 부분
          if (!_isLoginInterrupted.value) {
            final String errorMessage = call.arguments as String;
            await _xummService.closeXummAndSwitchToChat(); // 추가
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
      _isXummInstalled.value = canLaunch;
      developer.log('XUMM installation check: $canLaunch');
      return canLaunch;
    } catch (e) {
      developer.log('Error checking XUMM installation: $e');
      _isXummInstalled.value = false;
      return false;
    }
  }

  Future<void> loginWithLocalXumm() async {
    if (_currentState.value == LoginState.loading) {
      developer.log('Login already in progress, ignoring request');
      return;
    }

    try {
      developer.log('Starting local XUMM login process...');
      _setLoginState(LoginState.loading);
      _setXummOpened(false);

      if (!_isXummInstalled.value) {
        developer.log('XUMM not installed');
        throw Exception('xumm_not_installed'.tr);
      }

      developer.log('Creating login request...');
      final loginData = await _xummService.createLoginRequest();
      _validateLoginData(loginData);

      final requestId = loginData['requestId']?.toString();
      final deepLink = loginData['deepLink']?.toString();

      if (requestId == null || deepLink == null) {
        developer.log('Invalid login data received');
        throw Exception('invalid_login_data'.tr);
      }

      developer.log('Launching XUMM with deepLink: $deepLink');
      try {
        final success = await platform
            .invokeMethod('openXummLogin', {'deepLink': deepLink});
        if (!success) throw Exception('Native launch failed');
      } catch (e) {
        developer.log('Platform channel failed, trying URL launcher');
        final uri = Uri.parse(deepLink);
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          throw Exception('xumm_cannot_launch'.tr);
        }
      }

      _requestId.value = requestId;
      _setXummOpened(true);
      startPolling();
    } catch (e) {
      developer.log('Login error occurred: $e');
      _setLoginState(LoginState.failed);
      await handleLoginFailure('xumm_cannot_launch'.tr);
    }
  }

  Future<void> loginWithQR() async {
    if (_currentState.value == LoginState.loading) {
      developer.log('QR login already in progress, ignoring request');
      return;
    }

    developer.log('Starting QR login process...');
    _resetLoginState();
    try {
      final loginData =
          await _xummService.createLoginRequest(); // launchDeepLink 파라미터 제거
      _validateLoginData(loginData);

      final requestId = loginData['requestId']?.toString();
      final qrUrl = loginData['qrUrl']?.toString();

      if (requestId == null || qrUrl == null) {
        developer.log('Invalid QR login data received');
        throw Exception('invalid_login_data'.tr);
      }

      _requestId.value = requestId;
      _qrImageUrl.value = qrUrl;

      startPolling();
    } catch (e) {
      developer.log('QR login error occurred: $e');
      await handleLoginFailure('qr_code_error'.tr);
    } finally {
      if (_currentState.value == LoginState.loading) {
        _setLoginState(LoginState.idle);
      }
    }
  }

  void startPolling() {
    if (_requestId.value.isEmpty) {
      developer.log('Cannot start polling: requestId is empty');
      return;
    }

    developer.log('Starting polling for requestId: ${_requestId.value}');
    _timer?.cancel();
    _timeoutTimer?.cancel();
    retryCount = 0;
    _consecutiveOpenedCount = 0;
    _lastPollingStatus = '';

    _timeoutTimer = Timer(const Duration(seconds: maxPollingDuration), () {
      developer.log('Polling timeout reached');
      handleLoginFailure('login_expired'.tr);
    });

    Timer(const Duration(seconds: warningThreshold), () {
      if (_currentState.value == LoginState.opened) {
        developer.log('Warning threshold reached');
        onShowError?.call('login_expiry_warning'.tr);
      }
    });

    _timer = Timer.periodic(
      Duration(milliseconds: currentPollingInterval),
      (timer) => _pollLoginStatus(timer),
    );
  }

  Future<void> _pollLoginStatus(Timer timer) async {
    if (_currentState.value == LoginState.cancelled) {
      developer.log('Polling cancelled');
      timer.cancel();
      return;
    }

    try {
      final now = DateTime.now();
      if (_lastStatusCheck != null &&
          now.difference(_lastStatusCheck!) < _cacheDuration) {
        return;
      }
      _lastStatusCheck = now;

      developer.log('Checking sign-in status...');
      final status = await _xummService.checkSignInStatus(_requestId.value);

      if (status == null) {
        throw Exception('null_status_received'.tr);
      }

      _statusCache[_requestId.value] = status;

      if (status['status'] != _lastPollingStatus) {
        _lastPollingStatus = status['status'];
        developer.log('Status changed to: ${status['status']}');
        await _handleStatusChange(status);
      }
    } catch (e) {
      developer.log('Polling error: $e');
      retryCount++;
      if (retryCount >= 3) {
        developer.log('Max retry count reached');
        timer.cancel();
        await handleLoginFailure('login_attempt_error'.tr);
      }
    }
  }

  Future<void> _handleStatusChange(Map<String, dynamic> status) async {
    developer.log('Handling status change: ${status['status']}');
    switch (status['status']) {
      case 'opened':
        _handleOpenedStatus();
        break;
      case 'success':
        final String? account = status['account'];
        final String? userToken = status['userToken'];

        if (account != null && account.isNotEmpty) {
          await handleLoginSuccess(account, userToken);
        } else {
          throw Exception('invalid_account_data'.tr);
        }
        break;
      case 'cancelled':
      case 'expired':
      case 'error':
      case 'invalid':
      case 'user_cancelled':
      case 'server_error':
        if (!_isLoginInterrupted.value) {
          // 모든 타이머 취소

          // await platform.invokeMethod(
          //     'handleXummError', status['message'] ?? 'unknown_error'.tr);
          await handleXummError(status['message'] ?? 'unknown_error'.tr);

          // 상태 정리
          cleanupLoginState();
        }
        break;
    }
  }

  void _handleOpenedStatus() {
    if (!_isXummOpened.value) {
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

  Future<void> handleLoginSuccess(String account, String? userToken) async {
    if (_isProcessingSuccess.value ||
        _hasProcessedPayload[_requestId.value] == true) {
      return;
    }

    try {
      _isProcessingSuccess.value = true;
      _hasProcessedPayload[_requestId.value] = true;

      developer.log(
          'Processing login success with account: $account, userToken: $userToken');

      // 1. 모든 작업을 먼저 완료
      await Future.wait([
        _userSession.clear(),
        platform.invokeMethod('handleLoginSuccess'),
      ]);

      // 2. Supabase users 체크
      try {
        final existingUser = await SupabaseService.instance
            .from('users')
            .select()
            .eq('xumm_address', account)
            .single();

        // 유저 정보가 있으면 UserSession 초기화
        if (existingUser != null) {
          await _userSession.initializeUserData(
            address: account,
            displayName: existingUser['display_name'],
            avatarUrl: existingUser['avatar_url'],
          );
        }

        // 3. cleanup 수행
        cleanupLoginState();

        // 4. 한번에 화면 전환
        Get.offAll(
          () => existingUser != null
              ? HomeScreen(userAddress: account)
              : OnboardingScreen(
                  userAddress: account,
                  userToken: userToken ?? '',
                ),
          transition: Transition.noTransition,
          duration: Duration.zero,
        );
      } catch (e) {
        // users 테이블에서 유저를 찾지 못한 경우
        await _userSession.initializeUserData(address: account); // 기본 정보만 초기화
        cleanupLoginState();
        Get.offAll(
          () => OnboardingScreen(
            userAddress: account,
            userToken: userToken ?? '',
          ),
          transition: Transition.noTransition,
          duration: Duration.zero,
        );
      }
    } catch (e) {
      developer.log('Error handling login success: $e');
      onShowError?.call('login_processing_error'.tr);
    }
  }

  Future<void> _performBackgroundTasks(String account) async {
    try {
      // 병렬로 처리하되 실패해도 계속 진행
      await Future.wait([
        _userSession
            .clear()
            .catchError((e) => developer.log('Error clearing session: $e')),
        _userSession
            .setXummAddress(account)
            .catchError((e) => developer.log('Error setting address: $e')),
        platform
            .invokeMethod('handleLoginSuccess')
            .catchError((e) => developer.log('Error handling success: $e')),
      ], eagerError: false);
    } finally {
      cleanupLoginState();
    }
  }

  Future<void> handleLoginFailure(String errorMessage) async {
    try {
      developer.log('Handling login failure: $errorMessage');
      await _xummService.closeXummAndSwitchToChat();
      cleanupLoginState();
      onShowError?.call(errorMessage);
    } catch (e) {
      developer.log('Error handling login failure: $e');
    }
  }

  Future<void> handleXummError(String errorMessage) async {
    try {
      developer.log('Handling XUMM error: $errorMessage');
      _setLoginState(LoginState.failed);
      _timer?.cancel();
      _timeoutTimer?.cancel();
      _timer = null;
      _timeoutTimer = null;

      // 에러 메시지와 함께 네이티브 메서드 호출
      try {
        await platform.invokeMethod('handleXummError', errorMessage);
      } catch (e) {
        developer.log('Error invoking handleXummError: $e');
      }

      cleanupLoginState();

      if (!_isLoginInterrupted.value) {
        onShowError?.call(errorMessage);
      }
    } catch (e) {
      developer.log('Error handling XUMM error: $e');
    }
  }

  void _validateLoginData(Map<String, dynamic>? loginData) {
    if (loginData == null) {
      throw Exception('login_data_null'.tr);
    }

    final requestId = loginData['requestId']?.toString();
    final deepLink = loginData['deepLink']?.toString();

    if (requestId == null || deepLink == null) {
      throw Exception('invalid_login_data_structure'.tr);
    }
  }

  void _setLoginState(LoginState newState) {
    if (_currentState.value == newState) return;
    _currentState.value = newState;
    _uiState['isLoading'] = (newState == LoginState.loading);
    developer.log('Login state set to: $newState');
  }

  void _setXummOpened(bool value) {
    if (_isXummOpened.value != value) {
      developer.log('Setting XUMM opened state to: $value');
      _isXummOpened.value = value;
      if (value) {
        _currentState.value = LoginState.opened;
      }
    }
  }

  void _resetLoginState() {
    developer.log('Resetting login state');
    _isLoginInterrupted.value = false;
    // _currentState.value = LoginState.idle;
    _isProcessingSuccess.value = false;
    _hasProcessedPayload.clear();
    currentPollingInterval = initialPollingInterval;
    _consecutiveOpenedCount = 0;
    _lastPollingStatus = '';
    _statusCache.clear();
    _lastStatusCheck = null;
  }

  void cleanupLoginState() {
    developer.log('Cleaning up login state');
    // 타이머 정리
    _timer?.cancel();
    _preAuthTimer?.cancel();
    _xummLaunchTimer?.cancel();
    _timeoutTimer?.cancel();
    _timer = null;
    _preAuthTimer = null;
    _xummLaunchTimer = null;
    _timeoutTimer = null;

    // 상태 초기화
    _setLoginState(LoginState.idle);
    _setXummOpened(false);
    _isLoginInterrupted.value = false;
    _qrImageUrl.value = '';
    _isProcessingSuccess.value = false;
    _hasProcessedPayload.clear();

    // 폴링 관련 상태 초기화
    currentPollingInterval = initialPollingInterval;
    _consecutiveOpenedCount = 0;
    _lastPollingStatus = '';
    _statusCache.clear();
    _lastStatusCheck = null;

    try {
      platform.invokeMethod('resetXummState');
    } catch (e) {
      developer.log('Error resetting XUMM state: $e', error: e);
    }
  }

  @override
  void onClose() {
    developer.log('Disposing LoginController');
    _stateWorker.dispose();
    _xummOpenedWorker.dispose();
    cleanupLoginState();
    super.onClose();
  }
}
