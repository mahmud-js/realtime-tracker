# Architecture Documentation 🏗️

## System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     Browser Client 1                         │
│  ┌────────────────┐  ┌──────────┐  ┌───────────────────┐   │
│  │   index.html   │  │ main.css │  │   index.js        │   │
│  │   (UI Layout)  │  │(Styling) │  │ (WebSocket Logic) │   │
│  └────────────────┘  └──────────┘  └───────────────────┘   │
└─────────────┬───────────────────────────────────────────────┘
              │ WebSocket Connection
              │ JSON Messages
              ▼
┌─────────────────────────────────────────────────────────────┐
│                     Go Server                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ HTTP Server (http.ListenAndServe)                  │   │
│  │  ├─ Static File Server (./public)                  │   │
│  │  └─ WebSocket Handler (/ws)                        │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ WebSocket Manager                                  │   │
│  │  ├─ handleConnections()   (Client connections)    │   │
│  │  ├─ handleMessages()      (Message broadcast)     │   │
│  │  └─ Mutex (Thread safety)                         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                              │
│  Data:                                                       │
│  ├─ clients map (active WebSocket connections)             │
│  └─ broadcast channel (message queue)                      │
└─────────────┬───────────────────────────────────────────────┘
              │ WebSocket Connection
              │ JSON Messages
              ▼
┌─────────────────────────────────────────────────────────────┐
│                     Browser Client 2                         │
│  ┌────────────────┐  ┌──────────┐  ┌───────────────────┐   │
│  │   index.html   │  │ main.css │  │   index.js        │   │
│  │   (UI Layout)  │  │(Styling) │  │ (WebSocket Logic) │   │
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
// Configuration
CONFIG {
    DEFAULT_LAT, DEFAULT_LNG, DEFAULT_ZOOM,
    GEOLOCATION_OPTIONS, UPDATE_INTERVAL
}

// Application State
state {
    userId, deviceType, socket, markers,
    userCount, isConnected, watchId
}

// Core Functions
├── UI Functions
│   ├── initializeUI()
│   ├── updateStatus()
│   ├── updateUserCount()
│   └── showNotification()
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
    └── updateMarker()

// Event Listeners
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
├── Imports
├── Data Structures
│   └── LocationData struct
├── Global Variables
│   ├── upgrader (WebSocket)
│   ├── clients map
│   ├── broadcast channel
│   └── mutex
├── Functions
│   ├── main()
│   ├── handleConnections()
│   └── handleMessages()
└── Constants
```

### Data Flow Diagram

```
Client Geolocation
    │
    ▼
JavaScript watch location
    │
    ▼
Create LocationData JSON
    │
    ▼
WebSocket.send()
    │
    ▼ (TCP/WebSocket)
    │
Go Server receives
    │
    ▼
ws.ReadJSON(&msg)
    │
    ▼
broadcast <- msg
    │
    ▼
handleMessages() loop
    │
    ▼
For each connected client:
    ├─ client.WriteJSON(msg)
    └─ (if error: close & remove)
    │
    ▼ (TCP/WebSocket)
    │
Client receives
    │
    ▼
socket.onmessage
    │
    ▼
updateMarker()
    │
    ▼
L.marker().setLatLng()
    │
    ▼
Update map display
```

### Concurrency Model

```
main()
├─ HTTP Server (blocking)
├─ handleConnections()
│  └─ Go routine per connection
│     ├─ ws.ReadJSON() (blocking read)
│     └─ broadcast <- msg (send to channel)
│
└─ handleMessages() (separate Go routine)
   └─ Infinite loop
      ├─ msg := <-broadcast (read from channel)
      └─ For each client: WriteJSON()

Synchronization:
├─ clients map: protected by mutex
└─ broadcast channel: thread-safe by design
```

## Communication Protocol

### WebSocket Message Format

```json
{
    "id": "User-123456",
    "lat": 51.505,
    "lng": -0.09,
    "deviceType": "Windows 💻"
}
```

### Update Frequency

- **Client → Server**: Every 5 seconds (or on significant location change)
- **Server → All Clients**: Immediately (on receipt)
- **Total Latency**: ~100-200ms (network dependent)

## Security Considerations

### Current Implementation
```go
upgrader := websocket.Upgrader{
    CheckOrigin: func(r *http.Request) bool {
        return true // ⚠️ Allows any origin
    },
}
```

### Recommended Improvements
```go
// Whitelist origins
CheckOrigin: func(r *http.Request) bool {
    return strings.Contains(r.Header.Get("Origin"), "yourdomain.com")
}

// Add authentication
// Add rate limiting
// Validate location coordinates
// Use WSS (WebSocket Secure) in production
```

## Performance Characteristics

### Resource Usage
- **Memory**: ~1-2MB per connected client
- **CPU**: Minimal (event-driven, no polling)
- **Network**: ~500 bytes per location update
- **Map Rendering**: ~16ms per frame (60 FPS)

### Scalability Limits
- **Single Instance**: ~1000 concurrent connections
- **Scaling**: Load balance multiple server instances
- **Database**: Add PostgreSQL for persistence

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
1. **Database**: Connect to PostgreSQL
2. **Authentication**: Add JWT tokens
3. **History**: Store location trails
4. **Clustering**: Load balance servers
5. **Notifications**: Add real-time alerts
6. **Geofencing**: Add boundary checks

### Modification Hooks
- Modify `CONFIG` for settings
- Override `updateMarker()` for custom markers
- Extend `state` object for additional data
- Add new WebSocket message types
