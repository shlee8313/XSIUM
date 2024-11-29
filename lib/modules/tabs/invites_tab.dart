// lib/presentation/screens/home/tabs/invites_tab.dart

import 'package:flutter/material.dart';
import '../widgets/security/secure_avatar.dart';
import '../widgets/base/optimized_list_view.dart';

class InvitesTab extends StatelessWidget {
  const InvitesTab({super.key});

  static const List<Map<String, dynamic>> _invites = [
    {
      'id': '1',
      'name': 'David',
      'type': '친구 요청',
      'time': '10분 전',
      'message': '안녕하세요, 친구 추가 부탁드립니다.',
    },
    {
      'id': '2',
      'name': 'Eve',
      'type': '채팅 초대',
      'time': '30분 전',
      'message': '새로운 프로젝트 논의하고 싶습니다.',
    },
    {
      'id': '3',
      'name': 'Frank',
      'type': '캔버스 초대',
      'time': '1시간 전',
      'message': '아이디어 스케치 함께 해요.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return OptimizedListView(
      pageKey: 'invite_list',
      itemCount: _invites.length,
      itemBuilder: (context, index) {
        final invite = _invites[index];
        return ListTile(
          key: ValueKey('invite_${invite['id']}'),
          leading: const SecureAvatar(),
          title: Text(invite['name']),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(invite['type']),
              Text(
                invite['message'],
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          trailing: Text(invite['time']),
        );
      },
    );
  }
}
