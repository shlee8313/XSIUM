// lib/modules/auth/controllers/onboarding_controller.dart

import 'dart:async';

import 'package:get/get.dart';
import '../../../services/supabase_service.dart';
import '../../home/home_screen.dart';
import '../../../core/session/user_session.dart';
import 'dart:developer' as developer;

class OnboardingController extends GetxController {
  final _userSession = UserSession(); // <- 추가
  final displayName = ''.obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final selectedAvatarIndex = 0.obs;
  final isCheckingName = false.obs; // 이름 체크 중 상태
  Timer? _debounceTimer; // 디바운스 타이머
  // 생명주기 관리를 위한 변수 추가
  bool _disposed = false; // 컨트롤러 dispose 상태 추적

  final defaultAvatars = [
    'assets/images/avatars/avatar.png',
    'assets/images/avatars/1.png',
    'assets/images/avatars/2.png',
    'assets/images/avatars/3.png',
    'assets/images/avatars/4.png',
    'assets/images/avatars/5.png',
    'assets/images/avatars/6.png',
    'assets/images/avatars/7.png',
    'assets/images/avatars/8.png',
    'assets/images/avatars/9.png',
  ];

  @override
  void onInit() {
    super.onInit();
    // 초기화 시 상태 리셋
    _disposed = false;
  }

  @override
  void onClose() {
    _disposed = true;
    _debounceTimer?.cancel();
    super.onClose();
  }

  String get selectedAvatarPath => defaultAvatars[selectedAvatarIndex.value];

  Future<void> selectDefaultAvatar(int index) async {
    selectedAvatarIndex.value = index;
  }

  // 디스플레이 이름 유효성 검사 및 중복 체크
  // String get selectedAvatarPath => defaultAvatars[selectedAvatarIndex.value];

  Future<void> checkDisplayName(String value) async {
    if (_disposed) return;
    _debounceTimer?.cancel();

    if (value.isEmpty) {
      errorMessage.value = null;
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (_disposed) return;

      try {
        isCheckingName.value = true;

        // 영문, 숫자만 허용하는 정규식 추가
        final RegExp validCharacters = RegExp(r'^[a-zA-Z0-9]+$');
        if (!validCharacters.hasMatch(value)) {
          errorMessage.value = 'only_english_allowed'.tr;
          return;
        }
        // 기본 유효성 검사
        if (value.length < 5) {
          errorMessage.value = 'name_min_length'.tr;
          return;
        }

        if (value.length > 40) {
          errorMessage.value = 'name_max_length'.tr;
          return;
        }

        // users 테이블에서 대소문자 구분 없이 중복 체크
        // ilike 연산자를 사용하여 대소문자 구분 없이 검색
        final response = await SupabaseService.instance
            .from('users')
            .select('display_name')
            .ilike('display_name', value.trim())
            .maybeSingle();

        if (!_disposed) {
          if (response != null) {
            errorMessage.value = 'name_already_in_use'.tr;
          } else {
            errorMessage.value = null;
          }
        }
      } catch (e) {
        developer.log('Error checking display name: $e');
        if (!_disposed) {
          errorMessage.value = 'error_checking_name'.tr;
        }
      } finally {
        if (!_disposed) {
          isCheckingName.value = false;
        }
      }
    });
  }

  Future<void> saveUsers(String xummAddress, String xummUuid) async {
    if (_disposed || isCheckingName.value) return;

    if (displayName.value.trim().isEmpty) {
      errorMessage.value = 'enter_display_name'.tr;
      return;
    }

    if (errorMessage.value != null) return;

    try {
      isLoading.value = true;

      // users 테이블에서 대소문자 구분 없이 최종 중복 체크
      final existingName = await SupabaseService.instance
          .from('users')
          .select('display_name')
          .ilike('display_name', displayName.value.trim())
          .maybeSingle();

      if (_disposed) return;

      if (existingName != null) {
        errorMessage.value = 'name_already_in_use'.tr;
        return;
      }

      final success = await SupabaseService.createUser(
        displayName: displayName.value.trim(),
        xummAddress: xummAddress,
        xummUuid: xummUuid,
        avatarPath: selectedAvatarPath,
      );

      if (_disposed) return;

      if (success) {
        // Get.find 대신 직접 인스턴스 사용
        await _userSession.initializeUserData(
          address: xummAddress,
          displayName: displayName.value.trim(),
          avatarUrl: selectedAvatarPath, // avatarUrl도 함께 저장
        );
        Get.offAll(
          () => HomeScreen(userAddress: xummAddress),
          transition: Transition.noTransition,
          duration: Duration.zero,
        );
      } else {
        errorMessage.value = 'create_user_failed'.tr;
      }
    } catch (e) {
      developer.log('Error in saveProfile:', error: e);
      if (!_disposed) {
        errorMessage.value = 'unexpected_error'.tr;
      }
    } finally {
      if (!_disposed) {
        isLoading.value = false;
      }
    }
  }

  void cleanupState() {
    if (_disposed) return;

    // 상태 초기화
    _debounceTimer?.cancel();
    isLoading.value = false;
    isCheckingName.value = false;
    displayName.value = '';
    errorMessage.value = null;
    selectedAvatarIndex.value = 0;
  }

  void setLoading(bool value) {
    isLoading.value = value;
  }

  void setError(String? message) {
    errorMessage.value = message;
  }
}
