class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String seatSection;
  final String seatRow;
  final String seatNumber;
  final String role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.seatSection = '',
    this.seatRow = '',
    this.seatNumber = '',
    this.role = 'user',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      seatSection: json['seatSection'] ?? '',
      seatRow: json['seatRow'] ?? '',
      seatNumber: json['seatNumber'] ?? '',
      role: json['role'] ?? 'user',
    );
  }

  String get seatDisplay {
    if (seatSection.isEmpty) return 'Not assigned';
    return 'Section $seatSection, Row $seatRow, Seat $seatNumber';
  }
}
