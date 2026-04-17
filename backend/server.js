require('dotenv').config();
const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');
const { connectDB } = require('./config/db');
const seedDatabase = require('./database/seed');
const SimulatorService = require('./services/simulator');

// Import routes
const userRoutes = require('./routes/users');
const crowdRoutes = require('./routes/crowd');
const navigationRoutes = require('./routes/navigation');
const queueRoutes = require('./routes/queues');
const foodRoutes = require('./routes/food');
const emergencyRoutes = require('./routes/emergency');
const notificationRoutes = require('./routes/notifications');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: '*', methods: ['GET', 'POST', 'PUT', 'DELETE'] },
});

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logging
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} ${req.method} ${req.url}`);
  next();
});

// API Routes
app.use('/api/users', userRoutes);
app.use('/api/crowd', crowdRoutes);
app.use('/api/navigation', navigationRoutes);
app.use('/api/queues', queueRoutes);
app.use('/api/food', foodRoutes);
app.use('/api/emergency', emergencyRoutes);
app.use('/api/notifications', notificationRoutes);

// Health check
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    name: 'CrowdSync API',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
  });
});

// Socket.io connection handling
io.on('connection', (socket) => {
  console.log(`🔌 Client connected: ${socket.id}`);

  socket.on('join:zone', (zoneId) => {
    socket.join(`zone:${zoneId}`);
    console.log(`  Socket ${socket.id} joined zone:${zoneId}`);
  });

  socket.on('leave:zone', (zoneId) => {
    socket.leave(`zone:${zoneId}`);
  });

  socket.on('disconnect', () => {
    console.log(`🔌 Client disconnected: ${socket.id}`);
  });
});

// Start server
const PORT = process.env.PORT || 3000;

async function startServer() {
  try {
    // Connect to MongoDB (in-memory)
    await connectDB();

    // Seed database with sample data
    await seedDatabase();

    // Start real-time simulator
    const simulator = new SimulatorService(io);
    simulator.start();

    server.listen(PORT, '0.0.0.0', () => {
      console.log('');
      console.log('╔════════════════════════════════════════════╗');
      console.log('║          🏟️  CrowdSync API Server          ║');
      console.log('╠════════════════════════════════════════════╣');
      console.log(`║  🌐 HTTP:   http://localhost:${PORT}          ║`);
      console.log(`║  🔌 WS:     ws://localhost:${PORT}             ║`);
      console.log('║  📊 Health: http://localhost:' + PORT + '/api/health ║');
      console.log('╠════════════════════════════════════════════╣');
      console.log('║  Demo Login:                               ║');
      console.log('║  📧 john@crowdsync.com / password123       ║');
      console.log('╚════════════════════════════════════════════╝');
      console.log('');
    });
  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
}

startServer();
