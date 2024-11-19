// lib/presentation/screens/home/components/secure_avatar.dart

import 'package:flutter/material.dart';

class SecureAvatar extends StatelessWidget {
  const SecureAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.person,
        color: Colors.grey,
      ),
    );
  }
}
