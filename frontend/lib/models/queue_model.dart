class QueueModel {
  final String id;
  final String facilityName;
  final String facilityType;
  final int currentWaitMinutes;
  final int queueLength;
  final int maxCapacity;
  final String status;
  final String trend;
  final String? zoneName;

  QueueModel({
    required this.id,
    required this.facilityName,
    required this.facilityType,
    required this.currentWaitMinutes,
    required this.queueLength,
    this.maxCapacity = 50,
    required this.status,
    required this.trend,
    this.zoneName,
  });

  factory QueueModel.fromJson(Map<String, dynamic> json) {
    final zone = json['zone'];
    return QueueModel(
      id: json['_id'] ?? '',
      facilityName: json['facilityName'] ?? '',
      facilityType: json['facilityType'] ?? '',
      currentWaitMinutes: json['currentWaitMinutes'] ?? 0,
      queueLength: json['queueLength'] ?? 0,
      maxCapacity: json['maxCapacity'] ?? 50,
      status: json['status'] ?? 'open',
      trend: json['trend'] ?? 'stable',
      zoneName: zone is Map ? zone['name'] : null,
    );
  }

  double get occupancyRatio => maxCapacity > 0 ? queueLength / maxCapacity : 0;

  String get typeIcon {
    switch (facilityType) {
      case 'food_stall': return '🍔';
      case 'restroom': return '🚻';
      case 'entry_gate': return '🚪';
      case 'exit_gate': return '🚶';
      case 'ticket_counter': return '🎫';
      case 'merchandise': return '🛍️';
      default: return '📍';
    }
  }
}
