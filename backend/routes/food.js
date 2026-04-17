const express = require('express');
const Vendor = require('../models/Vendor');
const MenuItem = require('../models/MenuItem');
const Order = require('../models/Order');
const auth = require('../middleware/auth');
const router = express.Router();

// GET /api/food/vendors - List all food vendors
router.get('/vendors', auth, async (req, res) => {
  try {
    const { cuisine, open } = req.query;
    const filter = {};
    if (cuisine) filter.cuisineType = cuisine;
    if (open === 'true') filter.isOpen = true;

    const vendors = await Vendor.find(filter).populate('zone', 'name');
    res.json({ vendors });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/food/vendors/:id - Get vendor with menu
router.get('/vendors/:id', auth, async (req, res) => {
  try {
    const vendor = await Vendor.findById(req.params.id).populate('zone', 'name');
    if (!vendor) return res.status(404).json({ error: 'Vendor not found' });

    const menu = await MenuItem.find({ vendor: vendor._id, isAvailable: true });
    res.json({ vendor, menu });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/food/menu/:vendorId - Get menu for a vendor
router.get('/menu/:vendorId', auth, async (req, res) => {
  try {
    const menu = await MenuItem.find({ vendor: req.params.vendorId });
    res.json({ menu });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST /api/food/orders - Place a new order
router.post('/orders', auth, async (req, res) => {
  try {
    const { vendorId, items, specialInstructions } = req.body;

    const vendor = await Vendor.findById(vendorId);
    if (!vendor) return res.status(404).json({ error: 'Vendor not found' });
    if (!vendor.isOpen) return res.status(400).json({ error: 'Vendor is currently closed' });

    // Calculate total price
    let totalPrice = 0;
    const orderItems = [];

    for (const item of items) {
      const menuItem = await MenuItem.findById(item.menuItemId);
      if (!menuItem) {
        return res.status(400).json({ error: `Menu item ${item.menuItemId} not found` });
      }
      const qty = item.quantity || 1;
      totalPrice += menuItem.price * qty;
      orderItems.push({
        menuItem: menuItem._id,
        name: menuItem.name,
        price: menuItem.price,
        quantity: qty,
      });
    }

    const order = await Order.create({
      user: req.userId,
      vendor: vendorId,
      items: orderItems,
      totalPrice,
      specialInstructions: specialInstructions || '',
      estimatedReadyTime: new Date(Date.now() + vendor.avgPrepMinutes * 60000),
      pickupLocation: `${vendor.name} Counter`,
    });

    // Auto-progress order status after delays
    setTimeout(async () => {
      await Order.findByIdAndUpdate(order._id, { status: 'confirmed' });
    }, 3000);
    setTimeout(async () => {
      await Order.findByIdAndUpdate(order._id, { status: 'preparing' });
    }, 8000);
    setTimeout(async () => {
      await Order.findByIdAndUpdate(order._id, { status: 'ready' });
    }, 20000);

    res.status(201).json({ order });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/food/orders - Get user's orders
router.get('/orders', auth, async (req, res) => {
  try {
    const orders = await Order.find({ user: req.userId })
      .populate('vendor', 'name cuisineType')
      .sort({ createdAt: -1 });
    res.json({ orders });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/food/orders/:id - Get specific order
router.get('/orders/:id', auth, async (req, res) => {
  try {
    const order = await Order.findOne({ _id: req.params.id, user: req.userId })
      .populate('vendor', 'name cuisineType');
    if (!order) return res.status(404).json({ error: 'Order not found' });
    res.json({ order });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// PUT /api/food/orders/:id/status - Update order status
router.put('/orders/:id/status', auth, async (req, res) => {
  try {
    const { status } = req.body;
    const order = await Order.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true }
    ).populate('vendor', 'name cuisineType');

    if (!order) return res.status(404).json({ error: 'Order not found' });
    res.json({ order });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
