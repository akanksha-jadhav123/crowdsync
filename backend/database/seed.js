const User = require('../models/User');
const Zone = require('../models/Zone');
const Queue = require('../models/Queue');
const Vendor = require('../models/Vendor');
const MenuItem = require('../models/MenuItem');
const Notification = require('../models/Notification');

async function seedDatabase() {
  console.log('🌱 Seeding database...');

  // Check if already seeded
  const existingUsers = await User.countDocuments();
  if (existingUsers > 0) {
    console.log('  Database already seeded, skipping.');
    return;
  }

  // ======= USERS =======
  const users = await User.create([
    {
      name: 'John Fan',
      email: 'john@crowdsync.com',
      password: 'password123',
      phone: '+1-555-0101',
      seatSection: 'A',
      seatRow: '12',
      seatNumber: '7',
      role: 'user',
    },
    {
      name: 'Admin User',
      email: 'admin@crowdsync.com',
      password: 'admin123',
      phone: '+1-555-0100',
      role: 'admin',
    },
  ]);
  console.log(`  ✅ Created ${users.length} users`);

  // ======= ZONES =======
  const zones = await Zone.create([
    { name: 'Main Gate A', type: 'gate', capacity: 500, currentOccupancy: 180, coordinates: { x: 400, y: 50, width: 120, height: 60 }, floor: 1, facilities: ['Ticket Scanner', 'Security Check'] },
    { name: 'Main Gate B', type: 'gate', capacity: 500, currentOccupancy: 220, coordinates: { x: 400, y: 550, width: 120, height: 60 }, floor: 1, facilities: ['Ticket Scanner', 'Security Check'] },
    { name: 'East Gate', type: 'gate', capacity: 300, currentOccupancy: 90, coordinates: { x: 750, y: 300, width: 60, height: 120 }, floor: 1, facilities: ['Ticket Scanner'] },
    { name: 'West Gate', type: 'gate', capacity: 300, currentOccupancy: 120, coordinates: { x: 100, y: 300, width: 60, height: 120 }, floor: 1, facilities: ['Ticket Scanner'] },
    { name: 'North Stand', type: 'stand', capacity: 5000, currentOccupancy: 3200, coordinates: { x: 250, y: 80, width: 400, height: 100 }, floor: 2, facilities: ['Seating', 'Cup Holders'] },
    { name: 'South Stand', type: 'stand', capacity: 5000, currentOccupancy: 4100, coordinates: { x: 250, y: 480, width: 400, height: 100 }, floor: 2, facilities: ['Seating', 'Cup Holders'] },
    { name: 'East Stand', type: 'stand', capacity: 3000, currentOccupancy: 1800, coordinates: { x: 600, y: 200, width: 100, height: 260 }, floor: 2, facilities: ['Seating', 'Premium View'] },
    { name: 'West Stand', type: 'stand', capacity: 3000, currentOccupancy: 2500, coordinates: { x: 200, y: 200, width: 100, height: 260 }, floor: 2, facilities: ['Seating'] },
    { name: 'VIP Lounge', type: 'vip', capacity: 200, currentOccupancy: 80, coordinates: { x: 350, y: 250, width: 200, height: 60 }, floor: 3, facilities: ['Premium Seating', 'Private Bar', 'AC'] },
    { name: 'Main Concourse', type: 'concourse', capacity: 2000, currentOccupancy: 900, coordinates: { x: 200, y: 150, width: 500, height: 50 }, floor: 1, facilities: ['Walking Area', 'Info Desk'] },
    { name: 'South Concourse', type: 'concourse', capacity: 1500, currentOccupancy: 700, coordinates: { x: 200, y: 460, width: 500, height: 50 }, floor: 1, facilities: ['Walking Area'] },
    { name: 'Food Court A', type: 'food_court', capacity: 400, currentOccupancy: 280, coordinates: { x: 150, y: 380, width: 140, height: 80 }, floor: 1, facilities: ['Food Stalls', 'Seating Area'] },
    { name: 'Food Court B', type: 'food_court', capacity: 350, currentOccupancy: 150, coordinates: { x: 600, y: 380, width: 140, height: 80 }, floor: 1, facilities: ['Food Stalls', 'Beverage Corner'] },
    { name: 'Restroom North', type: 'restroom', capacity: 80, currentOccupancy: 35, coordinates: { x: 170, y: 100, width: 60, height: 50 }, floor: 1, facilities: ['Restroom'] },
    { name: 'Restroom South', type: 'restroom', capacity: 80, currentOccupancy: 55, coordinates: { x: 680, y: 480, width: 60, height: 50 }, floor: 1, facilities: ['Restroom'] },
    { name: 'Restroom East', type: 'restroom', capacity: 60, currentOccupancy: 20, coordinates: { x: 700, y: 200, width: 50, height: 50 }, floor: 1, facilities: ['Restroom'] },
    { name: 'Medical Center', type: 'medical', capacity: 30, currentOccupancy: 5, coordinates: { x: 150, y: 250, width: 80, height: 60 }, floor: 1, facilities: ['First Aid', 'Ambulance Access'] },
    { name: 'Parking Lot A', type: 'parking', capacity: 1000, currentOccupancy: 750, coordinates: { x: 50, y: 50, width: 100, height: 100 }, floor: 0, facilities: ['Parking', 'EV Charging'] },
    { name: 'Playing Field', type: 'field', capacity: 100, currentOccupancy: 30, coordinates: { x: 300, y: 200, width: 300, height: 260 }, floor: 1, facilities: ['Field', 'Pitch'] },
  ]);

  // Set up adjacency graph for navigation
  const zoneByName = {};
  zones.forEach(z => { zoneByName[z.name] = z; });

  const adjacencyMap = {
    'Main Gate A': ['Main Concourse', 'North Stand', 'Parking Lot A'],
    'Main Gate B': ['South Concourse', 'South Stand'],
    'East Gate': ['East Stand', 'South Concourse', 'Main Concourse'],
    'West Gate': ['West Stand', 'Main Concourse', 'South Concourse'],
    'North Stand': ['Main Gate A', 'Main Concourse', 'VIP Lounge'],
    'South Stand': ['Main Gate B', 'South Concourse', 'Food Court A'],
    'East Stand': ['East Gate', 'Main Concourse', 'Food Court B', 'Restroom East'],
    'West Stand': ['West Gate', 'Main Concourse', 'Medical Center'],
    'VIP Lounge': ['North Stand', 'Main Concourse'],
    'Main Concourse': ['Main Gate A', 'North Stand', 'East Stand', 'West Stand', 'VIP Lounge', 'East Gate', 'West Gate', 'Restroom North', 'Food Court B'],
    'South Concourse': ['Main Gate B', 'South Stand', 'East Gate', 'West Gate', 'Food Court A', 'Restroom South'],
    'Food Court A': ['South Stand', 'South Concourse', 'Restroom South'],
    'Food Court B': ['East Stand', 'Main Concourse', 'Restroom East'],
    'Restroom North': ['Main Concourse'],
    'Restroom South': ['South Concourse', 'Food Court A'],
    'Restroom East': ['East Stand', 'Food Court B'],
    'Medical Center': ['West Stand', 'Main Concourse'],
    'Parking Lot A': ['Main Gate A'],
    'Playing Field': [],
  };

  for (const [zoneName, adjNames] of Object.entries(adjacencyMap)) {
    const zone = zoneByName[zoneName];
    if (zone) {
      zone.adjacentZones = adjNames
        .map(n => zoneByName[n]?._id)
        .filter(Boolean);
      zone.updateDensityLevel();
      await zone.save();
    }
  }
  console.log(`  ✅ Created ${zones.length} zones with adjacency graph`);

  // ======= QUEUES =======
  const queues = await Queue.create([
    { zone: zoneByName['Main Gate A']._id, facilityName: 'Gate A Entry', facilityType: 'entry_gate', currentWaitMinutes: 8, queueLength: 45 },
    { zone: zoneByName['Main Gate B']._id, facilityName: 'Gate B Entry', facilityType: 'entry_gate', currentWaitMinutes: 12, queueLength: 65, status: 'busy' },
    { zone: zoneByName['East Gate']._id, facilityName: 'East Gate Entry', facilityType: 'entry_gate', currentWaitMinutes: 3, queueLength: 15 },
    { zone: zoneByName['Main Gate A']._id, facilityName: 'Gate A Exit', facilityType: 'exit_gate', currentWaitMinutes: 2, queueLength: 10 },
    { zone: zoneByName['Restroom North']._id, facilityName: 'North Restroom', facilityType: 'restroom', currentWaitMinutes: 5, queueLength: 12 },
    { zone: zoneByName['Restroom South']._id, facilityName: 'South Restroom', facilityType: 'restroom', currentWaitMinutes: 15, queueLength: 30, status: 'busy' },
    { zone: zoneByName['Restroom East']._id, facilityName: 'East Restroom', facilityType: 'restroom', currentWaitMinutes: 3, queueLength: 8 },
    { zone: zoneByName['Food Court A']._id, facilityName: 'Food Court A Counter', facilityType: 'food_stall', currentWaitMinutes: 10, queueLength: 25 },
    { zone: zoneByName['Food Court B']._id, facilityName: 'Food Court B Counter', facilityType: 'food_stall', currentWaitMinutes: 6, queueLength: 14 },
    { zone: zoneByName['Main Concourse']._id, facilityName: 'Merchandise Store', facilityType: 'merchandise', currentWaitMinutes: 7, queueLength: 18 },
  ]);
  console.log(`  ✅ Created ${queues.length} queues`);

  // ======= VENDORS =======
  const vendors = await Vendor.create([
    { name: 'Stadium Burgers', zone: zoneByName['Food Court A']._id, cuisineType: 'American', description: 'Fresh grilled burgers and fries', rating: 4.3, avgPrepMinutes: 12, imageUrl: 'burger' },
    { name: 'Pizza Corner', zone: zoneByName['Food Court A']._id, cuisineType: 'Italian', description: 'Wood-fired pizzas and pasta', rating: 4.5, avgPrepMinutes: 15, imageUrl: 'pizza' },
    { name: 'Taco Express', zone: zoneByName['Food Court B']._id, cuisineType: 'Mexican', description: 'Authentic tacos and burritos', rating: 4.2, avgPrepMinutes: 8, imageUrl: 'taco' },
    { name: 'Sushi Roll', zone: zoneByName['Food Court B']._id, cuisineType: 'Japanese', description: 'Fresh sushi and ramen bowls', rating: 4.6, avgPrepMinutes: 10, imageUrl: 'sushi' },
    { name: 'Drink Hub', zone: zoneByName['Food Court A']._id, cuisineType: 'Beverages', description: 'Cold drinks, smoothies, and coffee', rating: 4.1, avgPrepMinutes: 5, imageUrl: 'drinks' },
    { name: 'Ice Cream Parlor', zone: zoneByName['Food Court B']._id, cuisineType: 'Desserts', description: 'Premium ice cream and frozen treats', rating: 4.4, avgPrepMinutes: 5, imageUrl: 'icecream' },
  ]);

  // ======= MENU ITEMS =======
  const menuItems = [
    // Stadium Burgers
    { vendor: vendors[0]._id, name: 'Classic Burger', description: 'Angus beef patty with lettuce, tomato, and special sauce', price: 8.99, category: 'meals', isVeg: false, preparationTime: 12 },
    { vendor: vendors[0]._id, name: 'Cheese Burger', description: 'Double cheese with caramelized onions', price: 10.99, category: 'meals', isVeg: false, preparationTime: 12 },
    { vendor: vendors[0]._id, name: 'Veggie Burger', description: 'Plant-based patty with avocado', price: 9.99, category: 'meals', isVeg: true, preparationTime: 10 },
    { vendor: vendors[0]._id, name: 'Loaded Fries', description: 'Crispy fries with cheese sauce and jalapeños', price: 5.99, category: 'snacks', isVeg: true, preparationTime: 8 },
    { vendor: vendors[0]._id, name: 'Onion Rings', description: 'Beer-battered crispy onion rings', price: 4.99, category: 'snacks', isVeg: true, preparationTime: 6 },
    // Pizza Corner
    { vendor: vendors[1]._id, name: 'Margherita Pizza', description: 'Classic tomato, mozzarella, and basil', price: 11.99, category: 'meals', isVeg: true, preparationTime: 15 },
    { vendor: vendors[1]._id, name: 'Pepperoni Pizza', description: 'Loaded with spicy pepperoni', price: 13.99, category: 'meals', isVeg: false, preparationTime: 15 },
    { vendor: vendors[1]._id, name: 'Garlic Bread', description: 'Toasted with garlic butter and herbs', price: 4.99, category: 'snacks', isVeg: true, preparationTime: 8 },
    // Taco Express
    { vendor: vendors[2]._id, name: 'Beef Tacos (3pc)', description: 'Seasoned beef with salsa and cheese', price: 7.99, category: 'meals', isVeg: false, preparationTime: 8 },
    { vendor: vendors[2]._id, name: 'Chicken Burrito', description: 'Grilled chicken with rice, beans, and guac', price: 9.99, category: 'meals', isVeg: false, preparationTime: 10 },
    { vendor: vendors[2]._id, name: 'Nachos Grande', description: 'Loaded nachos with all the toppings', price: 8.99, category: 'snacks', isVeg: true, preparationTime: 7 },
    // Sushi Roll
    { vendor: vendors[3]._id, name: 'California Roll', description: 'Crab, avocado, cucumber roll (8pc)', price: 10.99, category: 'meals', isVeg: false, preparationTime: 10 },
    { vendor: vendors[3]._id, name: 'Spicy Tuna Roll', description: 'Fresh tuna with spicy mayo (8pc)', price: 12.99, category: 'meals', isVeg: false, preparationTime: 10 },
    { vendor: vendors[3]._id, name: 'Edamame', description: 'Steamed soybeans with sea salt', price: 4.99, category: 'snacks', isVeg: true, preparationTime: 5 },
    // Drink Hub
    { vendor: vendors[4]._id, name: 'Iced Cola', description: 'Classic cola with ice', price: 3.99, category: 'beverages', isVeg: true, preparationTime: 2 },
    { vendor: vendors[4]._id, name: 'Fresh Lemonade', description: 'Hand-squeezed lemonade with mint', price: 4.99, category: 'beverages', isVeg: true, preparationTime: 3 },
    { vendor: vendors[4]._id, name: 'Mango Smoothie', description: 'Fresh mango blended with yogurt', price: 6.99, category: 'beverages', isVeg: true, preparationTime: 5 },
    { vendor: vendors[4]._id, name: 'Hot Coffee', description: 'Freshly brewed premium coffee', price: 3.99, category: 'beverages', isVeg: true, preparationTime: 3 },
    // Ice Cream Parlor
    { vendor: vendors[5]._id, name: 'Vanilla Scoop', description: 'Premium vanilla bean ice cream', price: 4.99, category: 'desserts', isVeg: true, preparationTime: 3 },
    { vendor: vendors[5]._id, name: 'Chocolate Sundae', description: 'Rich chocolate with hot fudge and whipped cream', price: 7.99, category: 'desserts', isVeg: true, preparationTime: 5 },
    { vendor: vendors[5]._id, name: 'Waffle Cone Special', description: 'Two scoops in a fresh waffle cone', price: 6.99, category: 'desserts', isVeg: true, preparationTime: 4 },
  ];

  await MenuItem.create(menuItems);
  console.log(`  ✅ Created ${vendors.length} vendors with ${menuItems.length} menu items`);

  // ======= WELCOME NOTIFICATION =======
  await Notification.create({
    user: users[0]._id,
    title: 'Welcome to CrowdSync! 🏟️',
    message: 'Your smart stadium experience starts now. Explore the heatmap, check wait times, and order food from your seat!',
    type: 'info',
    isBroadcast: false,
  });
  await Notification.create({
    user: users[0]._id,
    title: 'Match Day Alert ⚽',
    message: 'Today\'s match starts at 7:00 PM. Gate A has the shortest entry queue right now.',
    type: 'warning',
  });
  await Notification.create({
    user: users[0]._id,
    title: 'Special Offer 🍕',
    message: 'Get 20% off at Pizza Corner until halftime! Use code GOAL20.',
    type: 'promo',
  });
  console.log('  ✅ Created welcome notifications');

  console.log('🌱 Database seeding complete!');
}

module.exports = seedDatabase;
