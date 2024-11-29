class Friend {
  final String id;
  final String name;
  final String address;
  final bool isOnline;
  final bool isTrusted;
  final DateTime lastSeen;

  Friend({
    required this.id,
    required this.name,
    required this.address,
    this.isOnline = false,
    this.isTrusted = false,
    required this.lastSeen,
  });
}
