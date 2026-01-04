# Architecture Documentation 🏗️

## System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     Browser Client 1                         │
│  ┌────────────────┐  ┌──────────┐  ┌───────────────────┐   │
│  │   index.html   │  │ Tailwind │  │   index.js        │   │
│  │   (UI Layout)  │  │ (Styling)│  │ (WebSocket Logic) │   │
│  └────────────────┘  └──────────┘  └───────────────────┘   │
└─────────────┬───────────────────────────────────────────────┘
              │ WebSocket Connection
              │ JSON Messages + Timestamps
              ▼
┌─────────────────────────────────────────────────────────────┐
│                     Go Server (Production)                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ HTTP Server (net/http with timeouts)                │   │
│  │  ├─ Static File Server (./public)                  │   │
│  │  ├─ WebSocket Handler (/ws)                        │   │
│  │  ├─ Health Check (/health)                         │   │
│  │  └─ Statistics (/stats)                            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Client Manager (Concurrent Safe)                   │   │
│  │  ├─ register channel    (New connections)          │   │
│  │  ├─ unregister channel  (Closed connections)       │   │
│  │  ├─ broadcast channel   (Message queue - 256 buf)  │   │
│  │  └─ Manager.run()       (Main event loop)          │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Data Management                                     │   │
│  │  ├─ clients map (active WebSocket connections)     │   │
│  │  ├─ lastLocation map (last known position)         │   │
│  │  ├─ RWMutex (Thread safety)                        │   │
│  │  └─ Graceful shutdown handling                     │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────┬───────────────────────────────────────────────┘
              │ WebSocket Connection
              │ JSON Messages + Timestamps
              ▼
┌─────────────────────────────────────────────────────────────┐
│                     Browser Client 2                         │
│  ┌────────────────┐  ┌──────────┐  ┌───────────────────┐   │
│  │   index.html   │  │ Tailwind │  │   index.js        │   │
│  │   (UI Layout)  │  │ (Styling)│  │ (WebSocket Logic) │   │
│  └────────────────┘  └──────────┘  └───────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## Frontend Architecture

### Component Hierarchy

```
index.html
├── header.header
│   └── h1 (Title)
├── div#map (Leaflet Container)
├── div.info-panel
│   ├── Device ID Display
│   ├── Connection Status
│   ├── Device Type
│   └── User Count
├── div#notification (Toast)
└── <scripts>
    ├── leaflet.js (Map library)
    └── index.js (App logic)
```

### JavaScript Module Structure

```javascript
// Map Layers Configuration
MAP_LAYERS {
    osm: { url, attribution, maxZoom },
    cartodb: { url, attribution, maxZoom },
    stamen: { url, attribution, maxZoom }
}

// Application State
state {
    userId, deviceType, socket, markers,
    userCount, isConnected, watchId,
    currentLayer, userZoomed, currentTileLayer
}

// Core Functions
├── UI Functions
│   ├── initializeUI()
│   ├── updateStatus()
│   ├── updateUserCount()
│   ├── showNotification()
│   └── switchMapLayer()
│
├── WebSocket Functions
│   ├── connectWebSocket()
│   ├── socket.onopen
│   ├── socket.onmessage
│   ├── socket.onerror
│   └── socket.onclose
│
├── Geolocation Functions
│   ├── startTracking()
│   └── watchPosition callbacks
│
└── Marker Management
    └── updateMarker() [with auto-zoom to user location]

// Event Listeners
├── Map layer button clicks
├── Copy button click
├── Window beforeunload
└── Document DOMContentLoaded
```

### CSS Architecture

```
Variables (--primary-color, --shadow, etc.)
├── Root styles (html, body)
├── Header styles
├── Map container
├── Info panel
│   ├── Info items
│   ├── Status badge
│   └── Copy button
├── Notifications
├── Animations
│   ├── slideIn
│   ├── slideInUp
│   └── pulse
└── Responsive breakpoints
    ├── @media (max-width: 768px)
    └── @media (max-width: 480px)
```

## Backend Architecture

### Go Package Structure

```
main.go
├── Imports (context, encoding/json, errors, math, sync, etc.)
├── Data Structures
│   ├── LocationData struct
│   │   ├── ID string
│   │   ├── Lat float64
│   │   ├── Lng float64
│   │   ├── DeviceType string
│   │   └── Timestamp time.Time
│   ├── ClientManager struct
│   │   ├── clients map
│   │   ├── broadcast channel (buffered 256)
│   │   ├── register channel
│   │   ├── unregister channel
│   │   ├── mutex (RWMutex)
│   │   ├── clientCount int
│   │   └── lastLocation map
│   └── ServerConfig struct
│       ├── Host string
│       ├── Port string
│       ├── ReadTimeout
│       ├── WriteTimeout
│       └── IdleTimeout
├── Global Variables
│   ├── manager *ClientManager
│   ├── logger *log.Logger
│   └── config *ServerConfig
├── Initialization
│   └── init() [sets up config, logger, manager]
├── Utility Functions
│   ├── getEnv()
│   └── getDurationEnv()
├── HTTP Handlers
│   ├── main()
│   ├── handleWebSocket()
│   ├── handleHealth()
│   └── handleStats()
├── Middleware
│   └── loggingMiddleware()
├── WebSocket Message Handling
│   ├── handleClientMessages()
│   └── validateLocationData()
├── Coordinate Validation
│   └── isValidCoordinate()
└── ClientManager Methods
    └── run() [main event loop with select]
```

