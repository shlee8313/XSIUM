// lib/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:async'; // 추가: Timer를 위한 import
import 'dart:developer' as developer;
import '../../../core/session/user_session.dart';
import '../auth/views/login_screen.dart';
// import 'dart:math';
import 'package:get/get.dart';
import '../../../core/controllers/theme_controller.dart';
// import '../coins/coin_balance_widget.dart';
import '../tabs/friends_tab.dart';
import '../tabs/chats_tab.dart';
import '../tabs/canvas_tab.dart';
import '../tabs/invites_tab.dart';
// import 'components/security_banner.dart';
import '../widgets/badges/new_requests_badge.dart';
// import '../settings/chat_room_settings_sheet.dart';
import '../settings/common_app_bar.dart';
import '../../../config/theme.dart';

class HomeScreen extends StatefulWidget {
  final String userAddress;

  const HomeScreen({
    super.key,
    required this.userAddress,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final themeController = Get.find<ThemeController>();
  final _userSession = UserSession();
  bool _isReady = false;
  bool _isLoggingOut = false;
  bool _isSessionValid = true;
  Timer? _sessionCheckTimer;
  int _currentIndex = 0;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _prepareScreen();
    if (mounted) {
      _startSessionCheck();
      _userSession.refreshSession();
    }

    // Initialize pages
    _pages.addAll([
      FriendsTab(userAddress: widget.userAddress),
      const ChatsTab(),
      const CanvasTab(),
      const InvitesTab(),
    ]);
  }

  @override
  void dispose() {
    // [수정 2] Timer 정리
    _sessionCheckTimer?.cancel();
    _sessionCheckTimer = null;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _prepareScreen() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() => _isReady = true);
      }
    } catch (e) {
      developer.log('Error preparing home screen: $e');
    }
  }

  // 추가: 세션 체크 타이머 시작
  // [수정 3] 세션 체크 타이머 로직 개선
  void _startSessionCheck() {
    _sessionCheckTimer?.cancel();
    _sessionCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      // mounted 체크 추가
      if (!mounted) {
        timer.cancel();
        return;
      }
      _validateSession();
    });
  }

  // 추가: 세션 유효성 검사
  Future<void> _validateSession() async {
    if (!mounted) return;

    final isValid = _userSession.validateSession();
    if (!isValid && mounted) {
      setState(() => _isSessionValid = false);
      await _handleLogout();
    }
  }

  // 수정: 로그아웃 처리 개선
  Future<void> _handleLogout() async {
    if (_isLoggingOut || !mounted) return;

    try {
      setState(() => _isLoggingOut = true);
      final wasSessionValid = _isSessionValid;

      // Timer 정리
      _sessionCheckTimer?.cancel();
      _sessionCheckTimer = null;

      // 세션 클리어
      await _userSession.clear();

      if (!mounted) return;

      await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (route) => false,
      );

      if (!wasSessionValid && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('세션이 만료되었습니다. 다시 로그인해주세요.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      developer.log('Error during logout: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그아웃 중 오류가 발생했습니다.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  Future<bool> _onWillPop() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: colorScheme.surface,
            title: Text(
              '앱 종료',
              style: theme.textTheme.titleLarge,
            ),
            content: Text(
              '앱을 종료하시겠습니까?',
              style: theme.textTheme.bodyLarge,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  '취소',
                  style: TextStyle(color: colorScheme.primary),
                ),
              ),
              TextButton(
                onPressed: () async {
                  // 세션 정리
                  await _userSession.clear();
                  _sessionCheckTimer?.cancel();

                  // 로그인 화면으로 이동
                  if (context.mounted) {
                    await Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
                child: Text(
                  '종료',
                  style: TextStyle(color: colorScheme.primary),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        },
        child: GestureDetector(
          onTapDown: (_) => _userSession.refreshSession(),
          onPanDown: (_) => _userSession.refreshSession(),
          child: Scaffold(
            backgroundColor: theme.colorScheme.surface,
            appBar: CommonAppBar(title: 'Xsium'),

            // appBar: AppBar(
            //   title: const Text('Xsium'),
            //   backgroundColor: theme.colorScheme.surface,
            //   actions: [
            //     CoinBalanceWidget(),
            //     IconButton(
            //       icon: Icon(
            //         themeController.isDarkMode.value
            //             ? Icons.light_mode
            //             : Icons.dark_mode,
            //         color: theme.colorScheme.onSurface,
            //       ),
            //       onPressed: () => themeController.toggleTheme(),
            //     ),
            //     IconButton(
            //       icon: Icon(
            //         Icons.logout,
            //         color: theme.colorScheme.onSurface,
            //       ),
            //       onPressed: _isLoggingOut ? null : _handleLogout,
            //     ),
            //   ],
            // ),
            body: AnimatedOpacity(
              opacity: _isReady ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: SafeArea(
                child: Column(
                  children: [
                    // const SecurityBanner(),
                    Expanded(
                      child: _pages[_currentIndex],
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Theme(
              data: Theme.of(context).copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                backgroundColor: theme.colorScheme.surface,
                height: 60,
                indicatorColor: Colors.transparent,
                shadowColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: [
                  NavigationDestination(
                    icon: Icon(
                      _currentIndex == 0 ? Icons.people : Icons.people_outline,
                      color: _currentIndex == 0
                          ? themeController.isDarkMode.value
                              ? AppColors.primaryDark
                              : AppColors.primaryLight
                          : null,
                    ),
                    label: 'Friends',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      _currentIndex == 1 ? Icons.sms : Icons.sms_outlined,
                      color: _currentIndex == 1
                          ? themeController.isDarkMode.value
                              ? AppColors.primaryDark
                              : AppColors.primaryLight
                          : null,
                    ),
                    label: 'Chats',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      _currentIndex == 2
                          ? Icons.palette
                          : Icons.palette_outlined,
                      color: _currentIndex == 2
                          ? themeController.isDarkMode.value
                              ? AppColors.primaryDark
                              : AppColors.primaryLight
                          : null,
                    ),
                    label: 'Canvas',
                  ),
                  NavigationDestination(
                    icon: Stack(
                      children: [
                        Icon(
                          _currentIndex == 3
                              ? Icons.person_add
                              : Icons.person_add_outlined,
                          color: _currentIndex == 3
                              ? themeController.isDarkMode.value
                                  ? AppColors.primaryDark
                                  : AppColors.primaryLight
                              : null,
                        ),
                        const Positioned(
                          right: -1,
                          top: -3,
                          child: NewRequestsBadge(),
                        ),
                      ],
                    ),
                    label: 'Invites',
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        if (mounted && !_isReady) {
          _validateSession();
          _userSession.refreshSession(); // 여기에 추가
          setState(() => _isReady = true);
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        if (mounted && _isReady) {
          // _userSession.refreshSession(); // 추가: 앱이 포그라운드로 돌아올 때 리프레시
          setState(() => _isReady = false);
        }
        break;
      case AppLifecycleState.detached:
        break;
    }
  }
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../core/controllers/theme_controller.dart';
// import '../../config/theme.dart';
// import 'package:flutter/services.dart';
// import 'dart:async';
// import 'dart:developer' as developer;
// import '../../core/session/user_session.dart';
// import '../auth/views/login_screen.dart';

// class HomeScreen extends StatefulWidget {
//   final String userAddress;

//   const HomeScreen({
//     super.key,
//     required this.userAddress,
//   });

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
//   late final ThemeController themeController;
//   final _userSession = UserSession();
//   bool _isReady = false;
//   bool _isLoggingOut = false;
//   bool _isSessionValid = true;
//   Timer? _sessionCheckTimer;

//   @override
//   void initState() {
//     super.initState();
//     themeController = Get.find<ThemeController>();
//     WidgetsBinding.instance.addObserver(this);
//     _prepareScreen();
//     if (mounted) {
//       _startSessionCheck();
//     }
//   }

//   @override
//   void dispose() {
//     _sessionCheckTimer?.cancel();
//     _sessionCheckTimer = null;
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   Future<void> _prepareScreen() async {
//     try {
//       await Future.delayed(const Duration(milliseconds: 500));
//       if (mounted) {
//         setState(() => _isReady = true);
//       }
//     } catch (e) {
//       developer.log('Error preparing home screen: $e');
//     }
//   }

//   void _startSessionCheck() {
//     _sessionCheckTimer?.cancel();
//     _sessionCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
//       if (!mounted) {
//         timer.cancel();
//         return;
//       }
//       _validateSession();
//     });
//   }

//   Future<void> _validateSession() async {
//     if (!mounted) return;

//     final isValid = _userSession.validateSession();
//     if (!isValid && mounted) {
//       setState(() => _isSessionValid = false);
//       await _handleLogout();
//     }
//   }

//   Future<void> _handleLogout() async {
//     if (_isLoggingOut || !mounted) return;

//     try {
//       setState(() => _isLoggingOut = true);
//       final wasSessionValid = _isSessionValid;

//       _sessionCheckTimer?.cancel();
//       _sessionCheckTimer = null;

//       await _userSession.clear();

//       if (!mounted) return;

//       await Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(
//           builder: (context) => const LoginScreen(),
//         ),
//         (route) => false,
//       );

//       if (!wasSessionValid && mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('세션이 만료되었습니다. 다시 로그인해주세요.'),
//             backgroundColor: AppColors.error,
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       }
//     } catch (e) {
//       developer.log('Error during logout: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('로그아웃 중 오류가 발생했습니다.'),
//             backgroundColor: AppColors.error,
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoggingOut = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     return PopScope(
//       canPop: false,
//       onPopInvokedWithResult: (didPop, result) async {
//         if (didPop) return;
//         final shouldPop = await _onWillPop();
//         if (shouldPop && context.mounted) {
//           Navigator.of(context).pop();
//         }
//       },
//       child: Scaffold(
//         backgroundColor: colorScheme.surface,
//         body: AnimatedOpacity(
//           opacity: _isReady ? 1.0 : 0.0,
//           duration: const Duration(milliseconds: 300),
//           child: SafeArea(
//             child: Column(
//               children: [
//                 AppBar(
//                   title: Text(
//                     '홈',
//                     style: theme.textTheme.titleLarge,
//                   ),
//                   automaticallyImplyLeading: false,
//                   backgroundColor: colorScheme.surface,
//                   actions: [
//                     Obx(() => IconButton(
//                           icon: Icon(
//                             themeController.isDarkMode.value
//                                 ? Icons.light_mode
//                                 : Icons.dark_mode,
//                             color: colorScheme.onSurface,
//                           ),
//                           onPressed: themeController.toggleTheme,
//                         )),
//                     IconButton(
//                       icon: Icon(
//                         Icons.logout,
//                         color: colorScheme.onSurface,
//                       ),
//                       onPressed: _isLoggingOut ? null : _handleLogout,
//                     ),
//                   ],
//                 ),
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16.0,
//                       vertical: 24.0,
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           '안녕하세요!',
//                           style: theme.textTheme.headlineMedium,
//                         ),
//                         const SizedBox(height: 8),
//                         SelectableText(
//                           '지갑 주소: ${widget.userAddress}',
//                           style: theme.textTheme.bodyLarge,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<bool> _onWillPop() async {
//     return await showDialog(
//           context: context,
//           builder: (context) => Theme(
//             data: Theme.of(context),
//             child: AlertDialog(
//               backgroundColor: Theme.of(context).colorScheme.surface,
//               title: Text(
//                 '앱 종료',
//                 style: Theme.of(context).textTheme.titleLarge,
//               ),
//               content: Text(
//                 '앱을 종료하시겠습니까?',
//                 style: Theme.of(context).textTheme.bodyLarge,
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(false),
//                   child: Text(
//                     '취소',
//                     style: TextStyle(
//                       color: Theme.of(context).colorScheme.primary,
//                     ),
//                   ),
//                 ),
//                 TextButton(
//                   onPressed: () async {
//                     Navigator.of(context).pop(true);
//                     SystemNavigator.pop();
//                   },
//                   child: Text(
//                     '종료',
//                     style: TextStyle(
//                       color: Theme.of(context).colorScheme.primary,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ) ??
//         false;
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);
//     switch (state) {
//       case AppLifecycleState.resumed:
//         if (mounted && !_isReady) {
//           _validateSession();
//           setState(() => _isReady = true);
//         }
//         break;
//       case AppLifecycleState.inactive:
//       case AppLifecycleState.hidden:
//       case AppLifecycleState.paused:
//         if (mounted && _isReady) {
//           setState(() => _isReady = false);
//         }
//         break;
//       case AppLifecycleState.detached:
//         break;
//     }
//   }
// }
