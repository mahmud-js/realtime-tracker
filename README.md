# Real Time Location Tracker 

> A real-time location tracking application built with **Go** and **WebSocket**

![Status](https://img.shields.io/badge/status-active-success)
![Language](https://img.shields.io/badge/language-Go-blue)
![Frontend](https://img.shields.io/badge/frontend-HTML5%2FCSS3%2FJS-orange)

## Video Tutorial Available on YouTube

Check out the complete step-by-step tutorial on YouTube to learn how this project works and how to build it from scratch!

## Features 🎯

- ✅ Real-time location tracking using WebSocket
- ✅ Interactive map powered by Leaflet.js
- ✅ Multiple map layers (OpenStreetMap, CartoDB, Stamen)
- ✅ Auto-zoom to user's actual location on connection
- ✅ Multi-device support detection
- ✅ Responsive design (mobile, tablet, desktop)
- ✅ User-friendly interface with status indicators
- ✅ Copy-to-clipboard user ID functionality
- ✅ Live user count display
- ✅ Error handling and reconnection logic
- ✅ Cross-browser compatible
- ✅ Beautiful notifications system
- ✅ Production-ready backend with health checks
- ✅ Configurable server settings via environment variables


## Tech Stack 🛠️

### Backend
- **Go 1.16+** - Server runtime
- **Gorilla WebSocket** - Real-time bidirectional communication
- **HTTP Server** - Built-in Go http package with middleware
- **Structured Logging** - Production-grade logging
- **Configuration Management** - Environment variables support

### Frontend
- **HTML5** - Semantic markup
- **CSS3** - Responsive styling with CSS Grid/Flexbox and Tailwind CSS
- **Vanilla JavaScript** - No dependencies, ES6+
- **Leaflet.js** - Interactive maps library
- **Multiple Map Providers** - OpenStreetMap, CartoDB, Stamen

## Installation & Setup 🚀

### Prerequisites
- Go 1.24+
- Git
- Docker & Docker Compose (optional)
- A modern web browser

### Quick Start (Development)

```bash
# Clone repository
git clone https://github.com/yourusername/realtime-tracker.git
cd realtime-tracker

# Option 1: Run directly
go mod download
go run main.go

# Option 2: Run with Docker
docker-compose up

# Option 3: Run with hot reload
air
```

Visit `http://localhost:8080`

### Production Deployment

**See [CI_CD_SETUP.md](CI_CD_SETUP.md) for automated build pipeline.**

For manual deployment to **devplus.fun**:
```bash
docker-compose up -d
# Then setup Nginx + SSL (see DEPLOYMENT.md)
```

## Usage 💡

1. **Open the App**: Navigate to `http://localhost:8080`
2. **Grant Permission**: Allow the browser to access your location
3. **See the Map**: Your location will appear on the map with a marker
4. **Share Your ID**: Click the 📋 button to copy your User ID
5. **Invite Others**: Share the server URL with others on the same network
6. **Watch in Real-Time**: See other users' locations update in real-time

## API Documentation 📡

### WebSocket Endpoint
```
ws://localhost:8080/ws
```

### HTTP Endpoints

**Health Check**
```bash
GET /health
```
Response:
```json
{
  "status": "healthy",
  "timestamp": "2024-01-04T10:30:45Z",
  "connected": 5,
  "uptime_check": true
}
```

**Server Statistics**
```bash
GET /stats
```
Response:
```json
{
  "connected_clients": 5,
  "tracked_locations": 4,
  "broadcast_queue": 0,
  "timestamp": "2024-01-04T10:30:45Z"
}
```

### WebSocket Message Format

**Client → Server (Location Update)**
```json
{
  "id": "User-123456",
  "lat": 51.505,
  "lng": -0.09,
  "deviceType": "Windows 💻",
  "timestamp": "2024-01-04T10:30:45Z"
}
```

**Server → Clients (Broadcast)**
Same format as above - all clients receive all location updates with timestamps

## Configuration ⚙️

### Server Configuration (Backend)

Set via environment variables:
```bash
# Server settings
export SERVER_HOST="0.0.0.0"        # Default: 0.0.0.0
export SERVER_PORT="8080"           # Default: 8080
export READ_TIMEOUT="15s"           # Default: 15 seconds
export WRITE_TIMEOUT="15s"          # Default: 15 seconds
export IDLE_TIMEOUT="60s"           # Default: 60 seconds

# Then run:
go run main.go
```

### Frontend Configuration

Edit `public/js/index.js` to customize:
- Default map center coordinates
- Default zoom level
- Geolocation accuracy
- Update interval
- Map layers

```javascript
const CONFIG = {
    DEFAULT_LAT: 51.505,
    DEFAULT_LNG: -0.09,
    DEFAULT_ZOOM: 13,
    GEOLOCATION_OPTIONS: {
        enableHighAccuracy: true,
        timeout: 10000,
        maximumAge: 0
    },
    UPDATE_INTERVAL: 5000
};
```

## Responsive Design 📱

The application is fully responsive:
- **Desktop**: Full-size map with side panel
- **Tablet**: Optimized layout with adjustable panel
- **Mobile**: Compact view with full-width map

Breakpoints:
- `≥768px`: Desktop layout
- `480px - 768px`: Tablet layout
- `<480px`: Mobile layout

## CI/CD & Deployment 🚀

### Automated Testing & Building

This project uses **GitHub Actions** for CI/CD on every push to `main`:

**Builds**:
- ✅ Go backend (Linux, Windows, macOS)
- ✅ Flutter mobile (APK)
- ✅ Flutter web
- ✅ Docker container

**Tests**:
- ✅ Go unit tests with race detection
- ✅ Go vet code quality
- ✅ Flutter analyze
- ✅ Flutter unit tests
- ✅ Security scanning (Gosec)

**Artifacts**: Download from Actions tab after successful build

### Quick Deploy (Production)

```bash
# Docker (Recommended)
docker-compose up -d

# Systemd Service
sudo systemctl start tracker

# See CI_CD_SETUP.md for detailed setup
```

Deploy to **devplus.fun**:
- See [CI_CD_SETUP.md](CI_CD_SETUP.md) - Complete guide
- See [DEPLOYMENT.md](DEPLOYMENT.md) - Nginx + SSL setup

### Development Setup

```bash
# Hot reload (auto-restart on code changes)
air

# Or Docker with hot reload
docker-compose -f docker-compose.dev.yml up
```

## Features in Detail 🔍

### Real-Time Updates
Uses WebSocket for bidirectional communication with ~100ms latency and timestamp tracking.

### User Presence
Online user count updates automatically. Users are removed from the map when they disconnect.

### Map Layer Switching
Switch between three open-source map providers:
- **OpenStreetMap**: Free, community-driven base map
- **CartoDB Positron**: Clean, minimal light map design
- **Stamen Toner**: High-contrast black & white map

Buttons in the info panel allow instant switching without losing markers.

### Auto-Zoom to User Location
When your location is first detected, the map automatically zooms to your position (zoom level 15) and centers on your coordinates, instead of showing a default location.

### Device Detection
Automatically detects user device type:
- 📱 Android
- 🍎 iOS
- 💻 Windows
- 🐧 Linux
- 🖥️ Mac

### Error Handling
- Network errors trigger automatic reconnection
- Geolocation errors display user-friendly messages
- Invalid coordinates are filtered out

### Notifications
Toast-style notifications for:
- Successful connections
- New users joining
- Connection errors
- Location permission issues

## Performance Considerations 🚀

- Location updates sent every 5 seconds
- Efficient marker updates (create once, update position)
- CSS animations use GPU acceleration
- Minimal JavaScript overhead

## Browser Support 🌐

| Browser | Support |
|---------|---------|
| Chrome | ✅ Full |
| Firefox | ✅ Full |
| Safari | ✅ Full |
| Edge | ✅ Full |
| IE11 | ⚠️ Partial |

## Troubleshooting 🔧

### Server won't start
- Check if port 8080 is already in use
- Run with a different port: Modify `main.go` line with `ListenAndServe`

### Map doesn't load
- Check internet connection (needs OpenStreetMap tiles)
- Check browser console for errors
- Disable ad blockers

### Location not updating
- Grant location permission when prompted
- Check GPS/geolocation is enabled on device
- Ensure HTTPS for production (geolocation requires secure context)

### WebSocket connection fails
- Check firewall settings
- Ensure server is running (`go run main.go`)
- For remote access, use reverse proxy (Nginx) or cloud deployment

## Development 👨‍💻

### Code Style
- Go: Follow Go conventions (gofmt)
- JavaScript: Semicolons optional, use var/let/const appropriately
- CSS: BEM-like naming convention

### Testing
```bash
# Test WebSocket locally
go run main.go

# Open multiple browser windows at localhost:8080
# Verify locations sync across all windows
```

### Debugging
- Browser DevTools: F12
- Go Server: Check console output
- Network Tab: Monitor WebSocket messages

## Contributing 🤝

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Deployment 🌍

See [DEPLOYMENT.md](DEPLOYMENT.md) for production deployment guide.

## Backend Features (Production Ready) 🔒

### Server Features
- **Graceful Shutdown**: Handles SIGINT/SIGTERM signals cleanly
- **Health Checks**: `/health` endpoint for monitoring
- **Statistics**: `/stats` endpoint for server metrics
- **Request Logging**: Detailed request/response logging with duration
- **Connection Management**: Automatic dead connection cleanup
- **Data Validation**: Input validation for all location data
- **Configuration**: Environment variable support for all settings
- **Error Handling**: Comprehensive error handling and recovery
- **Performance**: Buffered channels and RWMutex for concurrency

### Data Persistence
- Last known location stored per user
- Timestamp tracking for all updates

## Known Limitations ⚠️

1. Locations only visible while browser tab is active
2. Location history not persisted to database
3. No authentication/user accounts
4. No offline mode
5. Limited to single server instance (no clustering)
6. In-memory storage (lost on server restart)

## Future Enhancements 💭

- [ ] PostgreSQL/MongoDB for location history persistence
- [ ] User authentication and authorization
- [ ] Location trails/history visualization
- [ ] Geofencing alerts and notifications
- [ ] Custom markers and icons
- [ ] Dark mode theme
- [ ] Location sharing groups/teams
- [ ] Export location data (CSV/JSON)
- [ ] Server clustering and horizontal scaling
- [ ] Redis for distributed caching
- [ ] Metrics and monitoring (Prometheus)
- [ ] Advanced search and filtering

## License 📄

MIT License - feel free to use this project for personal or commercial purposes.

## Support 💬

- **GitHub Issues**: Report bugs and request features
- **YouTube Comments**: Ask questions on the tutorial video
- **Email**: Create an issue with your question


---

**Star this project** if you find it helpful! ⭐

Checkout this: https://github.com/mahmud-r-farhan/realtime-location-tracker (Node powered!)

