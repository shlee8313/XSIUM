// lib/presentation/screens/home/tabs/canvas_tab.dart

import 'package:flutter/material.dart';
import '../canvas/widgets/canvas_list_tile.dart';
import '../widgets/badges/timer_badge.dart';
import '../widgets/security/secure_avatar.dart';

class CanvasTab extends StatelessWidget {
  const CanvasTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return CanvasListTile(
          leading: const SecureAvatar(),
          title: const Text('Canvas Chat'),
          subtitle: Row(
            children: [
              const Icon(Icons.brush, size: 12),
              const SizedBox(width: 4),
              Text('New canvas'),
            ],
          ),
          trailing: const TimerBadge(),
        );
      },
    );
  }
}
