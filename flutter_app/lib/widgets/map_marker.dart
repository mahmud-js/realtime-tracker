import 'package:flutter/material.dart';

class MapMarker extends StatelessWidget {
  final String title;
  final String deviceType;
  final Color color;

  const MapMarker({
    super.key,
    required this.title,
    required this.deviceType,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
