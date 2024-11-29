// lib\modules\chats\widgets\chat_list_tile.dart
import 'package:flutter/foundation.dart'; // 추가
import '../../widgets/base/base_list_tile.dart';

class ChatListTile extends BaseListTile {
  final VoidCallback? onTap; // 추가

  const ChatListTile({
    super.key,
    required super.leading,
    required super.title,
    required super.subtitle,
    required super.trailing,
    this.onTap, // 추가
  });
}
