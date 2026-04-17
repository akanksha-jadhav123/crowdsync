const Zone = require('../models/Zone');

class NavigationService {
  /**
   * Find the optimal route between two zones using Dijkstra's algorithm.
   * Weights edges by crowd density so least-congested paths are preferred.
   */
  async findRoute(fromZoneId, toZoneId, preferLeastCrowded = true) {
    const zones = await Zone.find({ isOpen: true }).populate('adjacentZones');
    const zoneMap = new Map();
    zones.forEach(z => zoneMap.set(z._id.toString(), z));

    const from = fromZoneId.toString();
    const to = toZoneId.toString();

    if (!zoneMap.has(from) || !zoneMap.has(to)) {
      return { route: [], totalWeight: Infinity, estimatedMinutes: 0 };
    }

    // Dijkstra
    const dist = new Map();
    const prev = new Map();
    const visited = new Set();
    const pq = []; // priority queue as sorted array (simple approach)

    zones.forEach(z => {
      dist.set(z._id.toString(), Infinity);
      prev.set(z._id.toString(), null);
    });
    dist.set(from, 0);
    pq.push({ id: from, cost: 0 });

    while (pq.length > 0) {
      pq.sort((a, b) => a.cost - b.cost);
      const { id: current } = pq.shift();

      if (visited.has(current)) continue;
      visited.add(current);

      if (current === to) break;

      const zone = zoneMap.get(current);
      if (!zone || !zone.adjacentZones) continue;

      for (const adj of zone.adjacentZones) {
        const adjId = (adj._id || adj).toString();
        if (visited.has(adjId)) continue;

        const adjZone = zoneMap.get(adjId);
        if (!adjZone) continue;

        // Weight: base distance + crowd penalty
        let weight = 1;
        if (preferLeastCrowded) {
          const density = adjZone.getDensityPercentage();
          weight += density / 25; // 0-4 extra weight based on crowding
        }

        const newDist = dist.get(current) + weight;
        if (newDist < dist.get(adjId)) {
          dist.set(adjId, newDist);
          prev.set(adjId, current);
          pq.push({ id: adjId, cost: newDist });
        }
      }
    }

    // Reconstruct path
    const route = [];
    let cur = to;
    while (cur) {
      const zone = zoneMap.get(cur);
      if (zone) {
        route.unshift({
          zoneId: zone._id,
          name: zone.name,
          type: zone.type,
          densityLevel: zone.densityLevel,
          density: zone.getDensityPercentage(),
        });
      }
      cur = prev.get(cur);
    }

    const totalWeight = dist.get(to);
    const estimatedMinutes = Math.round(totalWeight * 2); // ~2 min per edge

    return { route, totalWeight, estimatedMinutes };
  }

  /**
   * Find nearby zones of a specific type (restroom, food_court, etc.)
   * sorted by least crowded first.
   */
  async findNearby(fromZoneId, facilityType, limit = 5) {
    const zones = await Zone.find({ type: facilityType, isOpen: true });
    
    // Sort by density (least crowded first)
    zones.sort((a, b) => a.getDensityPercentage() - b.getDensityPercentage());

    return zones.slice(0, limit).map(z => ({
      zoneId: z._id,
      name: z.name,
      type: z.type,
      densityLevel: z.densityLevel,
      density: z.getDensityPercentage(),
      occupancy: z.currentOccupancy,
      capacity: z.capacity,
    }));
  }
}

module.exports = new NavigationService();
