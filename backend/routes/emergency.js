const express = require('express');
const Emergency = require('../models/Emergency');
const Notification = require('../models/Notification');
const auth = require('../middleware/auth');
const router = express.Router();

// POST /api/emergency - Report an emergency
router.post('/', auth, async (req, res) => {
  try {
    const { type, locationZone, locationDescription, description, priority } = req.body;

    const emergency = await Emergency.create({
      user: req.userId,
      type,
      locationZone,
      locationDescription: locationDescription || '',
      description,
      priority: priority || 'high',
    });

    // Create notification for the user
    await Notification.create({
      user: req.userId,
      title: 'Emergency Reported',
      message: `Your ${type} emergency has been reported. Help is on the way.`,
      type: 'emergency',
      data: { emergencyId: emergency._id },
    });

    // Simulate acknowledgment after 5 seconds
    setTimeout(async () => {
      await Emergency.findByIdAndUpdate(emergency._id, {
        status: 'acknowledged',
        assignedTo: 'Security Team Alpha',
      });
    }, 5000);

    // Simulate response after 15 seconds
    setTimeout(async () => {
      await Emergency.findByIdAndUpdate(emergency._id, {
        status: 'responding',
        $push: { notes: { text: 'Response team dispatched to your location', author: 'System' } },
      });
    }, 15000);

    res.status(201).json({ emergency });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/emergency - Get user's emergencies
router.get('/', auth, async (req, res) => {
  try {
    const emergencies = await Emergency.find({ user: req.userId })
      .populate('locationZone', 'name type')
      .sort({ createdAt: -1 });
    res.json({ emergencies });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/emergency/active - Get active emergencies
router.get('/active', auth, async (req, res) => {
  try {
    const emergencies = await Emergency.find({
      status: { $in: ['reported', 'acknowledged', 'responding'] },
    })
      .populate('locationZone', 'name type')
      .populate('user', 'name')
      .sort({ createdAt: -1 });
    res.json({ emergencies });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/emergency/:id - Get specific emergency
router.get('/:id', auth, async (req, res) => {
  try {
    const emergency = await Emergency.findById(req.params.id)
      .populate('locationZone', 'name type')
      .populate('user', 'name');
    if (!emergency) return res.status(404).json({ error: 'Emergency not found' });
    res.json({ emergency });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// PUT /api/emergency/:id/resolve - Resolve an emergency
router.put('/:id/resolve', auth, async (req, res) => {
  try {
    const emergency = await Emergency.findByIdAndUpdate(
      req.params.id,
      {
        status: 'resolved',
        resolvedAt: new Date(),
        $push: { notes: { text: req.body.resolution || 'Emergency resolved', author: 'System' } },
      },
      { new: true }
    );

    if (!emergency) return res.status(404).json({ error: 'Emergency not found' });

    await Notification.create({
      user: emergency.user,
      title: 'Emergency Resolved',
      message: `Your ${emergency.type} emergency has been resolved.`,
      type: 'info',
    });

    res.json({ emergency });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
