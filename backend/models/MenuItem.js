const mongoose = require('mongoose');

const menuItemSchema = new mongoose.Schema({
  vendor: { type: mongoose.Schema.Types.ObjectId, ref: 'Vendor', required: true },
  name: { type: String, required: true },
  description: { type: String, default: '' },
  price: { type: Number, required: true, min: 0 },
  category: { 
    type: String, 
    enum: ['snacks', 'meals', 'beverages', 'desserts', 'combos'],
    required: true 
  },
  imageUrl: { type: String, default: '' },
  isAvailable: { type: Boolean, default: true },
  isVeg: { type: Boolean, default: false },
  preparationTime: { type: Number, default: 10 },
}, { timestamps: true });

module.exports = mongoose.model('MenuItem', menuItemSchema);
