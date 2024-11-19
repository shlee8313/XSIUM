// lib/presentation/screens/home/tabs/chats_tab.dart

import 'package:flutter/material.dart';
import '../chats/widgets/chat_list_tile.dart';
import '../widgets/security/secure_avatar.dart';
import '../chats/chat_room_screen.dart';
import '../../models/chat_room.dart';

class ChatsTab extends StatefulWidget {
  const ChatsTab({super.key});

  @override
  State<ChatsTab> createState() => _ChatsTabState();
}

class _ChatsTabState extends State<ChatsTab> {
  // 테스트용 더미 데이터
  final List<ChatRoom> chatRooms = [
    ChatRoom(
      id: '1',
      partnerId: 'user1',
      partnerName: '홍길동',
      lastMessage: '안녕하세요',
      lastMessageTime: '12:34',
      unreadCount: 2,
    ),
    ChatRoom(
      id: '2',
      partnerId: 'user2',
      partnerName: '김철수',
      lastMessage: '네 알겠습니다',
      lastMessageTime: '11:20',
      unreadCount: 0,
    ),
    ChatRoom(
      id: '3',
      partnerId: 'user3',
      partnerName: '이영희',
      lastMessage: '내일 뵙겠습니다',
      lastMessageTime: '어제',
      unreadCount: 5,
    ),
  ];

  void _navigateToChatRoom(BuildContext context, ChatRoom chatRoom) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRoomScreen(
          userId: 'currentUser', // 실제로는 로그인한 사용자 ID를 사용
          partnerId: chatRoom.partnerId,
          userName: chatRoom.partnerName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: chatRooms.length,
      itemBuilder: (context, index) {
        final chatRoom = chatRooms[index];

        return GestureDetector(
          onTap: () => _navigateToChatRoom(context, chatRoom),
          child: ChatListTile(
            leading: const SecureAvatar(),
            title: Text(chatRoom.partnerName),
            subtitle: Row(
              children: [
                if (chatRoom.isEncrypted) ...[
                  const Icon(Icons.lock, size: 12),
                  const SizedBox(width: 4),
                ],
                Text(chatRoom.lastMessage),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(chatRoom.lastMessageTime),
                if (chatRoom.unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      chatRoom.unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
