import 'package:cloud_firestore/cloud_firestore.dart';

class FarmProfile {
  final String id;
  final String cropType;
  final String location;
  final double latitude;
  final double longitude;
  final String growthStage;
  final DateTime createdAt;
  final Map<String, dynamic>? weatherData;  // ✅ ADDED: NASA data
  final Map<String, dynamic>? soilData;     // ✅ ADDED: SoilGrids data

  FarmProfile({
    required this.id,
    required this.cropType,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.growthStage,
    required this.createdAt,
    this.weatherData,
    this.soilData,
  });

  // ✅ Convert to JSON (for Firebase)
  Map<String, dynamic> toJson() => {
    'id': id,
    'cropType': cropType,
    'location': location,
    'latitude': latitude,
    'longitude': longitude,
    'growthStage': growthStage,
    'createdAt': createdAt,
    'weatherData': weatherData,
    'soilData': soilData,
  };

  // ✅ Convert from Firebase
  factory FarmProfile.fromJson(Map<String, dynamic> json) {
    return FarmProfile(
      id: json['id'] ?? '',
      cropType: json['cropType'] ?? '',
      location: json['location'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      growthStage: json['growthStage'] ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      weatherData: json['weatherData'],
      soilData: json['soilData'],
    );
  }

  // ✅ Copy with method
  FarmProfile copyWith({
    String? id,
    String? cropType,
    String? location,
    double? latitude,
    double? longitude,
    String? growthStage,
    DateTime? createdAt,
    Map<String, dynamic>? weatherData,
    Map<String, dynamic>? soilData,
  }) {
    return FarmProfile(
      id: id ?? this.id,
      cropType: cropType ?? this.cropType,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      growthStage: growthStage ?? this.growthStage,
      createdAt: createdAt ?? this.createdAt,
      weatherData: weatherData ?? this.weatherData,
      soilData: soilData ?? this.soilData,
    );
  }
}
