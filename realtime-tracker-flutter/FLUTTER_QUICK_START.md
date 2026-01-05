# Flutter: Quick Start Guide 🚀

This guide will help you set up Flutter from scratch and get the Real-Time Location Tracker running on all platforms.

---

## Step 1: Download & Install Flutter SDK

### Windows

1. Download Flutter SDK from [flutter.dev](https://flutter.dev/docs/get-started/install/windows)
2. Extract to a location (e.g., `C:\flutter`)
3. Add to PATH:
   ```bash
   # Add C:\flutter\bin to your system PATH environment variable
   # Then restart your terminal
   ```
4. Verify installation:
   ```bash
   flutter --version
   flutter doctor
   ```

### macOS

```bash
# Using Homebrew
brew install flutter

# Or download and extract manually
# https://flutter.dev/docs/get-started/install/macos
```

### Linux

```bash
# Download and extract
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"
```

---

## Step 2: Run Flutter Doctor

```bash
flutter doctor
```

This checks your system for all dependencies. Fix any issues it reports.

---

## Step 3: Create Flutter Project

```bash
# Navigate to your workspace
cd C:\Users\coder\Desktop

# Create project from this template
flutter create realtime_location_tracker

# Or use our template:
cd realtime_location_tracker
flutter pub get
```

---

## Step 4: Set Up Platform-Specific Tools

### For Android Development

```bash
# Install Android Studio from https://developer.android.com/studio
# Then:
flutter config --android-sdk /path/to/android/sdk
flutter config --android-studio-dir /path/to/android/studio
```

### For iOS Development (macOS only)

```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
```

### For Windows Development

```bash
flutter config --enable-windows-desktop
flutter doctor -v
```

### For macOS Development (macOS only)

```bash
flutter config --enable-macos-desktop
flutter doctor -v
```

### For Web Development

```bash
flutter config --enable-web
```

---

## Step 5: Configure the Project

Copy all Flutter code files to your project:

```bash
# Copy from realtime-tracker-flutter to realtime_location_tracker
cp -r lib/* /path/to/realtime_location_tracker/lib/
cp pubspec.yaml /path/to/realtime_location_tracker/
```

Get dependencies:

```bash
flutter pub get
```

---

## Step 6: Run on Different Platforms

### Android

```bash
# Connect Android device or start emulator
flutter devices  # List available devices
flutter run -d <device_id>

# Or automatically select a device
flutter run
```

### iOS

```bash
# On macOS with Xcode
open ios/Runner.xcworkspace
# Or from command line:
flutter run -d ios
```

### Windows

```bash
flutter run -d windows
```

### macOS

```bash
flutter run -d macos
```

### Web

```bash
flutter run -d chrome
# Alternative browsers: firefox, edge, safari
```

---

## Step 7: Build for Production

### Android APK

```bash
flutter build apk --release
# Find at: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Play Store)

```bash
flutter build appbundle --release
# Find at: build/app/outputs/bundle/release/app-release.aab
```

### iOS (requires Mac)

```bash
flutter build ios --release
# Then use Transporter to upload to App Store
```

### Windows

```bash
flutter build windows --release
# Find at: build/windows/runner/Release/
```

### macOS (requires Mac)

```bash
flutter build macos --release
# Find at: build/macos/Build/Products/Release/
```

### Web

```bash
flutter build web --release
# Find at: build/web/
# Deploy to any web server (Firebase, Netlify, etc.)
```

---

## Command Cheat Sheet

```bash
# Project Setup
flutter create <project_name>
flutter pub get
flutter clean
flutter pub upgrade

# Development
flutter run                    # Run app
flutter run -d <device>      # Run on specific device
flutter devices              # List available devices
flutter emulators           # List emulators
flutter emulators --launch <emulator_id>  # Launch emulator

# Hot Reload (in running app)
r  # Hot reload
R  # Full restart
q  # Quit

# Testing & Analysis
flutter test
flutter analyze
flutter doctor

# Building
flutter build apk --release
flutter build ios --release
flutter build windows --release
flutter build macos --release
flutter build web --release

# Debugging
flutter run --debug
flutter run --profile
flutter logs
```

---

## Troubleshooting

### "Flutter command not found"
- Add Flutter bin to PATH
- Restart terminal/IDE

### "Android SDK not found"
- Set `ANDROID_SDK_ROOT` environment variable
- Run `flutter doctor --android-licenses`

### "Xcode not installed" (macOS)
- Install Xcode from App Store
- Accept license: `sudo xcode-select --switch /Applications/Xcode.app`

### "WebSocket connection refused"
- Ensure backend Go server is running
- Check server URL in `websocket_provider.dart`

### "Location permission denied"
- Grant permissions in app settings
- Restart the app

### "Map tiles not loading"
- Check internet connection
- Verify map style URL is accessible
- Check CORS settings for web

---

## Useful Resources

- **Official Docs**: https://flutter.dev/docs
- **Pub.dev**: https://pub.dev (package repository)
- **Flutter Examples**: https://github.com/flutter/samples
- **Firebase Integration**: https://firebase.flutter.dev
- **WebSocket Guide**: https://pub.dev/packages/web_socket_channel
- **Maps Guide**: https://github.com/maplibre/maplibre-gl-flutter

---

## Next Steps

1. ✅ Install Flutter SDK
2. ✅ Set up platform tools
3. ✅ Create project
4. ✅ Copy code files
5. ✅ Run on desired platform
6. 📝 Customize for your needs
7. 🚀 Build and deploy

---

**Enjoy building cross-platform apps with Flutter!** 🎉
