class ChatRoom {
  final String id;
  final String partnerId;
  final String partnerName;
  final String lastMessage;
  final String lastMessageTime;
  final int unreadCount;
  final bool isEncrypted;

  ChatRoom({
    required this.id,
    required this.partnerId,
    required this.partnerName,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isEncrypted = true,
  });
}
