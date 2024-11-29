// lib/presentation/widgets/timer_badge.dart

import 'package:flutter/material.dart';

class TimerBadge extends StatelessWidget {
  final String time;
  final bool showDot;

  const TimerBadge({
    super.key,
    required this.time,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.orange..withAlpha(51), // 0.2 * 255 ≈ 51,
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
            time,
            style: TextStyle(
              color: Colors.orange[700],
              fontSize: 12,
            ),
          ),
          if (showDot) ...[
            const SizedBox(width: 4),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.orange[700],
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
