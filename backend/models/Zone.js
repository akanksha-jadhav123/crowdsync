const mongoose = require('mongoose');

const zoneSchema = new mongoose.Schema({
  name: { type: String, required: true },
  type: { 
    type: String, 
    enum: ['gate', 'concourse', 'stand', 'restroom', 'food_court', 'parking', 'medical', 'vip', 'field'],
    required: true 
  },
  capacity: { type: Number, required: true },
  currentOccupancy: { type: Number, default: 0 },
  densityLevel: { 
    type: String, 
    enum: ['low', 'medium', 'high'], 
    default: 'low' 
  },
  coordinates: {
    x: { type: Number, required: true },
    y: { type: Number, required: true },
    width: { type: Number, default: 100 },
    height: { type: Number, default: 100 },
  },
  floor: { type: Number, default: 1 },
  facilities: [String],
  adjacentZones: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Zone' }],
  isOpen: { type: Boolean, default: true },
}, { timestamps: true });

zoneSchema.methods.getDensityPercentage = function () {
  if (this.capacity === 0) return 0;
  return Math.round((this.currentOccupancy / this.capacity) * 100);
};

zoneSchema.methods.updateDensityLevel = function () {
  const pct = this.getDensityPercentage();
  if (pct < 40) this.densityLevel = 'low';
  else if (pct < 75) this.densityLevel = 'medium';
  else this.densityLevel = 'high';
};

module.exports = mongoose.model('Zone', zoneSchema);
