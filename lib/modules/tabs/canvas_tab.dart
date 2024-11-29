// lib/presentation/screens/home/tabs/canvas_tab.dart

import 'package:flutter/material.dart';
import '../canvas/widgets/canvas_list_tile.dart';
import '../widgets/badges/timer_badge.dart';
import '../widgets/security/secure_avatar.dart';
import '../widgets/badges/timer_badge.dart';
import '../widgets/base/optimized_list_view.dart';

class CanvasTab extends StatelessWidget {
  const CanvasTab({super.key});

  static const List<Map<String, dynamic>> _canvasChats = [
    {
      'id': '1',
      'name': '그림 대화방 1',
      'status': 'New canvas available',
      'time': '2m',
      'unread': true,
    },
    {
      'id': '2',
      'name': '낙서하기',
      'status': 'Drawing in progress',
      'time': '5m',
      'unread': false,
    },
    {
      'id': '3',
      'name': '스케치북',
      'status': 'Canvas completed',
      'time': '1h',
      'unread': true,
    }
  ];

  @override
  Widget build(BuildContext context) {
    return OptimizedListView(
      pageKey: 'canvas_list',
      itemCount: _canvasChats.length,
      itemBuilder: (context, index) {
        final chat = _canvasChats[index];
        return CanvasListTile(
          key: ValueKey('canvas_${chat['id']}'),
          leading: const SecureAvatar(),
          title: Text(chat['name']),
          subtitle: Row(
            children: [
              const Icon(Icons.brush, size: 12),
              const SizedBox(width: 4),
              Flexible(child: Text(chat['status'])),
            ],
          ),
          trailing: TimerBadge(
            time: chat['time'],
            showDot: chat['unread'],
          ),
        );
      },
    );
  }
}
