import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'providers/location_provider.dart';
import 'providers/websocket_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _requestPermissions();
  runApp(const MyApp());
}

Future<void> _requestPermissions() async {
  final status = await Permission.location.request();
  if (status.isDenied) {
    // Permission denied
    await Geolocator.requestPermission();
  } else if (status.isPermanentlyDenied) {
    // Permission permanently denied, open app settings
    openAppSettings();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WebSocketProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: MaterialApp(
        title: 'Real-Time Location Tracker',
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
