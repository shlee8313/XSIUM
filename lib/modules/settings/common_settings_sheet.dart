// lib\modules\settings\common_settings_sheet.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/theme_controller.dart';
import '../coins/coin_balance_widget.dart';
import '../../core/session/user_session.dart';
import '../auth/views/login_screen.dart';
import '../widgets/avartar/avatar.dart';

class CommonSettingsSheet extends StatelessWidget {
  const CommonSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeController = Get.find<ThemeController>();

    return Scaffold(
      backgroundColor: Colors.black.withAlpha(128),
      body: Column(
        children: [
          // 상단 설정 영역
          Container(
            color: theme.colorScheme.surface,
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 헤더
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Avatar(),

                        Text(
                          "홍길동",
                          style: TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 40), // 빈 공간
                        const CoinBalanceWidget(),
                      ],
                    ),
                  ),
                  // const Divider(height: 1, thickness: 1),
                  // 설정 항목
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildSettingsTile(
                          context,
                          icon: Obx(() => Icon(
                                themeController.isDarkMode.value
                                    ? Icons.light_mode
                                    : Icons.dark_mode,
                              )),
                          title: '테마 설정',
                          onTap: themeController.toggleTheme,
                        ),
                        // const Divider(height: 1, thickness: 1),
                        _buildSettingsTile(
                          context,
                          icon: const Icon(Icons.logout, color: Colors.red),
                          title: '로그아웃',
                          titleStyle: const TextStyle(color: Colors.red),
                          onTap: () => _handleLogout(context),
                        ),
                        // const Divider(height: 1, thickness: 1),
                        _buildSettingsTile(
                          context,
                          icon: const Icon(Icons.security),
                          title: '보안 설정',
                          onTap: () {
                            // 보안 설정 화면으로 이동
                          },
                        ),
                        // const Divider(height: 1, thickness: 1),
                        _buildSettingsTile(
                          context,
                          icon: const Icon(Icons.help_outline),
                          title: '도움말',
                          onTap: () {
                            // 도움말 화면으로 이동
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required Widget icon,
    required String title,
    TextStyle? titleStyle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: icon,
      title: Text(title, style: titleStyle ?? const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final themeController = Get.find<ThemeController>();
    final userSession = UserSession();

    // 로그아웃 확인 다이얼로그 표시
    bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            '로그아웃',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            '정말 로그아웃 하시겠습니까?',
            style: TextStyle(
              fontSize: 16.0,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('로그아웃'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    try {
      // 로딩 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // 세션 클리어
      await userSession.clear();

      // 로그인 화면으로 이동
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그아웃 중 오류가 발생했습니다. 다시 시도해주세요.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
