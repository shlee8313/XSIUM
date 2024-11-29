import 'package:flutter/foundation.dart';

@immutable
class ChatRoom {
  final String id;
  final String partnerId;
  final String partnerName;
  final String lastMessage;
  final String lastMessageTime;
  final int unreadCount;
  final bool isEncrypted;

  const ChatRoom({
    required this.id,
    required this.partnerId,
    required this.partnerName,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.isEncrypted,
  });

  ChatRoom copyWith({
    String? id,
    String? partnerId,
    String? partnerName,
    String? lastMessage,
    String? lastMessageTime,
    int? unreadCount,
    bool? isEncrypted,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      partnerId: partnerId ?? this.partnerId,
      partnerName: partnerName ?? this.partnerName,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isEncrypted: isEncrypted ?? this.isEncrypted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatRoom &&
        other.id == id &&
        other.partnerId == partnerId &&
        other.partnerName == partnerName &&
        other.lastMessage == lastMessage &&
        other.lastMessageTime == lastMessageTime &&
        other.unreadCount == unreadCount &&
        other.isEncrypted == isEncrypted;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      partnerId,
      partnerName,
      lastMessage,
      lastMessageTime,
      unreadCount,
      isEncrypted,
    );
  }

  @override
  String toString() {
    return 'ChatRoom(id: $id, partnerId: $partnerId, partnerName: $partnerName, lastMessage: $lastMessage, lastMessageTime: $lastMessageTime, unreadCount: $unreadCount, isEncrypted: $isEncrypted)';
  }
}
