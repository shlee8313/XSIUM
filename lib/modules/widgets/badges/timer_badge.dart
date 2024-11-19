// lib/presentation/widgets/timer_badge.dart

import 'package:flutter/material.dart';

class TimerBadge extends StatelessWidget {
  const TimerBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 14,
            color: Colors.orange[700],
          ),
          const SizedBox(width: 4),
          Text(
            '5:00',
            style: TextStyle(
              color: Colors.orange[700],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
