// lib/presentation/screens/chat/chat_room_body.dart
import 'package:flutter/material.dart';
// import '../../../config/theme.dart';
import '../../../models/message.dart'; // Message 모델 필요
import 'message_bubble.dart';

class ChatRoomBody extends StatefulWidget {
  final String userId; // 현재 사용자 ID
  final String partnerId; // 대화 상대방 ID

  const ChatRoomBody({
    super.key,
    required this.userId,
    required this.partnerId,
  });

  @override
  State<ChatRoomBody> createState() => _ChatRoomBodyState();
}

class _ChatRoomBodyState extends State<ChatRoomBody> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = []; // 메시지 목록
  bool _isLoading = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      // TODO: 메시지 로드 로직 구현
      // final messages = await chatRepository.getMessages(widget.partnerId);
      // setState(() {
      //   _messages.addAll(messages);
      // });
    } catch (e) {
      // 에러 처리
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);

    try {
      // TODO: 메시지 전송 로직 구현
      // final message = await chatRepository.sendMessage(
      //   widget.partnerId,
      //   text,
      // );

      // setState(() {
      //   _messages.add(message);
      //   _messageController.clear();
      // });

      // 스크롤을 맨 아래로
      _scrollToBottom();
    } catch (e) {
      // 에러 처리
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // 메시지 목록
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isMe = message.senderId == widget.userId;

                    return MessageBubble(
                      message: message,
                      isMe: isMe,
                    );
                  },
                ),
        ),

        // 메시지 입력창
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                // 첨부 파일 버튼
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () {
                    // TODO: 파일 첨부 기능 구현
                  },
                ),
                // 메시지 입력 필드
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: '메시지를 입력하세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceVariant,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                  ),
                ),
                const SizedBox(width: 8),
                // 전송 버튼
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: _isSending ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
