import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(const RealTimeTrackerApp());
}

class RealTimeTrackerApp extends StatelessWidget {
  const RealTimeTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Real-Time Location Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          primary: const Color(0xFF4CAF50),
        ),
      ),
      home: const TrackerScreen(),
    );
  }
}

class LocationData {
  final String id;
  final double lat;
  final double lng;
  final String deviceType;

  LocationData({
    required this.id,
    required this.lat,
    required this.lng,
    required this.deviceType,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      id: json['id'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      deviceType: json['deviceType'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'lat': lat,
        'lng': lng,
        'deviceType': deviceType,
      };
}

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  final String _myId = 'User-${const Uuid().v4().substring(0, 8)}';
  String _deviceType = 'Unknown Device';
  
  // Update this to your local server IP if testing on a real device
  final String _wsUrl = 'ws://localhost:8080/ws';
  
  WebSocketChannel? _channel;
  StreamSubscription? _locationSubscription;
  bool _isConnected = false;
  
  final Map<String, LocationData> _remoteUsers = {};
  LocationData? _myLastLocation;
  
  final MapController _mapController = MapController();
  bool _hasZoomedToMe = false;

  @override
  void initState() {
    super.initState();
    _initDeviceAndTracking();
    _connectWebSocket();
  }

  Future<void> _initDeviceAndTracking() async {
    // Get device type
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      _deviceType = 'Android (${androidInfo.model}) 📱';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      _deviceType = 'iOS (${iosInfo.name}) 🍎';
    } else {
      _deviceType = '${Platform.operatingSystem} 💻';
    }

    // Request permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    if (permission == LocationPermission.whileInUse || 
        permission == LocationPermission.always) {
      _startLocationTracking();
    }

    if (mounted) setState(() {});
  }

  void _connectWebSocket() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
      _channel!.stream.listen(
        (message) {
          final data = jsonDecode(message as String);
          final location = LocationData.fromJson(data);
          
          if (location.id != _myId) {
            setState(() {
              _remoteUsers[location.id] = location;
            });
          }
        },
        onDone: () {
          setState(() {
            _isConnected = false;
          });
          // Reconnect after delay
          Future.delayed(const Duration(seconds: 3), _connectWebSocket);
        },
        onError: (error) {
          setState(() {
            _isConnected = false;
          });
          debugPrint('WS Error: $error');
        },
      );
      
      setState(() {
        _isConnected = true;
      });
    } catch (e) {
      debugPrint('WS Connect Error: $e');
      setState(() {
        _isConnected = false;
      });
      Future.delayed(const Duration(seconds: 3), _connectWebSocket);
    }
  }

  void _startLocationTracking() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      final myLocation = LocationData(
        id: _myId,
        lat: position.latitude,
        lng: position.longitude,
        deviceType: _deviceType,
      );

      _myLastLocation = myLocation;

      // Send to server
      if (_channel != null && _isConnected) {
        _channel!.sink.add(jsonEncode(myLocation.toJson()));
      }

      // Initial zoom
      if (!_hasZoomedToMe) {
        _mapController.move(LatLng(position.latitude, position.longitude), 15);
        _hasZoomedToMe = true;
      }

      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[];

    // Add remote users
    _remoteUsers.forEach((id, loc) {
      markers.add(
        Marker(
          point: LatLng(loc.lat, loc.lng),
          width: 80,
          height: 80,
          child: _buildMarker(id, loc.deviceType, Colors.blue),
        ),
      );
    });

    // Add myself
    if (_myLastLocation != null) {
      markers.add(
        Marker(
          point: LatLng(_myLastLocation!.lat, _myLastLocation!.lng),
          width: 80,
          height: 80,
          child: _buildMarker("You", _deviceType, Colors.green),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(0, 0),
              initialZoom: 2,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.flutter_app',
              ),
              MarkerLayer(markers: markers),
            ],
          ),
          
          // Info Panel (similar to the web version)
          Positioned(
            top: 50,
            right: 16,
            child: Card(
              color: Colors.white.withOpacity(0.9),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _infoText('My ID:', _myId),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _isConnected ? Colors.green[100] : Colors.red[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _isConnected ? 'Connected ✅' : 'Connecting...',
                            style: TextStyle(
                              color: _isConnected ? Colors.green[800] : Colors.red[800],
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _infoText('Device:', _deviceType),
                    const SizedBox(height: 4),
                    _infoText('Online:', '${_remoteUsers.length + (_myLastLocation != null ? 1 : 0)}'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_myLastLocation != null) {
            _mapController.move(LatLng(_myLastLocation!.lat, _myLastLocation!.lng), 15);
          }
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Widget _infoText(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black87, fontSize: 12),
        children: [
          TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: value),
        ],
      ),
    );
  }

  Widget _buildMarker(String title, String deviceType, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: const [BoxShadow(blurRadius: 2, color: Colors.black26)],
          ),
          child: Text(
            title,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Icon(Icons.location_on, color: color, size: 30),
      ],
    );
  }
}
