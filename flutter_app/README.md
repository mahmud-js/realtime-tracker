# Real-Time Tracker (Flutter)

A cross-platform real-time location tracker built with Flutter, using a Golang backend.

## Project Architecture

The application is structured for maintainability and scalability:

- **`lib/models/`**: Data structures (e.g., `LocationData`).
- **`lib/services/`**: Logical units for external interactions (WebSockets, GPS, Device Info).
- **`lib/widgets/`**: Reusable UI components (Map Markers, Info Panels).
- **`lib/screens/`**: Main application views.
- **`lib/main.dart`**: Application entry point and theme configuration.

## Features

- **Live Tracking**: Real-time GPS location updates.
- **WebSocket Sync**: Instant synchronization with other connected devices.
- **Multi-platform**: Android and iOS support with configured permissions.
- **Responsive UI**: Interactive map with user status panels.

## Steps to Run

### 1. Start the Golang Backend
```powershell
go run main.go
```

### 2. Configure Frontend
Open `lib/screens/tracker_screen.dart` and update `_wsUrl`:
- **Emulator**: `ws://10.0.2.2:8080/ws`
- **Physical Device**: `ws://YOUR_LOCAL_IP:8080/ws`

### 3. Run Flutter App
```powershell
cd flutter_app
flutter run
```

## Maintenance & Updates

- **Add new data**: Update `LocationData` model in `lib/models/`.
- **Change Logic**: Modify `WebSocketService` or `LocationService` in `lib/services/`.
- **Style Changes**: Update widgets in `lib/widgets/` or the theme in `main.dart`.