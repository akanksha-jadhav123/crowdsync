import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../providers/app_data_provider.dart';
import '../models/food_models.dart';

class FoodOrderScreen extends StatefulWidget {
  const FoodOrderScreen({super.key});

  @override
  State<FoodOrderScreen> createState() => _FoodOrderScreenState();
}

class _FoodOrderScreenState extends State<FoodOrderScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedVendorId;
  List<MenuItemModel> _menu = [];
  bool _loadingMenu = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMenu(String vendorId) async {
    setState(() { _selectedVendorId = vendorId; _loadingMenu = true; });
    final data = context.read<AppDataProvider>();
    _menu = await data.fetchMenu(vendorId);
    setState(() => _loadingMenu = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food & Drinks', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentCyan,
          labelColor: AppTheme.accentCyan,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [
            Tab(text: 'Vendors'),
            Tab(text: 'Cart'),
            Tab(text: 'Orders'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _vendorsTab(),
          _cartTab(),
          _ordersTab(),
        ],
      ),
    );
  }

  // ======= VENDORS TAB =======
  Widget _vendorsTab() {
    return Consumer<AppDataProvider>(
      builder: (_, data, __) {
        if (_selectedVendorId != null) {
          final vendor = data.vendors.firstWhere(
            (v) => v.id == _selectedVendorId,
            orElse: () => data.vendors.first,
          );
          return _menuView(vendor);
        }
        return ListView(
          padding: const EdgeInsets.all(20),
          children: data.vendors.map((v) => _vendorCard(v)).toList(),
        );
      },
    );
  }

  Widget _vendorCard(VendorModel vendor) {
    return GestureDetector(
      onTap: () => _loadMenu(vendor.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.accentAmber.withOpacity(0.2), AppTheme.accentOrange.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Text(vendor.cuisineIcon, style: const TextStyle(fontSize: 28))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vendor.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(vendor.description, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: AppTheme.accentAmber),
                      const SizedBox(width: 4),
                      Text('${vendor.rating}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.accentAmber)),
                      const SizedBox(width: 12),
                      Icon(Icons.timer, size: 14, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text('${vendor.avgPrepMinutes} min', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: vendor.isOpen ? AppTheme.accentGreen.withOpacity(0.15) : AppTheme.accentRed.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                vendor.isOpen ? 'OPEN' : 'CLOSED',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: vendor.isOpen ? AppTheme.accentGreen : AppTheme.accentRed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuView(VendorModel vendor) {
    return Column(
      children: [
        // Back button
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _selectedVendorId = null),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Text(vendor.cuisineIcon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(vendor.name, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        Expanded(
          child: _loadingMenu
              ? const Center(child: CircularProgressIndicator(color: AppTheme.accentCyan))
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: _menu.map((item) => _menuItemCard(item)).toList(),
                ),
        ),
      ],
    );
  }

  Widget _menuItemCard(MenuItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (item.isVeg)
                      Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.accentGreen, width: 1.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Container(width: 8, height: 8, decoration: BoxDecoration(color: AppTheme.accentGreen, shape: BoxShape.circle)),
                      ),
                    Flexible(child: Text(item.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15))),
                  ],
                ),
                const SizedBox(height: 4),
                Text(item.description, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary), maxLines: 2),
                const SizedBox(height: 8),
                Text('\$${item.price.toStringAsFixed(2)}', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.accentCyan)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              context.read<AppDataProvider>().addToCart(item);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item.name} added to cart'),
                  backgroundColor: AppTheme.accentGreen.withOpacity(0.9),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ======= CART TAB =======
  Widget _cartTab() {
    return Consumer<AppDataProvider>(
      builder: (_, data, __) {
        if (data.cart.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🛒', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text('Your cart is empty', style: GoogleFonts.inter(fontSize: 18, color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                Text('Browse vendors to add items', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textMuted)),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: data.cart.map((cartItem) => _cartItemCard(cartItem, data)).toList(),
              ),
            ),
            // Checkout Bar
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy,
                border: Border(top: BorderSide(color: AppTheme.cardBorder)),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${data.cartItemCount} items', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                          Text('\$${data.cartTotal.toStringAsFixed(2)}',
                              style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.accentCyan)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: data.isLoading ? null : () => _placeOrder(data),
                      child: data.isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Place Order'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _cartItemCard(CartItem cartItem, AppDataProvider data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cartItem.menuItem.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                Text('\$${cartItem.menuItem.price.toStringAsFixed(2)}', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          // Quantity controls
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _qtyBtn(Icons.remove, () => data.updateCartQuantity(cartItem.menuItem.id, cartItem.quantity - 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('${cartItem.quantity}', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16)),
                ),
                _qtyBtn(Icons.add, () => data.updateCartQuantity(cartItem.menuItem.id, cartItem.quantity + 1)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text('\$${cartItem.total.toStringAsFixed(2)}', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppTheme.accentCyan)),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 18, color: AppTheme.accentCyan),
      ),
    );
  }

  Future<void> _placeOrder(AppDataProvider data) async {
    if (data.cart.isEmpty) return;
    // Use the vendor of the first cart item
    final vendorId = _selectedVendorId ?? data.vendors.first.id;
    final order = await data.placeOrder(vendorId, null);
    if (order != null && mounted) {
      _tabController.animateTo(2); // Switch to Orders tab
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order ${order.orderNumber} placed! 🎉'),
          backgroundColor: AppTheme.accentGreen.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  // ======= ORDERS TAB =======
  Widget _ordersTab() {
    return Consumer<AppDataProvider>(
      builder: (_, data, __) {
        if (data.orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('📦', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text('No orders yet', style: GoogleFonts.inter(fontSize: 18, color: AppTheme.textSecondary)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppTheme.accentCyan,
          onRefresh: () => data.fetchOrders(),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: data.orders.map((o) => _orderCard(o, data)).toList(),
          ),
        );
      },
    );
  }

  Widget _orderCard(OrderModel order, AppDataProvider data) {
    final statusColors = {
      'pending': AppTheme.accentAmber,
      'confirmed': AppTheme.accentBlue,
      'preparing': AppTheme.accentOrange,
      'ready': AppTheme.accentGreen,
      'picked_up': AppTheme.textMuted,
      'cancelled': AppTheme.accentRed,
    };
    final color = statusColors[order.status] ?? AppTheme.textMuted;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('🧾', style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.orderNumber, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15)),
                    Text(order.vendorName, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(order.statusDisplay, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Status Progress
          Row(
            children: List.generate(4, (i) {
              final active = order.statusStep >= i;
              final labels = ['Placed', 'Confirmed', 'Preparing', 'Ready'];
              return Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (i > 0) Expanded(child: Container(height: 3, color: active ? color : AppTheme.surfaceLight)),
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: active ? color : AppTheme.surfaceLight,
                            shape: BoxShape.circle,
                          ),
                          child: active ? const Icon(Icons.check, size: 10, color: Colors.white) : null,
                        ),
                        if (i < 3) Expanded(child: Container(height: 3, color: order.statusStep > i ? color : AppTheme.surfaceLight)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(labels[i], style: GoogleFonts.inter(fontSize: 9, color: active ? color : AppTheme.textMuted)),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('\$${order.totalPrice.toStringAsFixed(2)}', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.accentCyan)),
              if (order.status != 'ready' && order.status != 'picked_up' && order.status != 'cancelled')
                GestureDetector(
                  onTap: () => data.refreshOrder(order.id),
                  child: Row(
                    children: [
                      Icon(Icons.refresh, size: 14, color: AppTheme.accentCyan),
                      const SizedBox(width: 4),
                      Text('Refresh', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.accentCyan)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
