// lib/services/weather_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static Future<Map<String, dynamic>> fetchWeatherData(double lat, double lon) async {
    try {
      final url = Uri.parse(
          'https://power.larc.nasa.gov/api/temporal/hourly?'
              'parameters=T2M,RH2M&'
              'community=AG&'
              'longitude=$lon&'
              'latitude=$lat&'
              'start=20260301&'
              'end=20260307&'
              'format=JSON'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final parameters = data['properties']['parameter'];

        // Extract latest values safely
        final tempList = parameters['T2M'] as List<dynamic>? ?? [];
        final humList = parameters['RH2M'] as List<dynamic>? ?? [];

        final temperature = tempList.isNotEmpty ? tempList.last.toDouble() : 0.0;
        final humidity = humList.isNotEmpty ? humList.last.toDouble() : 0.0;

        return {
          'temperature': temperature.toStringAsFixed(1),
          'humidity': humidity.toStringAsFixed(1),
          'timestamp': DateTime.now().toString(),
        };
      }
    } catch (e) {
      print('Weather API Error: $e');
    }

    // Fallback mock data
    return {
      'temperature': '28.5',
      'humidity': '65.2',
      'timestamp': DateTime.now().toString(),
    };
  }
}
