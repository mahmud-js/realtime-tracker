# Flutter Real-Time Location Tracker 🗺️

A cross-platform real-time location tracking application built with **Flutter** and open-source maps, supporting **Android**, **iOS**, **Windows**, **macOS**, and **Web**.

## Why Flutter for This Project? 🎯

| Feature | Status |
|---------|--------|
| **Android** | ✅ Native Support |
| **iOS** | ✅ Native Support |
| **Windows** | ✅ Native Support |
| **macOS** | ✅ Native Support |
| **Web** | ✅ Full Support |
| **Open-Source Maps** | ✅ MapLibre GL |
| **Performance** | ✅ Compiled (Dart to Native) |
| **Single Codebase** | ✅ 100% Code Sharing |
| **Hot Reload** | ✅ Fast Development |

---

## Project Structure

```
realtime-tracker-flutter/
├── lib/
│   ├── main.dart                    # Entry point
│   ├── theme/
│   │   └── app_theme.dart          # Theme configuration
│   ├── models/
│   │   └── location_data.dart       # Data model
│   ├── providers/
│   │   ├── websocket_provider.dart  # WebSocket logic
│   │   └── location_provider.dart   # Geolocation logic
│   └── screens/
│       ├── home_screen.dart         # Main screen
│       └── widgets/
│           ├── info_panel.dart      # Info panel widget
│           └── notification_widget.dart
├── pubspec.yaml                     # Dependencies
├── android/                         # Android native code
├── ios/                            # iOS native code
├── windows/                        # Windows native code
├── macos/                          # macOS native code
└── web/                            # Web platform
```

---

## Setup Instructions

### Prerequisites

1. **Flutter SDK** (>=3.0.0)
   ```bash
   # Download from https://flutter.dev
   flutter --version
   ```

2. **Platform Requirements**:
   - **Android**: Android Studio + SDK (API 21+)
   - **iOS**: Xcode 12+ (macOS only)
   - **Windows**: Visual Studio 2019+ with C++ tools
   - **macOS**: Xcode 12+ (macOS only)
   - **Web**: Any modern browser

### Installation

1. **Create Flutter Project from Template**
   ```bash
   cd c:\Users\coder\Desktop
   flutter create realtime_location_tracker --template=app
   ```

2. **Copy the Files**
   ```bash
   # Copy all files from this directory to the created project
   cp -r lib/* realtime_location_tracker/lib/
   cp pubspec.yaml realtime_location_tracker/
   ```

3. **Install Dependencies**
   ```bash
   cd realtime_location_tracker
   flutter pub get
   ```

4. **Configure Platform-Specific Requirements**

   **Android** (`android/app/build.gradle`):
   ```gradle
   android {
       compileSdkVersion 34
       defaultConfig {
           minSdkVersion 21
           targetSdkVersion 34
       }
   }
   ```

   **iOS** (`ios/Podfile`):
   ```ruby
   platform :ios, '11.0'
   ```

   **Windows** - Run setup:
   ```bash
   flutter config --enable-windows-desktop
   flutter doctor
   ```

   **macOS** - Run setup:
   ```bash
   flutter config --enable-macos-desktop
   flutter doctor
   ```

   **Web** - Already configured

---

## Running the Application

### Development Mode

**Android**
```bash
flutter run -d android
```

**iOS**
```bash
flutter run -d ios
```

**Windows**
```bash
flutter run -d windows
```

**macOS**
```bash
flutter run -d macos
```

**Web**
```bash
flutter run -d chrome
# or firefox, edge, etc.
```

### Hot Reload (During Development)
```bash
# Just press 'r' in the terminal to hot reload
# Press 'R' to hot restart
```

---

## Building for Production

### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS
```bash
flutter build ios --release
# Then upload to App Store via Xcode/Transporter
```

### Windows
```bash
flutter build windows --release
# Output: build/windows/runner/Release/
```

### macOS
```bash
flutter build macos --release
# Output: build/macos/Build/Products/Release/
```

### Web
```bash
flutter build web --release
# Output: build/web/
# Deploy to any web server
```

---

## Features

### Real-Time Location Tracking
- 📍 Continuous GPS tracking with 5-second updates
- 🔄 WebSocket real-time data sync
- 📊 Live user count and status

