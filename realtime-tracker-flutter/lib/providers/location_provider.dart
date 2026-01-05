import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/location_data.dart';

class LocationProvider extends ChangeNotifier {
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStream;
  String deviceType = 'Unknown';

  Position? get currentPosition => _currentPosition;

  LocationProvider() {
    _detectDeviceType();
    _startLocationTracking();
  }

  void _detectDeviceType() {
    // This will be detected based on the platform
    if (defaultTargetPlatform == TargetPlatform.android) {
      deviceType = 'Android 📱';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      deviceType = 'iOS 🍎';
    } else if (defaultTargetPlatform == TargetPlatform.windows) {
      deviceType = 'Windows 💻';
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      deviceType = 'Mac 🖥️';
    } else {
      deviceType = 'Unknown ❓';
    }
  }

  Future<void> _startLocationTracking() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services not enabled
        return;
      }

      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 0,
          timeLimit: Duration(seconds: 5),
        ),
      ).listen((Position position) {
        _currentPosition = position;
        notifyListeners();
      });
    } catch (e) {
      print('Error starting location tracking: $e');
    }
  }

  LocationData getCurrentLocationData(String userId) {
    return LocationData(
      id: userId,
      lat: _currentPosition?.latitude ?? 0.0,
      lng: _currentPosition?.longitude ?? 0.0,
      deviceType: deviceType,
      timestamp: DateTime.now(),
    );
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }
}
