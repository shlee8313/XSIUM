class CanvasChat {
  final String id;
  final String partnerId;
  final String partnerName;
  final DateTime lastDrawingTime;
  final int unviewedCount;
  final bool isEncrypted;
  final Duration drawingDuration;

  CanvasChat({
    required this.id,
    required this.partnerId,
    required this.partnerName,
    required this.lastDrawingTime,
    this.unviewedCount = 0,
    this.isEncrypted = true,
    this.drawingDuration = const Duration(seconds: 30),
  });
}
