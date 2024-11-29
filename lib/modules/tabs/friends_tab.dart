// lib/presentation/screens/home/tabs/friends_tab.dart

import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../core/controllers/theme_controller.dart';
import '../friends/widgets/friend_list_tile.dart';
import '../widgets/security/secure_avatar.dart';
import '../widgets/base/optimized_list_view.dart';

class FriendsTab extends StatelessWidget {
  final String userAddress;

  const FriendsTab({
    super.key,
    required this.userAddress,
  });

  static const List<Map<String, dynamic>> _friends = [
    {
      'id': '1',
      'name': 'Alice',
      'status': '온라인',
      'address': 'xumm_address_1',
      'lastActive': '방금 전',
    },
    {
      'id': '2',
      'name': 'Bob',
      'status': '오프라인',
      'address': 'xumm_address_2',
      'lastActive': '1시간 전',
    },
    {
      'id': '3',
      'name': 'Charlie',
      'status': '자리비움',
      'address': 'xumm_address_3',
      'lastActive': '30분 전',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return OptimizedListView(
      pageKey: 'friend_list',
      itemCount: _friends.length,
      itemBuilder: (context, index) {
        final friend = _friends[index];
        return FriendListTile(
          key: ValueKey('friend_${friend['id']}'),
          leading: const SecureAvatar(),
          title: Text(friend['name']),
          subtitle: Row(
            children: [
              const Icon(Icons.security, size: 12),
              const SizedBox(width: 4),
              Flexible(child: Text(friend['status'])),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.sms_outlined),
                onPressed: () => _startChat(friend['address']),
              ),
              IconButton(
                icon: const Icon(Icons.palette_outlined),
                onPressed: () => _startCanvas(friend['address']),
              ),
            ],
          ),
        );
      },
    );
  }

  void _startChat(String partnerAddress) {
    debugPrint('Starting chat with: $partnerAddress');
  }

  void _startCanvas(String partnerAddress) {
    debugPrint('Starting canvas with: $partnerAddress');
  }
}
