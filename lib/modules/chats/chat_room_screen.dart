// lib/presentation/screens/chat/chat_room_screen.dart

import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../core/controllers/theme_controller.dart';
import '../settings/common_app_bar.dart';
import '../settings/chat_room_settings_sheet.dart';
import './widgets/chat_room_body.dart';

class ChatRoomScreen extends StatelessWidget {
  final String userId; // 현재 사용자 ID
  final String partnerId; // 대화 상대방 ID
  final String userName; // 대화 상대방 이름

  const ChatRoomScreen({
    super.key,
    required this.userId,
    required this.partnerId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: userName,
        additionalActions: [
          // 채팅방 전용 설정
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => ChatRoomSettingsSheet(
                  userName: userName,
                ),
              );
            },
          ),
        ],
      ),
      body: ChatRoomBody(
        userId: userId,
        partnerId: partnerId,
      ),
    );
  }
}