### Map Functionality
- 🗺️ **Multiple Map Layers**:
  - OpenStreetMap (free, open-source)
  - CartoDB Positron (light, minimal style)
  - Stamen Terrain (topographic style)
- 🎯 Auto-zoom to user's location on first update
- 🔍 Zoom and pan controls
- 🧭 Compass heading indicator

### Cross-Platform Support
- ✅ Android (Phones, Tablets)
- ✅ iOS (iPhones, iPads)
- ✅ Windows (Desktop)
- ✅ macOS (Desktop)
- ✅ Web (Browsers)

### User Experience
- 🎨 Beautiful Material Design 3 UI
- 📱 Responsive layout for all screen sizes
- 🔔 Real-time notifications
- 📋 Copy-to-clipboard user ID
- 🎯 Device type detection
- 🌐 Network status indicator

---

## Configuration

### Server Connection

Update the WebSocket URL in `lib/providers/websocket_provider.dart`:

```dart
// Change this line to match your server
final wsUrl = Uri.parse('ws://localhost:8080/ws');

// For production:
// final wsUrl = Uri.parse('ws://yourdomain.com/ws');
```

### Map Styles

Add or modify map styles in `lib/screens/widgets/info_panel.dart`:

```dart
final Map<String, String> mapLayers = {
  'openstreetmap': 'https://demotiles.maplibre.org/style.json',
  'cartodb': 'https://a.basemaps.cartocdn.com/gl/positron/style.json',
  'custom': 'YOUR_CUSTOM_MAPLIBRE_STYLE_URL',
};
```

### Location Update Interval

Modify in `lib/screens/home_screen.dart`:

```dart
Timer.periodic(const Duration(seconds: 5), (timer) {
  // Change 5 to desired seconds
});
```

---

## Platform-Specific Permissions

### Android Permissions (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS Permissions (`ios/Runner/Info.plist`)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs your location to show it on the map</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs your location to show it on the map</string>
```

### macOS (`macos/Runner/Info.plist`)
Similar to iOS configuration above

### Windows
No special permissions required for location in the app settings

### Web
Uses browser geolocation API (automatic permission prompt)

---

## Troubleshooting

### Location Permission Denied
- Android: Open Settings > App Permissions > Location
- iOS: Settings > [App Name] > Location
- Windows: Settings > Privacy & Security > App Permissions
- macOS: System Preferences > Security & Privacy > Location Services

### Map Not Loading
- Check internet connection (tiles need to be downloaded)
- Verify MapLibre style URL is accessible
- Check browser console for CORS errors (on web)

### WebSocket Connection Failed
- Verify backend server is running (`go run main.go`)
- Check firewall settings
- For remote servers, ensure WSS (secure WebSocket) is configured

### Hot Reload Not Working
- File: `flutter run` with `r` key
- Try Full Restart with `R` key
- Rebuild with `flutter clean && flutter pub get`

---

## Performance Tips

1. **Reduce Location Update Frequency** - Change interval from 5s to 30s
2. **Limit Connected Users Display** - Show only nearby users
3. **Optimize Map Rendering** - Use lower zoom levels
4. **Background Execution** - Use `workmanager` plugin for background tracking

---

## Future Enhancements

- [ ] Offline map caching with `flutter_osm_plugin`
- [ ] History trail visualization
- [ ] Geofencing alerts
- [ ] User groups/teams
- [ ] Dark mode theme
- [ ] Sound notifications
- [ ] Video call integration
- [ ] Data export (CSV/JSON)
- [ ] Custom markers
- [ ] Search and filter users

---

## Dependencies Overview

| Dependency | Purpose |
|------------|---------|
| `web_socket_channel` | WebSocket communication |
| `geolocator` | GPS location tracking |
| `permission_handler` | Runtime permissions |
| `maplibre_gl` | Open-source map rendering |
| `provider` | State management |
| `uuid` | Generate unique user IDs |
| `connectivity_plus` | Network status |

---

## License

MIT License - Feel free to use this project for personal or commercial purposes.

## Support

- **GitHub Issues**: Report bugs
- **Discussions**: Ask questions
- **Wiki**: Detailed guides

---

**Star this project if you find it helpful!** ⭐
