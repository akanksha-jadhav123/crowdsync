class EmergencyModel {
  final String id;
  final String type;
  final String description;
  final String status;
  final String priority;
  final String? locationDescription;
  final String? zoneName;
  final String? assignedTo;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  EmergencyModel({
    required this.id,
    required this.type,
    required this.description,
    required this.status,
    required this.priority,
    this.locationDescription,
    this.zoneName,
    this.assignedTo,
    required this.createdAt,
    this.resolvedAt,
  });

  factory EmergencyModel.fromJson(Map<String, dynamic> json) {
    final zone = json['locationZone'];
    return EmergencyModel(
      id: json['_id'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'reported',
      priority: json['priority'] ?? 'high',
      locationDescription: json['locationDescription'],
      zoneName: zone is Map ? zone['name'] : null,
      assignedTo: json['assignedTo'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      resolvedAt: json['resolvedAt'] != null ? DateTime.tryParse(json['resolvedAt']) : null,
    );
  }

  String get typeIcon {
    switch (type) {
      case 'medical': return '🏥';
      case 'fire': return '🔥';
      case 'security': return '🔒';
      case 'lost_child': return '👶';
      case 'evacuation': return '🚨';
      default: return '⚠️';
    }
  }

  String get typeDisplay {
    switch (type) {
      case 'medical': return 'Medical Emergency';
      case 'fire': return 'Fire Alert';
      case 'security': return 'Security Issue';
      case 'lost_child': return 'Lost Child';
      case 'evacuation': return 'Evacuation';
      default: return 'Other';
    }
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'info',
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  String get typeIcon {
    switch (type) {
      case 'emergency': return '🚨';
      case 'warning': return '⚠️';
      case 'alert': return '🔔';
      case 'order': return '📦';
      case 'promo': return '🎉';
      default: return 'ℹ️';
    }
  }
}
