// lib/presentation/widgets/sent_invites_list.dart

import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../../core/controllers/theme_controller.dart';
import 'invite_list_tile.dart';

class SentInvitesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return InviteListTile(
          title: const Text('Invited User'),
          subtitle: const Text('Pending...'),
          trailing: TextButton(
            onPressed: () => cancelInvite(),
            child: const Text('Cancel'),
          ),
        );
      },
    );
  }

  void cancelInvite() {
    // 초대 취소 로직
  }
}
