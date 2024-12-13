// lib/core/session/user_session.dart
import 'dart:developer' as developer;

class UserSession {
  // 싱글톤 인스턴스
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;
  UserSession._internal();

  // 메모리 내 데이터 저장
  String? _xummAddress;
  String? _displayName;
  String? _avatarUrl;
  DateTime? _lastLoginTime;
  bool _isInitialized = false;

  // 추가: 세션 상태 관리 변수
  bool _isClearing = false;
  DateTime? _lastStateCheck;
  bool _wasValidLastCheck = true;
  static const sessionTimeout = Duration(hours: 1);

  // getter 추가
  String? get displayName => _displayName;
  String? get avatarUrl => _avatarUrl;

  // XUMM 주소와 함께 사용자 정보 설정
  Future<void> initializeUserData({
    required String address,
    String? displayName,
    String? avatarUrl,
  }) async {
    try {
      // 이전 세션 정리
      if (_xummAddress != null && _xummAddress != address) {
        await clear();
      }

      _xummAddress = address;
      _displayName = displayName ?? address.substring(0, 8);
      _avatarUrl = avatarUrl;
      _lastLoginTime = DateTime.now();
      _isInitialized = true;
      _wasValidLastCheck = true;

      developer
          .log('UserSession: Successfully initialized user data in memory');
      _validateState();
    } catch (e) {
      developer.log('Error saving user session: $e');
      rethrow;
    }
  }

  // XUMM 주소 설정 - 기존 메서드는 하위 호환성을 위해 유지
  Future<void> setXummAddress(String address) async {
    await initializeUserData(address: address);
  }

  // XUMM 주소 가져오기
  String? getXummAddress() {
    _validateState();
    return _xummAddress;
  }

  // 로그인 여부 확인
  bool get isLoggedIn {
    _validateState();
    return _xummAddress != null && _isInitialized && !_isClearing;
  }

  // 마지막 로그인 시간 가져오기
  DateTime? getLastLoginTime() {
    _validateState();
    return _lastLoginTime;
  }

  // 세션 상태 검증
  void _validateState() {
    final now = DateTime.now();

    // 상태 체크 최적화 (너무 잦은 체크 방지)
    if (_lastStateCheck != null &&
        now.difference(_lastStateCheck!) < const Duration(seconds: 1)) {
      return;
    }
    _lastStateCheck = now;

    // 세션 타임아웃 체크
    if (_lastLoginTime != null) {
      final timeSinceLogin = now.difference(_lastLoginTime!);
      if (timeSinceLogin > sessionTimeout) {
        developer.log('Session timeout detected');
        _clearInternalState();
        _wasValidLastCheck = false;
        return;
      }
    }

    // 상태 일관성 체크
    if (_xummAddress == null && _isInitialized) {
      developer.log('Inconsistent session state detected');
      _clearInternalState();
      _wasValidLastCheck = false;
      return;
    }

    _wasValidLastCheck = true;
  }

  // 세션 초기화
  Future<void> initialize() async {
    try {
      if (!_isInitialized && !_isClearing) {
        _isInitialized = true;
        _lastStateCheck = DateTime.now();
        developer.log('UserSession initialized in memory');
      }
    } catch (e) {
      developer.log('Error initializing user session: $e');
      rethrow;
    }
  }

  // 세션 클리어
  Future<void> clear() async {
    if (_isClearing) {
      developer.log('Clear already in progress');
      return;
    }

    try {
      _isClearing = true;
      await _clearInternalState();
      developer.log('UserSession cleared from memory');
    } catch (e) {
      developer.log('Error clearing user session: $e');
      rethrow;
    } finally {
      _isClearing = false;
    }
  }

  // 내부 상태 클리어
  Future<void> _clearInternalState() async {
    _xummAddress = null;
    _displayName = null;
    _avatarUrl = null;
    _lastLoginTime = null;
    _isInitialized = false;
    _lastStateCheck = null;
    _wasValidLastCheck = true;
  }

  // 세션 상태 확인
  Map<String, dynamic> getSessionState() {
    _validateState();
    return {
      'isLoggedIn': isLoggedIn,
      'xummAddress': _xummAddress,
      'displayName': _displayName,
      'avatarUrl': _avatarUrl,
      'lastLoginTime': _lastLoginTime?.toIso8601String(),
      'isValid': _wasValidLastCheck,
      'isClearing': _isClearing,
    };
  }

  // 앱이 백그라운드로 갈 때 호출
  void onAppBackground() {
    developer.log('App entering background, validating session state');
    _validateState();
    if (!_wasValidLastCheck) {
      _clearInternalState();
    }
  }

  // 앱이 포그라운드로 돌아올 때 호출
  Future<void> onAppForeground() async {
    developer.log('App returning to foreground, checking session');
    _validateState();
    if (!_wasValidLastCheck) {
      await clear();
      developer.log('Session cleared due to invalid state on foreground');
    }
  }

  // 세션 유효성 검사
  bool validateSession() {
    if (!isLoggedIn || _xummAddress == null) {
      developer.log('Session validation failed: not logged in or no address');
      return false;
    }

    if (_lastLoginTime == null) {
      developer.log('Session validation failed: no login time');
      return false;
    }

    final now = DateTime.now();
    if (now.difference(_lastLoginTime!) > const Duration(minutes: 5)) {
      developer.log('Session validation failed: session timeout');
      return false;
    }

    return true;
  }

  // 세션 갱신
  Future<void> refreshSession() async {
    if (!isLoggedIn) return;

    try {
      _lastLoginTime = DateTime.now();
      _validateState();
      developer.log('Session refreshed');
    } catch (e) {
      developer.log('Error refreshing session: $e');
      await clear();
    }
  }

  // 강제 세션 종료
  Future<void> forceLogout() async {
    developer.log('Force logout requested');
    await clear();
  }
}
