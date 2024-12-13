// lib\modules\widgets\avartar\avatar.dart

import 'package:flutter/material.dart';
import '../../../core/session/user_session.dart';

class Avatar extends StatelessWidget {
  final double size;
  final UserSession _userSession = UserSession();

  Avatar({
    super.key,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    // 기본 아바타 경로
    const defaultAvatarPath = 'assets/images/avatars/avatar.png';
    final avatarUrl = _userSession.avatarUrl;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[200], // 연한 회색 배경
        shape: BoxShape.circle,
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: avatarUrl != null
                ? AssetImage(avatarUrl)
                : const AssetImage(defaultAvatarPath) as ImageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
