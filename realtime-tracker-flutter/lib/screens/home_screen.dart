import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maplibre_gl/maplibre_gl.dart' as mg;

import '../providers/websocket_provider.dart';
import '../providers/location_provider.dart';
import 'widgets/info_panel.dart';
import 'widgets/notification_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late mg.MapLibreController mapController;
  final List<mg.Symbol> _symbols = [];
  String mapStyle = 'https://demotiles.maplibre.org/style.json'; // Free MapLibre style
  bool _userZoomed = false;

  @override
  void initState() {
    super.initState();
    _startSendingLocation();
  }

  void _startSendingLocation() {
    final wsProvider = context.read<WebSocketProvider>();
    final locationProvider = context.read<LocationProvider>();
    
    // Send location every 5 seconds
    Future.delayed(Duration.zero, () {
      Timer.periodic(const Duration(seconds: 5), (timer) {
        if (mounted) {
          final locationData = locationProvider.getCurrentLocationData(wsProvider.userId);
          wsProvider.sendLocation(locationData);
        }
      });
    });
  }

  void _updateMarkers(mg.MapLibreController controller) {
    final wsProvider = context.read<WebSocketProvider>();
    
    // Remove old symbols
    for (var symbol in _symbols) {
      controller.removeSymbol(symbol);
    }
    _symbols.clear();

    // Add new symbols for each connected user
    for (var location in wsProvider.connectedUsers) {
      _addMarker(controller, location);
    }
  }

  Future<void> _addMarker(mg.MapLibreController controller, dynamic location) async {
    try {
      final symbol = await controller.addSymbol(
        mg.SymbolOptions(
          geometry: mg.LatLng(location.lat, location.lng),
          iconImage: 'marker',
          textField: location.id == context.read<WebSocketProvider>().userId 
              ? 'You' 
              : location.id,
          textSize: 12,
          textColor: '#333333',
        ),
      );
      _symbols.add(symbol);

      // Zoom to user's location on first update
      if (location.id == context.read<WebSocketProvider>().userId && !_userZoomed) {
        _userZoomed = true;
        await controller.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(location.lat, location.lng),
            15,
          ),
        );
      }
    } catch (e) {
      print('Error adding marker: $e');
    }
  }

  void _changeMapStyle(String styleUrl) {
    setState(() {
      mapStyle = styleUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📍 Real Time Location Tracker'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Map
          Consumer2<WebSocketProvider, LocationProvider>(
            builder: (context, wsProvider, locationProvider, child) {
              return MapLibreMap(
                styleString: mapStyle,
                onMapCreated: (controller) {
                  mapController = controller;
                  _updateMarkers(controller);
                },
                initialCameraPosition: const CameraPosition(
                  target: LatLng(51.505, -0.09),
                  zoom: 13,
                ),
                onStyleLoadedCallback: () {
                  print('Map style loaded');
                },
              );
            },
          ),

          // Info Panel
          Positioned(
            top: 16,
            right: 16,
            child: Consumer<WebSocketProvider>(
              builder: (context, wsProvider, _) {
                return InfoPanel(
                  wsProvider: wsProvider,
                  onMapStyleChanged: _changeMapStyle,
                );
              },
            ),
          ),

          // Notification Widget
          const Positioned(
            bottom: 32,
            right: 16,
            child: NotificationWidget(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
