enum InviteStatus { pending, accepted, rejected }

class Invite {
  final String id;
  final String userId;
  final String userName;
  final InviteStatus status;
  final DateTime timestamp;

  Invite({
    required this.id,
    required this.userId,
    required this.userName,
    required this.status,
    required this.timestamp,
  });
}
