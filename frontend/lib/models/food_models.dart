class VendorModel {
  final String id;
  final String name;
  final String cuisineType;
  final String description;
  final double rating;
  final bool isOpen;
  final int avgPrepMinutes;
  final String? zoneName;

  VendorModel({
    required this.id,
    required this.name,
    required this.cuisineType,
    this.description = '',
    this.rating = 4.0,
    this.isOpen = true,
    this.avgPrepMinutes = 10,
    this.zoneName,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    final zone = json['zone'];
    return VendorModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      cuisineType: json['cuisineType'] ?? '',
      description: json['description'] ?? '',
      rating: (json['rating'] ?? 4.0).toDouble(),
      isOpen: json['isOpen'] ?? true,
      avgPrepMinutes: json['avgPrepMinutes'] ?? 10,
      zoneName: zone is Map ? zone['name'] : null,
    );
  }

  String get cuisineIcon {
    switch (cuisineType.toLowerCase()) {
      case 'american': return '🍔';
      case 'italian': return '🍕';
      case 'mexican': return '🌮';
      case 'japanese': return '🍣';
      case 'beverages': return '🥤';
      case 'desserts': return '🍦';
      default: return '🍽️';
    }
  }
}

class MenuItemModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final bool isAvailable;
  final bool isVeg;
  final int preparationTime;

  MenuItemModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.price,
    required this.category,
    this.isAvailable = true,
    this.isVeg = false,
    this.preparationTime = 10,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      category: json['category'] ?? 'snacks',
      isAvailable: json['isAvailable'] ?? true,
      isVeg: json['isVeg'] ?? false,
      preparationTime: json['preparationTime'] ?? 10,
    );
  }
}

class CartItem {
  final MenuItemModel menuItem;
  int quantity;

  CartItem({required this.menuItem, this.quantity = 1});

  double get total => menuItem.price * quantity;
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String vendorName;
  final List<dynamic> items;
  final double totalPrice;
  final String status;
  final DateTime? estimatedReadyTime;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.vendorName,
    required this.items,
    required this.totalPrice,
    required this.status,
    this.estimatedReadyTime,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final vendor = json['vendor'];
    return OrderModel(
      id: json['_id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      vendorName: vendor is Map ? vendor['name'] ?? '' : '',
      items: json['items'] ?? [],
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      estimatedReadyTime: json['estimatedReadyTime'] != null
          ? DateTime.tryParse(json['estimatedReadyTime'])
          : null,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  String get statusDisplay {
    switch (status) {
      case 'pending': return 'Order Placed';
      case 'confirmed': return 'Confirmed';
      case 'preparing': return 'Preparing';
      case 'ready': return 'Ready for Pickup';
      case 'picked_up': return 'Picked Up';
      case 'cancelled': return 'Cancelled';
      default: return status;
    }
  }

  int get statusStep {
    switch (status) {
      case 'pending': return 0;
      case 'confirmed': return 1;
      case 'preparing': return 2;
      case 'ready': return 3;
      case 'picked_up': return 4;
      default: return 0;
    }
  }
}
