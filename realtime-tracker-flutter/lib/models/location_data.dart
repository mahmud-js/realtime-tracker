class LocationData {
  final String id;
  final double lat;
  final double lng;
  final String deviceType;
  final DateTime timestamp;

  LocationData({
    required this.id,
    required this.lat,
    required this.lng,
    required this.deviceType,
    required this.timestamp,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      id: json['id'] as String? ?? 'Unknown',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      deviceType: json['deviceType'] as String? ?? 'Unknown',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lat': lat,
      'lng': lng,
      'deviceType': deviceType,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationData &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
