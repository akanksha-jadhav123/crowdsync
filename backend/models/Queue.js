const mongoose = require('mongoose');

const queueSchema = new mongoose.Schema({
  zone: { type: mongoose.Schema.Types.ObjectId, ref: 'Zone', required: true },
  facilityName: { type: String, required: true },
  facilityType: { 
    type: String, 
    enum: ['food_stall', 'restroom', 'entry_gate', 'exit_gate', 'ticket_counter', 'merchandise'],
    required: true 
  },
  currentWaitMinutes: { type: Number, default: 0 },
  queueLength: { type: Number, default: 0 },
  maxCapacity: { type: Number, default: 50 },
  status: { 
    type: String, 
    enum: ['open', 'busy', 'closed'], 
    default: 'open' 
  },
  trend: { type: String, enum: ['increasing', 'decreasing', 'stable'], default: 'stable' },
}, { timestamps: true });

module.exports = mongoose.model('Queue', queueSchema);
