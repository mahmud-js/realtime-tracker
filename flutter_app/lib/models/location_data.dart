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
