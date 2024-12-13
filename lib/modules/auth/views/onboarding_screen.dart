// lib/modules/auth/views/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart'; // 아바타 이미지 선택을 위해 추가
// import 'dart:io'; // 파일 관련 작업을 위한 패키지
// import 'package:xsium_chat/modules/home/home_screen.dart';
import '../controllers/onboarding_controller.dart';
// import '../../../services/supabase_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.userAddress,
    required this.userToken,
  });

  final String userAddress;
  final String userToken;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with WidgetsBindingObserver {
  late final OnboardingController _controller;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(OnboardingController());
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_disposed) return;

    if (state == AppLifecycleState.paused) {
      _controller.cleanupState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Create Your Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select an avatar and enter your display name',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _controller.defaultAvatars.length,
                    itemBuilder: (context, index) {
                      return Obx(() => GestureDetector(
                            onTap: () => _controller.selectDefaultAvatar(index),
                            child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        _controller.selectedAvatarIndex.value ==
                                                index
                                            ? Theme.of(context).primaryColor
                                            : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 35,
                                  backgroundColor: Colors.grey[300],
                                  child: ClipOval(
                                    child: Image.asset(
                                      _controller.defaultAvatars[index],
                                      width: 70, // radius * 2
                                      height: 70, // radius * 2
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )),
                          ));
                    },
                  ),
                ),
                const SizedBox(height: 32),
                Obx(() => SizedBox(
                      width: 250,
                      child: TextField(
                        onChanged: (value) {
                          _controller.displayName.value = value;
                          _controller.checkDisplayName(value);
                        },
                        decoration: InputDecoration(
                          labelText: 'Display Name',
                          errorText: _controller.errorMessage.value,
                          suffixIcon: _controller.isCheckingName.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        enabled: !_controller.isLoading.value,
                      ),
                    )),
                const SizedBox(height: 24),
                Obx(() {
                  final isLoading = _controller.isLoading.value;

                  return ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            _controller.saveUsers(
                              widget.userAddress,
                              widget.userToken,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isLoading ? Colors.grey : Colors.blue, // 배경색
                      foregroundColor: Colors.white, // 텍스트 색상
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 24.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0), // 버튼 모서리를 둥글게
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : Text(
                            'Continue'.tr,
                            style: const TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
