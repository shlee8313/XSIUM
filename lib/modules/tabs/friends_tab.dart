// lib/presentation/screens/home/tabs/friends_tab.dart

import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../core/controllers/theme_controller.dart';
import '../friends/widgets/friend_list_tile.dart';
import '../widgets/security/secure_avatar.dart';

class FriendsTab extends StatelessWidget {
  final String userAddress;

  const FriendsTab({
    super.key,
    required this.userAddress,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return FriendListTile(
          leading: const SecureAvatar(),
          title: const Text('Friend Name'),
          subtitle: const Row(
            children: [
              Icon(Icons.security, size: 12),
              SizedBox(width: 4),
              Text('안전한 친구'),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.sms_outlined),
                onPressed: () => startChat(),
              ),
              IconButton(
                icon: const Icon(Icons.palette_outlined),
                onPressed: () => startCanvas(),
              ),
            ],
          ),
        );
      },
    );
  }

  void startChat() {
    // 채팅 시작 로직
  }

  void startCanvas() {
    // 캔버스 채팅 시작 로직
  }
}
