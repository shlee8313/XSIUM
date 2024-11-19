// lib/presentation/widgets/received_invites_list.dart

import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../../core/controllers/theme_controller.dart';
import 'invite_list_tile.dart';

class ReceivedInvitesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return InviteListTile(
          title: const Text('User Name'),
          subtitle: const Text('Wants to connect'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => acceptInvite(),
                child: const Text('Accept'),
              ),
              TextButton(
                onPressed: () => declineInvite(),
                child: const Text('Decline'),
              ),
            ],
          ),
        );
      },
    );
  }

  void acceptInvite() {
    // 초대 수락 로직
  }

  void declineInvite() {
    // 초대 거절 로직
  }
}
