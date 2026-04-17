const express = require('express');
const navigationService = require('../services/navigation');
const auth = require('../middleware/auth');
const router = express.Router();

// GET /api/navigation/route?from=zoneId&to=zoneId&mode=leastCrowded
router.get('/route', auth, async (req, res) => {
  try {
    const { from, to, mode } = req.query;
    if (!from || !to) {
      return res.status(400).json({ error: 'from and to zone IDs are required' });
    }

    const preferLeastCrowded = mode !== 'shortest';
    const result = await navigationService.findRoute(from, to, preferLeastCrowded);

    res.json({
      route: result.route,
      totalWeight: result.totalWeight,
      estimatedMinutes: result.estimatedMinutes,
      mode: preferLeastCrowded ? 'leastCrowded' : 'shortest',
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/navigation/nearby/:type?from=zoneId
router.get('/nearby/:type', auth, async (req, res) => {
  try {
    const { type } = req.params;
    const { from, limit } = req.query;

    const results = await navigationService.findNearby(
      from, type, parseInt(limit) || 5
    );

    res.json({ nearby: results });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
