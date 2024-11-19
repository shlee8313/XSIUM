// lib/presentation/widgets/chat/message_bubble.dart
import 'package:flutter/material.dart';
import '../../../models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: 8,
          right: 8,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isMe
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.time, // 시간 표시
              style: TextStyle(
                fontSize: 12,
                color: isMe
                    ? theme.colorScheme.onPrimary.withOpacity(0.7)
                    : theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