### Data Flow Diagram

```
Client Geolocation
    │
    ▼
JavaScript watch location (every 5s)
    │
    ▼
Create LocationData JSON
    │
    ▼
WebSocket.send()
    │
    ▼ (TCP/WebSocket)
    │
Go Server receives (handleClientMessages)
    │
    ▼
ws.ReadJSON(&msg)
    │
    ▼
validateLocationData(&msg)
    │
    ▼
Add timestamp
    │
    ▼
broadcast <- msg (send to channel)
    │
    ▼
ClientManager.run() event loop
    │
    ├─ Store in lastLocation map
    │
    ▼
For each connected client:
    ├─ Check if connection alive
    ├─ client.WriteJSON(msg)
    └─ (if error: close & remove from clients map)
    │
    ▼ (TCP/WebSocket)
    │
Client socket.onmessage
    │
    ▼
Parse JSON
    │
    ▼
updateMarker(data)
    │
    ├─ Validate coordinates
    │
    ├─ Create or update marker
    │
    ├─ If own location: setView() to zoom (once only)
    │
    ▼
L.marker().setLatLng()
    │
    ▼
Update map display (Leaflet re-renders)
```

### Concurrency Model

```
main()
├─ Setup HTTP mux with handlers:
│  ├─ GET /         → Static file server
│  ├─ GET /health   → Health check endpoint
│  ├─ GET /stats    → Statistics endpoint
│  └─ GET /ws       → WebSocket upgrade handler
├─ Apply logging middleware
├─ Create HTTP server with timeouts
├─ Start ClientManager.run() in goroutine
├─ Setup signal handling (SIGINT/SIGTERM)
└─ Start HTTP server (blocking)

ClientManager.run() Goroutine (Main Event Loop)
└─ Infinite for-select loop:
   ├─ case <-cm.register:
   │  └─ Add client to clients map
   │
   ├─ case <-cm.unregister:
   │  └─ Remove client from clients map
   │
   ├─ case msg := <-cm.broadcast:
   │  ├─ Store in lastLocation map
   │  ├─ For each client in clients map:
   │  │  ├─ Try: client.WriteJSON(msg)
   │  │  └─ On error: mark as dead & remove
   │  └─ Log stats
   │
   └─ case <-ticker.C (every 30s):
      └─ Log current statistics

handleWebSocket() per Connection
├─ Upgrade connection
├─ Set read deadlines & pong handlers
├─ Send to register channel
└─ Start handleClientMessages() goroutine

handleClientMessages() per Connection (Blocking Read Loop)
├─ Infinite for loop:
│  ├─ ws.ReadJSON(&msg)
│  ├─ validateLocationData(&msg)
│  └─ msg.Timestamp = time.Now()
│  └─ Send to broadcast channel (non-blocking select)
└─ On close/error:
   ├─ Send to unregister channel
   └─ Close connection

Synchronization:
├─ clients map: protected by RWMutex
├─ lastLocation map: protected by RWMutex
├─ broadcast channel: thread-safe by design
├─ register/unregister channels: thread-safe by design
└─ Read deadlines: prevent stale connections
```

## Communication Protocol

### WebSocket Message Format

```json
{
    "id": "User-123456",
    "lat": 51.505,
    "lng": -0.09,
    "deviceType": "Windows 💻",
    "timestamp": "2024-01-04T10:30:45.123456Z"
}
```

### HTTP Endpoints

**GET /health** - Server health check
```json
{
    "status": "healthy",
    "timestamp": "2024-01-04T10:30:45.123456Z",
    "connected": 5,
    "uptime_check": true
}
```

**GET /stats** - Server statistics
```json
{
    "connected_clients": 5,
    "tracked_locations": 4,
    "broadcast_queue": 1,
    "timestamp": "2024-01-04T10:30:45.123456Z"
}
```

### Update Frequency & Latency

- **Client → Server**: Every 5 seconds (configurable)
- **Server → All Clients**: Immediately on receipt
- **Total Latency**: ~100-200ms (network dependent)
- **Broadcast Channel**: Buffered at 256 messages
- **Connection Timeout**: 60 seconds idle

## Security Considerations

