import 'package:flutter/material.dart';
import 'screens/tracker_screen.dart';

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
