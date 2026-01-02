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
- ✅ Multi-device support detection
- ✅ Responsive design (mobile, tablet, desktop)
- ✅ User-friendly interface with status indicators
- ✅ Copy-to-clipboard user ID functionality
- ✅ Live user count display
- ✅ Error handling and reconnection logic
- ✅ Cross-browser compatible
- ✅ Beautiful notifications system


## Tech Stack 🛠️

### Backend
- **Go** - Server runtime
- **Gorilla WebSocket** - Real-time communication
- **HTTP Server** - Built-in Go http package

### Frontend
- **HTML5** - Markup
- **CSS3** - Responsive styling with CSS Grid/Flexbox
- **Vanilla JavaScript** - No dependencies
- **Leaflet.js** - Interactive maps
- **OpenStreetMap** - Map tiles

## Installation & Setup 🚀

### Prerequisites
- Go 1.16+
- Git
- A modern web browser

### Step 1: Clone the Repository
```bash
git clone https://github.com/mahmud-js/realtime-tracker.git
cd realtime-tracker
```

### Step 2: Install Dependencies
```bash
go mod download
```

### Step 3: Run the Server
```bash
go run main.go
```

You should see:
```
Server started on :8080
```

### Step 4: Open in Browser
Visit `http://localhost:8080` in your browser.

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

### Message Format

**Client → Server (Location Update)**
```json
{
  "id": "User-123456",
  "lat": 51.505,
  "lng": -0.09,
  "deviceType": "Windows 💻"
}
```

**Server → Clients (Broadcast)**
Same format as above - all clients receive all location updates

## Configuration ⚙️

Edit `public/js/index.js` to customize:
- Default map center coordinates
- Default zoom level
- Geolocation accuracy
- Reconnection timeout

```javascript
const CONFIG = {
    DEFAULT_LAT: 51.505,
    DEFAULT_LNG: -0.09,
    DEFAULT_ZOOM: 13,
    GEOLOCATION_OPTIONS: {
        enableHighAccuracy: true,
        timeout: 10000,
        maximumAge: 0
    }
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

## Features in Detail 🔍

### Real-Time Updates
Uses WebSocket for bidirectional communication with ~100ms latency.

### User Presence
Online user count updates automatically. Users are removed from the map when they disconnect.

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

## Known Limitations ⚠️

1. Locations only visible while browser tab is active
2. Location history not persisted
3. No authentication/user accounts
4. No offline mode
5. Limited to single server instance (no clustering)

## Future Enhancements 💭

- [ ] MongoDB/PostgreSQL for location history
- [ ] User authentication
- [ ] Location trails/history
- [ ] Geofencing alerts
- [ ] Custom markers
- [ ] Dark mode
- [ ] Location sharing groups
- [ ] Export location data

## License 📄

MIT License - feel free to use this project for personal or commercial purposes.

## Support 💬

- **GitHub Issues**: Report bugs and request features
- **YouTube Comments**: Ask questions on the tutorial video
- **Email**: Create an issue with your question


---

**Star this project** if you find it helpful! ⭐

Checkout this: https://github.com/mahmud-r-farhan/realtime-location-tracker (Node powered!)