### Current Implementation (Development)
```go
upgrader := websocket.Upgrader{
    ReadBufferSize:  1024,
    WriteBufferSize: 1024,
    CheckOrigin: func(r *http.Request) bool {
        return true // ⚠️ Allows any origin (dev only)
    },
}
```

### Validation & Error Handling
```go
// Input Validation
func validateLocationData(data *LocationData) error {
    if data.ID == ""                           → Error
    if len(data.ID) > 100                      → Error
    if !isValidCoordinate(data.Lat)            → Error
    if !isValidCoordinate(data.Lng)            → Error
}

// Coordinate Range Checking
func isValidCoordinate(coord float64) bool {
    return !math.IsNaN(coord) && 
           !math.IsInf(coord, 0) && 
           coord >= -180 && 
           coord <= 180
}
```

### Production Recommendations

1. **Origin Whitelisting**
```go
CheckOrigin: func(r *http.Request) bool {
    return strings.HasSuffix(r.Header.Get("Origin"), "yourdomain.com")
}
```

2. **Use WSS (WebSocket Secure)**
   - Enable HTTPS/TLS in production
   - Use wss:// instead of ws://

3. **Rate Limiting**
   - Implement per-user location update throttling
   - Prevent broadcast channel flooding

4. **Authentication**
   - Add JWT token validation
   - User session management

5. **CORS Headers**
   - Properly validate origins
   - Set appropriate headers

6. **Database Security**
   - When adding persistence: Use parameterized queries
   - Encrypt sensitive data
   - Set proper database permissions

7. **Monitoring & Logging**
   - Log all security events
   - Monitor for suspicious patterns
   - Set up alerts for errors

## Performance Characteristics

### Resource Usage (Per Connected Client)
- **Memory**: ~1-2MB per connection (client state + marker data)
- **CPU**: Minimal (event-driven, no polling or busy waiting)
- **Network**: ~500-800 bytes per location update
- **Goroutine**: 1 goroutine per client (read loop)

### Server Performance
- **Broadcast Channel**: 256 message buffer (prevents blocking)
- **RWMutex**: Allows concurrent reads, exclusive writes
- **Timer**: 30-second stats logging interval
- **Map Rendering**: ~16ms per frame (60 FPS client-side)

### Scalability Limits
- **Single Instance**: ~1000-2000 concurrent connections (hardware dependent)
- **Bottleneck**: Network I/O and client count
- **Scaling Strategy**: Load balance across multiple server instances

### Optimization Tips
1. Increase broadcast buffer for burst traffic
2. Adjust stats logging interval
3. Use CDN for static files
4. Implement connection pooling
5. Monitor goroutine leaks

### Benchmarking
```
Expected performance:
- Connection establishment: ~50-100ms
- Message latency: ~50-150ms
- Broadcasting 100 messages to 1000 clients: ~1-2 seconds
- Memory growth: ~2MB per 1000 new clients
```

## Responsive Design Strategy

### Mobile-First Approach
```
Base styles (mobile)
  ↓
@media (min-width: 480px)  → Tablet
  ↓
@media (min-width: 768px)  → Desktop
```

### Key Responsive Elements
- **Info Panel**: Adjusts max-width and position
- **Map**: Fills remaining space flexibly
- **Typography**: Uses clamp() for fluid sizing
- **Spacing**: Scales with viewport

## Error Handling Flow

```
Browser/Network Error
    │
    ▼
catch block / error event
    │
    ▼
updateStatus(error, 'error')
    │
    ▼
showNotification()
    │
    ├─ Connection Error → Reconnect after 3s
    ├─ Geolocation Error → Show user message
    ├─ Parse Error → Log and skip
    └─ Marker Error → Validate and filter
```

## Extension Points

### Add Features

1. **Database Persistence**
   - Connect to PostgreSQL/MongoDB
   - Store location history
   - Query historical trails

2. **Authentication**
   - Add JWT token validation
   - Implement user accounts
   - Session management

3. **Clustering**
   - Use Redis for pub/sub
   - Load balance across servers
   - Distributed client registry

4. **Advanced Features**
   - Geofencing/alerts
   - Custom markers/icons
   - Location trails visualization
   - Real-time search

5. **Monitoring & Observability**
   - Prometheus metrics export
   - Distributed tracing
   - Performance profiling
   - Custom dashboards

### Modification Hooks

**Frontend**
- Override `switchMapLayer()` for custom maps
- Extend `state` object for additional data
- Modify `updateMarker()` for custom marker behavior
- Add new WebSocket message types
- Customize `CONFIG` for different regions

**Backend**
- Add middleware for authentication
- Extend `LocationData` struct with new fields
- Implement custom validation in `validateLocationData()`
- Add new HTTP endpoints in `main()`
- Create new event types in `ClientManager.run()`

**Database Integration**
```go
// Add to ClientManager
database *sql.DB

// In manager.run() broadcast case:
if err := database.StoreLocation(msg); err != nil {
    logger.Printf("Database error: %v", err)
}
```
