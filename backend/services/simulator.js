const Zone = require('../models/Zone');
const CrowdData = require('../models/CrowdData');
const Queue = require('../models/Queue');

class SimulatorService {
  constructor(io) {
    this.io = io;
    this.interval = null;
  }

  start() {
    console.log('🔄 Real-time simulator started');
    // Update every 5 seconds
    this.interval = setInterval(() => this.tick(), 5000);
  }

  stop() {
    if (this.interval) {
      clearInterval(this.interval);
      this.interval = null;
    }
  }

  async tick() {
    try {
      await this.updateCrowdData();
      await this.updateQueues();
    } catch (err) {
      console.error('Simulator tick error:', err.message);
    }
  }

  async updateCrowdData() {
    const zones = await Zone.find({ isOpen: true });

    for (const zone of zones) {
      // Simulate gradual crowd changes
      const change = Math.floor(Math.random() * 21) - 10; // -10 to +10
      let newOccupancy = zone.currentOccupancy + change;
      newOccupancy = Math.max(0, Math.min(zone.capacity, newOccupancy));

      zone.currentOccupancy = newOccupancy;
      zone.updateDensityLevel();
      await zone.save();

      // Record crowd data snapshot
      const density = zone.getDensityPercentage();
      await CrowdData.create({
        zone: zone._id,
        density,
        occupancy: newOccupancy,
        movementDirection: change > 3 ? 'in' : change < -3 ? 'out' : 'stable',
        sensorCount: Math.floor(Math.random() * 5) + 1,
      });

      // Emit real-time update
      this.io.emit('crowd:update', {
        zoneId: zone._id,
        zoneName: zone.name,
        occupancy: newOccupancy,
        capacity: zone.capacity,
        density,
        densityLevel: zone.densityLevel,
      });
    }
  }

  async updateQueues() {
    const queues = await Queue.find({ status: { $ne: 'closed' } });

    for (const queue of queues) {
      // Simulate queue fluctuations
      const waitChange = (Math.random() * 4) - 2; // -2 to +2 minutes
      let newWait = queue.currentWaitMinutes + waitChange;
      newWait = Math.max(1, Math.min(45, newWait));

      const lengthChange = Math.floor(Math.random() * 7) - 3;
      let newLength = queue.queueLength + lengthChange;
      newLength = Math.max(0, Math.min(queue.maxCapacity, newLength));

      queue.currentWaitMinutes = Math.round(newWait);
      queue.queueLength = newLength;
      queue.trend = waitChange > 0.5 ? 'increasing' : waitChange < -0.5 ? 'decreasing' : 'stable';
      queue.status = newLength > queue.maxCapacity * 0.8 ? 'busy' : 'open';
      await queue.save();

      // Emit real-time update
      this.io.emit('queue:update', {
        queueId: queue._id,
        facilityName: queue.facilityName,
        facilityType: queue.facilityType,
        currentWaitMinutes: queue.currentWaitMinutes,
        queueLength: queue.queueLength,
        status: queue.status,
        trend: queue.trend,
      });
    }
  }
}

module.exports = SimulatorService;
