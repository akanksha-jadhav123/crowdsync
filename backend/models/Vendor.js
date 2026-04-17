const mongoose = require('mongoose');

const vendorSchema = new mongoose.Schema({
  name: { type: String, required: true },
  zone: { type: mongoose.Schema.Types.ObjectId, ref: 'Zone', required: true },
  cuisineType: { type: String, required: true },
  description: { type: String, default: '' },
  imageUrl: { type: String, default: '' },
  rating: { type: Number, min: 0, max: 5, default: 4.0 },
  isOpen: { type: Boolean, default: true },
  avgPrepMinutes: { type: Number, default: 10 },
  operatingHours: {
    open: { type: String, default: '10:00' },
    close: { type: String, default: '22:00' },
  },
}, { timestamps: true });

module.exports = mongoose.model('Vendor', vendorSchema);
