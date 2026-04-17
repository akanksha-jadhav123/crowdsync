const mongoose = require('mongoose');

const crowdDataSchema = new mongoose.Schema({
  zone: { type: mongoose.Schema.Types.ObjectId, ref: 'Zone', required: true },
  timestamp: { type: Date, default: Date.now },
  density: { type: Number, min: 0, max: 100, required: true },
  occupancy: { type: Number, required: true },
  movementDirection: { type: String, enum: ['in', 'out', 'stable'], default: 'stable' },
  sensorCount: { type: Number, default: 0 },
}, { timestamps: true });

crowdDataSchema.index({ zone: 1, timestamp: -1 });

module.exports = mongoose.model('CrowdData', crowdDataSchema);
