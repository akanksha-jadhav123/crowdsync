const express = require('express');
const Queue = require('../models/Queue');
const auth = require('../middleware/auth');
const router = express.Router();

// GET /api/queues - Get all queues
router.get('/', auth, async (req, res) => {
  try {
    const { type, status } = req.query;
    const filter = {};
    if (type) filter.facilityType = type;
    if (status) filter.status = status;

    const queues = await Queue.find(filter).populate('zone', 'name type');
    res.json({ queues });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/queues/:id - Get specific queue details
router.get('/:id', auth, async (req, res) => {
  try {
    const queue = await Queue.findById(req.params.id).populate('zone', 'name type');
    if (!queue) return res.status(404).json({ error: 'Queue not found' });
    res.json({ queue });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/queues/zone/:zoneId - Get queues for a specific zone
router.get('/zone/:zoneId', auth, async (req, res) => {
  try {
    const queues = await Queue.find({ zone: req.params.zoneId });
    res.json({ queues });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/queues/stats/summary - Get queue statistics
router.get('/stats/summary', auth, async (req, res) => {
  try {
    const queues = await Queue.find({});
    const avgWait = queues.length > 0
      ? Math.round(queues.reduce((s, q) => s + q.currentWaitMinutes, 0) / queues.length)
      : 0;
    const busyCount = queues.filter(q => q.status === 'busy').length;
    const longestWait = queues.reduce((max, q) => Math.max(max, q.currentWaitMinutes), 0);
    const shortestWait = queues.reduce((min, q) => Math.min(min, q.currentWaitMinutes), Infinity);

    res.json({
      stats: {
        totalQueues: queues.length,
        avgWaitMinutes: avgWait,
        busyQueues: busyCount,
        longestWaitMinutes: longestWait,
        shortestWaitMinutes: shortestWait === Infinity ? 0 : shortestWait,
      },
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
