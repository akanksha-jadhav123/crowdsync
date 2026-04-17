const express = require('express');
const Zone = require('../models/Zone');
const CrowdData = require('../models/CrowdData');
const auth = require('../middleware/auth');
const router = express.Router();

// GET /api/crowd/zones - Get all zones with current crowd data
router.get('/zones', auth, async (req, res) => {
  try {
    const zones = await Zone.find({ isOpen: true });
    const zonesData = zones.map(z => ({
      id: z._id,
      name: z.name,
      type: z.type,
      capacity: z.capacity,
      currentOccupancy: z.currentOccupancy,
      density: z.getDensityPercentage(),
      densityLevel: z.densityLevel,
      coordinates: z.coordinates,
      floor: z.floor,
      facilities: z.facilities,
    }));
    res.json({ zones: zonesData });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/crowd/zones/:id - Get specific zone details
router.get('/zones/:id', auth, async (req, res) => {
  try {
    const zone = await Zone.findById(req.params.id);
    if (!zone) return res.status(404).json({ error: 'Zone not found' });

    const history = await CrowdData.find({ zone: zone._id })
      .sort({ timestamp: -1 })
      .limit(20);

    res.json({
      zone: {
        id: zone._id,
        name: zone.name,
        type: zone.type,
        capacity: zone.capacity,
        currentOccupancy: zone.currentOccupancy,
        density: zone.getDensityPercentage(),
        densityLevel: zone.densityLevel,
        coordinates: zone.coordinates,
        floor: zone.floor,
        facilities: zone.facilities,
      },
      history: history.map(h => ({
        timestamp: h.timestamp,
        density: h.density,
        occupancy: h.occupancy,
        movement: h.movementDirection,
      })),
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/crowd/heatmap - Get heatmap data for all zones
router.get('/heatmap', auth, async (req, res) => {
  try {
    const zones = await Zone.find({ isOpen: true });
    const heatmapData = zones.map(z => ({
      zoneId: z._id,
      name: z.name,
      type: z.type,
      density: z.getDensityPercentage(),
      densityLevel: z.densityLevel,
      coordinates: z.coordinates,
      occupancy: z.currentOccupancy,
      capacity: z.capacity,
    }));
    res.json({ heatmap: heatmapData });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/crowd/stats - Get aggregated crowd stats
router.get('/stats', auth, async (req, res) => {
  try {
    const zones = await Zone.find({ isOpen: true });
    const totalCapacity = zones.reduce((sum, z) => sum + z.capacity, 0);
    const totalOccupancy = zones.reduce((sum, z) => sum + z.currentOccupancy, 0);
    const avgDensity = totalCapacity > 0 ? Math.round((totalOccupancy / totalCapacity) * 100) : 0;

    const densityCounts = { low: 0, medium: 0, high: 0 };
    zones.forEach(z => densityCounts[z.densityLevel]++);

    res.json({
      stats: {
        totalZones: zones.length,
        totalCapacity,
        totalOccupancy,
        avgDensity,
        densityCounts,
        overallLevel: avgDensity < 40 ? 'low' : avgDensity < 75 ? 'medium' : 'high',
      },
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
