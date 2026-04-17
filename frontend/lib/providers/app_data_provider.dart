import 'package:flutter/material.dart';
import '../models/zone_model.dart';
import '../models/queue_model.dart';
import '../models/food_models.dart';
import '../models/emergency_model.dart';
import '../services/api_service.dart';

class AppDataProvider extends ChangeNotifier {
  final ApiService _api;

  List<ZoneModel> _zones = [];
  List<QueueModel> _queues = [];
  List<VendorModel> _vendors = [];
  List<OrderModel> _orders = [];
  List<EmergencyModel> _emergencies = [];
  List<NotificationModel> _notifications = [];
  int _unreadNotifications = 0;
  Map<String, dynamic>? _crowdStats;
  Map<String, dynamic>? _queueStats;
  List<CartItem> _cart = [];
  String? _selectedVendorId;
  bool _isLoading = false;
  String? _error;

  AppDataProvider(this._api);

  // Getters
  List<ZoneModel> get zones => _zones;
  List<QueueModel> get queues => _queues;
  List<VendorModel> get vendors => _vendors;
  List<OrderModel> get orders => _orders;
  List<EmergencyModel> get emergencies => _emergencies;
  List<NotificationModel> get notifications => _notifications;
  int get unreadNotifications => _unreadNotifications;
  Map<String, dynamic>? get crowdStats => _crowdStats;
  Map<String, dynamic>? get queueStats => _queueStats;
  List<CartItem> get cart => _cart;
  String? get selectedVendorId => _selectedVendorId;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get cartTotal => _cart.fold(0, (sum, item) => sum + item.total);
  int get cartItemCount => _cart.fold(0, (sum, item) => sum + item.quantity);

  // ======= CROWD & ZONES =======
  Future<void> fetchZones() async {
    try {
      final data = await _api.get('/crowd/zones');
      _zones = (data['zones'] as List).map((z) => ZoneModel.fromJson(z)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> fetchCrowdStats() async {
    try {
      final data = await _api.get('/crowd/stats');
      _crowdStats = data['stats'];
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<List<Map<String, dynamic>>> fetchHeatmap() async {
    try {
      final data = await _api.get('/crowd/heatmap');
      return List<Map<String, dynamic>>.from(data['heatmap'] ?? []);
    } catch (e) {
      return [];
    }
  }

  // ======= QUEUES =======
  Future<void> fetchQueues() async {
    try {
      final data = await _api.get('/queues');
      _queues = (data['queues'] as List).map((q) => QueueModel.fromJson(q)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> fetchQueueStats() async {
    try {
      final data = await _api.get('/queues/stats/summary');
      _queueStats = data['stats'];
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  // ======= FOOD =======
  Future<void> fetchVendors() async {
    try {
      final data = await _api.get('/food/vendors');
      _vendors = (data['vendors'] as List).map((v) => VendorModel.fromJson(v)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<List<MenuItemModel>> fetchMenu(String vendorId) async {
    try {
      final data = await _api.get('/food/menu/$vendorId');
      return (data['menu'] as List).map((m) => MenuItemModel.fromJson(m)).toList();
    } catch (e) {
      return [];
    }
  }

  void selectVendor(String vendorId) {
    _selectedVendorId = vendorId;
    notifyListeners();
  }

  void addToCart(MenuItemModel item) {
    final existing = _cart.indexWhere((c) => c.menuItem.id == item.id);
    if (existing >= 0) {
      _cart[existing].quantity++;
    } else {
      _cart.add(CartItem(menuItem: item));
    }
    notifyListeners();
  }

  void removeFromCart(String itemId) {
    _cart.removeWhere((c) => c.menuItem.id == itemId);
    notifyListeners();
  }

  void updateCartQuantity(String itemId, int quantity) {
    final idx = _cart.indexWhere((c) => c.menuItem.id == itemId);
    if (idx >= 0) {
      if (quantity <= 0) {
        _cart.removeAt(idx);
      } else {
        _cart[idx].quantity = quantity;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  Future<OrderModel?> placeOrder(String vendorId, String? instructions) async {
    try {
      _isLoading = true;
      notifyListeners();

      final items = _cart.map((c) => {
        'menuItemId': c.menuItem.id,
        'quantity': c.quantity,
      }).toList();

      final data = await _api.post('/food/orders', {
        'vendorId': vendorId,
        'items': items,
        'specialInstructions': instructions ?? '',
      });

      final order = OrderModel.fromJson(data['order']);
      _orders.insert(0, order);
      _cart.clear();
      _isLoading = false;
      notifyListeners();
      return order;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> fetchOrders() async {
    try {
      final data = await _api.get('/food/orders');
      _orders = (data['orders'] as List).map((o) => OrderModel.fromJson(o)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<OrderModel?> refreshOrder(String orderId) async {
    try {
      final data = await _api.get('/food/orders/$orderId');
      final order = OrderModel.fromJson(data['order']);
      final idx = _orders.indexWhere((o) => o.id == orderId);
      if (idx >= 0) {
        _orders[idx] = order;
        notifyListeners();
      }
      return order;
    } catch (e) {
      return null;
    }
  }

  // ======= EMERGENCY =======
  Future<EmergencyModel?> reportEmergency(String type, String description, String? zoneId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final body = <String, dynamic>{
        'type': type,
        'description': description,
      };
      if (zoneId != null) body['locationZone'] = zoneId;

      final data = await _api.post('/emergency', body);
      final emergency = EmergencyModel.fromJson(data['emergency']);
      _emergencies.insert(0, emergency);
      _isLoading = false;
      notifyListeners();
      return emergency;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> fetchEmergencies() async {
    try {
      final data = await _api.get('/emergency');
      _emergencies = (data['emergencies'] as List).map((e) => EmergencyModel.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  // ======= NOTIFICATIONS =======
  Future<void> fetchNotifications() async {
    try {
      final data = await _api.get('/notifications');
      _notifications = (data['notifications'] as List).map((n) => NotificationModel.fromJson(n)).toList();
      _unreadNotifications = data['unreadCount'] ?? 0;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> markNotificationRead(String id) async {
    try {
      await _api.put('/notifications/$id/read', {});
      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx >= 0) {
        _notifications[idx] = NotificationModel(
          id: _notifications[idx].id,
          title: _notifications[idx].title,
          message: _notifications[idx].message,
          type: _notifications[idx].type,
          isRead: true,
          createdAt: _notifications[idx].createdAt,
        );
        _unreadNotifications = _notifications.where((n) => !n.isRead).length;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> markAllRead() async {
    try {
      await _api.put('/notifications/read-all', {});
      _notifications = _notifications.map((n) => NotificationModel(
        id: n.id, title: n.title, message: n.message,
        type: n.type, isRead: true, createdAt: n.createdAt,
      )).toList();
      _unreadNotifications = 0;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  // ======= REFRESH ALL =======
  Future<void> refreshAll() async {
    await Future.wait([
      fetchZones(),
      fetchCrowdStats(),
      fetchQueues(),
      fetchQueueStats(),
      fetchVendors(),
      fetchOrders(),
      fetchEmergencies(),
      fetchNotifications(),
    ]);
  }
}
