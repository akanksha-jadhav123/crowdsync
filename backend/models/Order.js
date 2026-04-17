const mongoose = require('mongoose');

const orderSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  vendor: { type: mongoose.Schema.Types.ObjectId, ref: 'Vendor', required: true },
  items: [{
    menuItem: { type: mongoose.Schema.Types.ObjectId, ref: 'MenuItem' },
    name: String,
    price: Number,
    quantity: { type: Number, default: 1 },
  }],
  totalPrice: { type: Number, required: true },
  status: { 
    type: String, 
    enum: ['pending', 'confirmed', 'preparing', 'ready', 'picked_up', 'cancelled'],
    default: 'pending' 
  },
  specialInstructions: { type: String, default: '' },
  estimatedReadyTime: { type: Date },
  pickupLocation: { type: String, default: '' },
  orderNumber: { type: String, unique: true },
}, { timestamps: true });

orderSchema.pre('save', function (next) {
  if (!this.orderNumber) {
    this.orderNumber = 'CS-' + Date.now().toString(36).toUpperCase() + Math.random().toString(36).substring(2, 5).toUpperCase();
  }
  if (!this.estimatedReadyTime) {
    this.estimatedReadyTime = new Date(Date.now() + 15 * 60000);
  }
  next();
});

module.exports = mongoose.model('Order', orderSchema);
