class ZoneModel {
  final String id;
  final String name;
  final String type;
  final int capacity;
  final int currentOccupancy;
  final int density;
  final String densityLevel;
  final double x;
  final double y;
  final double width;
  final double height;
  final int floor;
  final List<String> facilities;

  ZoneModel({
    required this.id,
    required this.name,
    required this.type,
    required this.capacity,
    required this.currentOccupancy,
    required this.density,
    required this.densityLevel,
    required this.x,
    required this.y,
    this.width = 100,
    this.height = 100,
    this.floor = 1,
    this.facilities = const [],
  });

  factory ZoneModel.fromJson(Map<String, dynamic> json) {
    final coords = json['coordinates'] ?? {};
    return ZoneModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      capacity: json['capacity'] ?? 0,
      currentOccupancy: json['currentOccupancy'] ?? json['occupancy'] ?? 0,
      density: json['density'] ?? 0,
      densityLevel: json['densityLevel'] ?? 'low',
      x: (coords['x'] ?? 0).toDouble(),
      y: (coords['y'] ?? 0).toDouble(),
      width: (coords['width'] ?? 100).toDouble(),
      height: (coords['height'] ?? 100).toDouble(),
      floor: json['floor'] ?? 1,
      facilities: List<String>.from(json['facilities'] ?? []),
    );
  }
}
