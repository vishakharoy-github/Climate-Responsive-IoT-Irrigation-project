class FarmProfile {
  final String id;
  final String cropType;
  final String location;
  final double latitude;
  final double longitude;
  final String growthStage;
  final DateTime createdAt;

  FarmProfile({
    required this.id,
    required this.cropType,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.growthStage,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'cropType': cropType,
    'location': location,
    'latitude': latitude,
    'longitude': longitude,
    'growthStage': growthStage,
    'createdAt': createdAt.toIso8601String(),
  };

  factory FarmProfile.fromJson(Map<String, dynamic> json) => FarmProfile(
    id: json['id'],
    cropType: json['cropType'],
    location: json['location'],
    latitude: json['latitude'],
    longitude: json['longitude'],
    growthStage: json['growthStage'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}
