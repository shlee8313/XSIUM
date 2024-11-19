// lib/presentation/screens/home/components/new_requests_badge.dart

import 'package:flutter/material.dart';

class NewRequestsBadge extends StatelessWidget {
  const NewRequestsBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: const Text(
        '2',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
        ),
      ),
    );
  }
}
