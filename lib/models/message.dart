// lib/models/message.dart
class Message {
  final String id;
  final String senderId;
  final String text;
  final String time;
  final bool isRead;

  Message({
    required this.id,
    required this.senderId,
    required this.text,
    required this.time,
    this.isRead = false,
  });
}
