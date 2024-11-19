// lib/presentation/screens/home/tabs/invites_tab.dart

import 'package:flutter/material.dart';
// import '../widgets/security/secure_avatar.dart';

class InvitesTab extends StatelessWidget {
  const InvitesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        // 보낸 초대
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '보낸 초대',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Expanded(
                  child: SizedBox(
                width: 30,
              )),
            ],
          ),
        ),
        // 구분선
        const Divider(height: 1),
        // 받은 초대
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '받은 초대',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Expanded(child: SizedBox(width: 30)),
            ],
          ),
        ),
      ],
    );
  }
}
