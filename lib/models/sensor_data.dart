class SensorData {
  final double soilMoisture;
  final double temperature;
  final double humidity;
  final String plantStress;
  final DateTime timestamp;

  SensorData({
    required this.soilMoisture,
    required this.temperature,
    required this.humidity,
    required this.plantStress,
    required this.timestamp,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) => SensorData(
    soilMoisture: json['soilMoisture']?.toDouble() ?? 0.0,
    temperature: json['temperature']?.toDouble() ?? 0.0,
    humidity: json['humidity']?.toDouble() ?? 0.0,
    plantStress: json['plantStress'] ?? 'Normal',
    timestamp: json['timestamp'] != null
        ? DateTime.parse(json['timestamp'])
        : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'soilMoisture': soilMoisture,
    'temperature': temperature,
    'humidity': humidity,
    'plantStress': plantStress,
    'timestamp': timestamp.toIso8601String(),
  };
}
