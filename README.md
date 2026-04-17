# 🏟️ CrowdSync — Smart Stadium Experience

A complete full-stack mobile application designed to enhance physical event experiences in large-scale sporting venues by solving crowd congestion, long waiting times, navigation difficulties, and lack of real-time coordination.

## 🎯 Features

| Feature | Description |
|---------|-------------|
| **Real-time Crowd Monitoring** | Zone-based density visualization (low/medium/high) with live heatmap |
| **Smart Navigation** | Shortest and least-congested routes via Dijkstra pathfinding |
| **Queue Tracking** | Live wait times for food stalls, restrooms, gates with trends |
| **Food Ordering** | Browse vendors, add to cart, place orders, track status in real-time |
| **Emergency System** | One-tap SOS, emergency type selection, response tracking |
| **Notifications** | Real-time alerts, event updates, promotional offers |
| **User Profile** | Seat assignment, order history, preferences |

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter (Dart) with Provider state management |
| Backend | Node.js + Express.js |
| Database | MongoDB (in-memory via mongodb-memory-server — no installation needed) |
| Real-time | Socket.io WebSocket server |
| Auth | JWT (JSON Web Tokens) |

## 📁 Project Structure

```
crowdsync/
├── backend/                     # Node.js API Server
│   ├── server.js               # Express + Socket.io entry point
│   ├── config/db.js            # MongoDB connection
│   ├── database/seed.js        # Seed data (19 zones, 6 vendors, 21 menu items)
│   ├── middleware/auth.js      # JWT authentication
│   ├── models/                 # Mongoose models
│   │   ├── User.js, Zone.js, CrowdData.js, Queue.js
│   │   ├── Vendor.js, MenuItem.js, Order.js
│   │   ├── Emergency.js, Notification.js
│   ├── routes/                 # REST API routes
│   │   ├── users.js, crowd.js, navigation.js
│   │   ├── queues.js, food.js, emergency.js, notifications.js
│   └── services/
│       ├── simulator.js        # Real-time crowd/queue data simulator
│       └── navigation.js       # Dijkstra pathfinding service
│
└── frontend/                    # Flutter Mobile App
    └── lib/
        ├── main.dart
        ├── config/             # Theme & API config
        ├── models/             # Data models
        ├── services/           # API service (HTTP)
        ├── providers/          # State management (Provider)
        └── screens/            # All app screens
            ├── login_screen.dart
            ├── home_shell.dart
            ├── dashboard_screen.dart
            ├── stadium_map_screen.dart
            ├── queue_screen.dart
            ├── food_order_screen.dart
            ├── emergency_screen.dart
            ├── notifications_screen.dart
            └── profile_screen.dart
```

## 🚀 Setup & Run

### Prerequisites
- **Node.js** v18+
- **Flutter** v3.10+
- **Android Emulator** or physical device (or Chrome for web)

### 1. Start Backend Server

```bash
cd backend
npm install
npm start
```

The server starts at `http://localhost:3000` with:
- In-memory MongoDB (auto-created, no install needed)
- Pre-seeded data (users, zones, vendors, menus, queues)
- Real-time simulator running (crowd/queue updates every 5s)

### 2. Run Flutter App

```bash
cd frontend

# Enable Developer Mode (Windows)
start ms-settings:developers

# Get dependencies
flutter pub get

# Run on emulator or device
flutter run

# Or run on Chrome
flutter run -d chrome
```

### Demo Login
- **Email:** `john@crowdsync.com`
- **Password:** `password123`

## 📡 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/users/register` | Register new user |
| POST | `/api/users/login` | Login, get JWT token |
| GET | `/api/users/profile` | Get user profile |
| GET | `/api/crowd/zones` | Get all zones with density |
| GET | `/api/crowd/heatmap` | Get heatmap data |
| GET | `/api/crowd/stats` | Get aggregate crowd stats |
| GET | `/api/navigation/route?from=&to=` | Get optimal route |
| GET | `/api/navigation/nearby/:type` | Find nearby facilities |
| GET | `/api/queues` | Get all queue statuses |
| GET | `/api/queues/stats/summary` | Queue statistics |
| GET | `/api/food/vendors` | List food vendors |
| GET | `/api/food/menu/:vendorId` | Get vendor menu |
| POST | `/api/food/orders` | Place food order |
| GET | `/api/food/orders` | Get user's orders |
| POST | `/api/emergency` | Report emergency |
| GET | `/api/emergency` | Get user's emergencies |
| GET | `/api/notifications` | Get notifications |
| PUT | `/api/notifications/:id/read` | Mark as read |

### Sample API Responses

**Login Response:**
```json
{
  "user": {
    "_id": "...",
    "name": "John Fan",
    "email": "john@crowdsync.com",
    "seatSection": "A",
    "seatRow": "12",
    "seatNumber": "7"
  },
  "token": "eyJhbGciOiJIUzI1NiIs..."
}
```

**Crowd Stats Response:**
```json
{
  "stats": {
    "totalZones": 19,
    "totalCapacity": 21400,
    "totalOccupancy": 14935,
    "avgDensity": 70,
    "densityCounts": { "low": 5, "medium": 8, "high": 6 },
    "overallLevel": "medium"
  }
}
```

**Place Order Response:**
```json
{
  "order": {
    "_id": "...",
    "orderNumber": "CS-M4QR7XK",
    "vendor": "...",
    "items": [{ "name": "Classic Burger", "price": 8.99, "quantity": 2 }],
    "totalPrice": 17.98,
    "status": "pending",
    "estimatedReadyTime": "2024-01-15T15:30:00Z"
  }
}
```

## 🎨 Design

- **Dark theme** with navy/slate background
- **Glassmorphism** inspired card design
- **Gradient accents** — cyan-to-purple primary, amber warnings, red alerts
- **Color-coded density** — Green (low), Amber (medium), Red (high)
- **Responsive** layout for phones and tablets
- **Google Fonts Inter** typography

## 🔄 Real-time Simulation

The backend runs a simulator that:
- Updates crowd density for all zones every 5 seconds
- Fluctuates queue wait times and lengths
- Auto-progresses food orders (pending → confirmed → preparing → ready)
- Auto-acknowledges emergency reports after 5 seconds

This makes the demo feel alive with constantly changing data.
