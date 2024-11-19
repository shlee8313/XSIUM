// lib/presentation/widgets/settings/chat_room_settings_sheet.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/theme_controller.dart';

class ChatRoomSettingsSheet extends StatelessWidget {
  final String userName;

  const ChatRoomSettingsSheet({
    super.key,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('알림 설정'),
            onTap: () {
              // 채팅방 알림 설정
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('대화 내용 암호화'),
            onTap: () {
              // 암호화 설정
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('대화 내용 삭제'),
            onTap: () {
              // 대화 내용 삭제
            },
          ),
        ],
      ),
    );
  }
}
