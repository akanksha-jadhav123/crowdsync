const mongoose = require('mongoose');

const emergencySchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  type: { 
    type: String, 
    enum: ['medical', 'fire', 'security', 'lost_child', 'evacuation', 'other'],
    required: true 
  },
  locationZone: { type: mongoose.Schema.Types.ObjectId, ref: 'Zone' },
  locationDescription: { type: String, default: '' },
  description: { type: String, required: true },
  status: { 
    type: String, 
    enum: ['reported', 'acknowledged', 'responding', 'resolved'],
    default: 'reported' 
  },
  priority: { 
    type: String, 
    enum: ['low', 'medium', 'high', 'critical'],
    default: 'high' 
  },
  assignedTo: { type: String, default: '' },
  resolvedAt: { type: Date },
  notes: [{ 
    text: String, 
    author: String, 
    timestamp: { type: Date, default: Date.now } 
  }],
}, { timestamps: true });

module.exports = mongoose.model('Emergency', emergencySchema);
