## Android Platform Configuration

Add to `android/app/build.gradle`:

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.example.realtime_location_tracker"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

---

## iOS Platform Configuration

Update `ios/Podfile`:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_LOCATION=1',
      ]
    end
  end
end
```

Add to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to track your position on the map in real-time</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need your location to track your position on the map in real-time</string>
<key>UIBackgroundModes</key>
<array>
    <string>location</string>
</array>
```

---

## Windows Platform Configuration

Create `windows/flutter/generated_plugins.cmake` with MapLibre configuration.

No special permissions needed - uses Windows location APIs.

---

## macOS Platform Configuration

Update `macos/Podfile` (similar to iOS).

Add to `macos/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to track your position on the map</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need your location to track your position on the map</string>
```

---

## Web Platform Configuration

No special configuration needed - uses browser's Geolocation API.

For HTTPS (required for secure WebSocket):
- Use `wss://` protocol instead of `ws://`
- Ensure backend server has valid SSL certificate

---

## Build & Deployment

### Android Play Store

1. Generate keystore:
   ```bash
   keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. Sign and build:
   ```bash
   flutter build appbundle --release
   ```

3. Upload to Google Play Console

### iOS App Store

1. Create App ID in Apple Developer
2. Create Certificate and Provisioning Profile
3. Build:
   ```bash
   flutter build ios --release
   ```
4. Upload using Transporter or Xcode

### Windows

1. Build:
   ```bash
   flutter build windows --release
   ```
2. Create installer using MSIX or ship the executable
3. For Microsoft Store, use MSIX packaging

### macOS

1. Create App ID in Apple Developer (Mac)
2. Build:
   ```bash
   flutter build macos --release
   ```
3. Submit to Mac App Store or distribute directly

### Web

1. Build:
   ```bash
   flutter build web --release
   ```
2. Deploy to any web server:
   - Firebase Hosting
   - Netlify
   - Vercel
   - AWS S3 + CloudFront
   - Your own server
