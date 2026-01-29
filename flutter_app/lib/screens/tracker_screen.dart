import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

import '../models/location_data.dart';
import '../services/location_service.dart';
import '../services/websocket_service.dart';
import '../widgets/info_panel.dart';
import '../widgets/map_marker.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  final String _myId = 'User-${const Uuid().v4().substring(0, 8)}';
  String _deviceType = 'Detecting...';
  
  // Local server IP or public URL
  final String _wsUrl = 'ws://localhost:8080/ws';
  
  WebSocketService? _wsService;
  StreamSubscription? _locationSubscription;
  bool _isConnected = false;
  
  final Map<String, LocationData> _remoteUsers = {};
  LocationData? _myLastLocation;
  
  final MapController _mapController = MapController();
  bool _hasZoomedToMe = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    _deviceType = await LocationService.getDeviceTypeInfo();
    
    // Connect to WebSocket
    _wsService = WebSocketService(
      url: _wsUrl,
      onConnected: () => setState(() => _isConnected = true),
      onDisconnected: () {
        setState(() => _isConnected = false);
        Future.delayed(const Duration(seconds: 3), () => _wsService?.connect());
      },
      onError: (err) {
        setState(() => _isConnected = false);
        debugPrint('WS Error: $err');
      },
      onMessageReceived: (data) {
        if (data.id != _myId) {
          setState(() {
            _remoteUsers[data.id] = data;
          });
        }
      },
    );
    _wsService?.connect();

    // Setup Location
    bool hasPermission = await LocationService.handleLocationPermission();
    if (hasPermission) {
      _startTracking();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
      }
    }
  }

  void _startTracking() {
    _locationSubscription = LocationService.getPositionStream().listen((position) {
      final myLocation = LocationData(
        id: _myId,
        lat: position.latitude,
        lng: position.longitude,
        deviceType: _deviceType,
      );

      setState(() => _myLastLocation = myLocation);

      if (_isConnected) {
        _wsService?.sendLocation(myLocation);
      }

      if (!_hasZoomedToMe) {
        _mapController.move(LatLng(position.latitude, position.longitude), 15);
        _hasZoomedToMe = true;
      }
    });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _wsService?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[];

    // Add remote user markers
    _remoteUsers.forEach((id, loc) {
      markers.add(
        Marker(
          point: LatLng(loc.lat, loc.lng),
          width: 80,
          height: 80,
          child: MapMarker(title: id, deviceType: loc.deviceType, color: Colors.blue),
        ),
      );
    });

    // Add my marker
    if (_myLastLocation != null) {
      markers.add(
        Marker(
          point: LatLng(_myLastLocation!.lat, _myLastLocation!.lng),
          width: 80,
          height: 80,
          child: MapMarker(title: "You", deviceType: _deviceType, color: Colors.green),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(0, 0),
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
          
          InfoPanel(
            myId: _myId,
            isConnected: _isConnected,
            deviceType: _deviceType,
            onlineCount: _remoteUsers.length + (_myLastLocation != null ? 1 : 0),
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
}
