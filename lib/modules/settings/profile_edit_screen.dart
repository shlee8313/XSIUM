// lib/modules/settings/profile_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/session/user_session.dart';
// import '../widgets/avartar/avatar.dart';
import '../../services/supabase_service.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _displayNameController = TextEditingController();
  final _userSession = UserSession();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  int _selectedAvatarIndex = 0;

  final List<String> defaultAvatars = [
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
  void initState() {
    super.initState();
    _displayNameController.text = _userSession.displayName ?? '';
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('edit_profile'.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Avatar Selection
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: defaultAvatars.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedAvatarIndex = index;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selectedAvatarIndex == index
                                  ? colorScheme.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.grey[300],
                            child: ClipOval(
                              child: Image.asset(
                                defaultAvatars[index],
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
                // Display Name Field
                TextFormField(
                  controller: _displayNameController,
                  decoration: InputDecoration(
                    labelText: 'display_name'.tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'enter_display_name'.tr;
                    }
                    if (value.length < 5) {
                      return 'name_min_length'.tr;
                    }
                    if (value.length > 20) {
                      return 'name_max_length'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : Text('save'.tr),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newDisplayName = _displayNameController.text.trim();
      final newAvatarPath = defaultAvatars[_selectedAvatarIndex];

      // Supabase에 프로필 업데이트
      final success = await SupabaseService.updateUser(
        xummAddress: _userSession.getXummAddress()!,
        displayName: newDisplayName,
        avatarUrl: newAvatarPath,
      );

      if (success) {
        // UserSession 업데이트
        await _userSession.initializeUserData(
          address: _userSession.getXummAddress()!,
          displayName: newDisplayName,
          avatarUrl: newAvatarPath,
        );

        Get.back(result: true);
        Get.snackbar(
          'success'.tr,
          'profile_updated'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'profile_update_error'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
