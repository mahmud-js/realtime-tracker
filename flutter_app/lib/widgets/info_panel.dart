import 'package:flutter/material.dart';

class InfoPanel extends StatelessWidget {
  final String myId;
  final bool isConnected;
  final String deviceType;
  final int onlineCount;

  const InfoPanel({
    super.key,
    required this.myId,
    required this.isConnected,
    required this.deviceType,
    required this.onlineCount,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      right: 16,
      child: Card(
        color: Colors.white.withAlpha(230),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _infoText('My ID:', myId),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text('Status: ', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isConnected ? Colors.green[100] : Colors.red[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isConnected ? 'Connected ✅' : 'Connecting...',
                      style: TextStyle(
                        color: isConnected ? Colors.green[800] : Colors.red[800],
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _infoText('Device:', deviceType),
              const SizedBox(height: 4),
              _infoText('Online:', onlineCount.toString()),
            ],
          ),
        ),
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
}
