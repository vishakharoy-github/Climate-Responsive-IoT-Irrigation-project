class WeatherData {
  final double temperature;
  final double humidity;
  final double windSpeed;
  final double rainfall;
  final double solarRadiation;
  final String forecast;

  WeatherData({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.rainfall,
    required this.solarRadiation,
    required this.forecast,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) => WeatherData(
    temperature: json['temperature']?.toDouble() ?? 0.0,
    humidity: json['humidity']?.toDouble() ?? 0.0,
    windSpeed: json['windSpeed']?.toDouble() ?? 0.0,
    rainfall: json['rainfall']?.toDouble() ?? 0.0,
    solarRadiation: json['solarRadiation']?.toDouble() ?? 0.0,
    forecast: json['forecast'] ?? 'Unknown',
  );
}
