// lib/presentation/screens/home/tabs/chats_tab.dart

import 'package:flutter/material.dart';
import '../chats/widgets/chat_list_tile.dart';
import '../widgets/security/secure_avatar.dart';
import '../chats/chat_room_screen.dart';
import '../../models/chat_room.dart';
import '../widgets/base/optimized_list_view.dart';

class ChatsTab extends StatelessWidget {
  const ChatsTab({super.key});

  static const List<ChatRoom> _chatRooms = [
    ChatRoom(
      id: '1',
      partnerId: 'xumm_user1',
      partnerName: 'Alice',
      lastMessage: '캔버스 채팅 어때요?',
      lastMessageTime: '방금 전',
      unreadCount: 3,
      isEncrypted: true,
    ),
    ChatRoom(
      id: '2',
      partnerId: 'xumm_user2',
      partnerName: 'Bob',
      lastMessage: '네, 확인해보겠습니다',
      lastMessageTime: '10분 전',
      unreadCount: 0,
      isEncrypted: true,
    ),
    ChatRoom(
      id: '3',
      partnerId: 'xumm_user3',
      partnerName: 'Charlie',
      lastMessage: '좋은 아이디어네요!',
      lastMessageTime: '1시간 전',
      unreadCount: 5,
      isEncrypted: true,
    ),
  ];

  void _navigateToChatRoom(BuildContext context, ChatRoom chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRoomScreen(
          userId: 'current_user_id', // TODO: 실제 사용자 ID로 교체 필요
          partnerId: chat.partnerId,
          userName: chat.partnerName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OptimizedListView(
      pageKey: 'chat_list',
      itemCount: _chatRooms.length,
      itemBuilder: (context, index) {
        final chat = _chatRooms[index];
        return ChatListTile(
          key: ValueKey('chat_${chat.id}'),
          leading: const SecureAvatar(),
          title: Text(chat.partnerName),
          subtitle: Row(
            children: [
              if (chat.isEncrypted) ...[
                const Icon(Icons.lock, size: 12),
                const SizedBox(width: 4),
              ],
              Flexible(child: Text(chat.lastMessage)),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(chat.lastMessageTime),
              if (chat.unreadCount > 0)
                Badge(
                  label: Text(chat.unreadCount.toString()),
                ),
            ],
          ),
          onTap: () => _navigateToChatRoom(context, chat),
        );
      },
    );
  }
}
