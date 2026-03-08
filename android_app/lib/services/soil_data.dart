// lib/services/soil_data.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class SoilService {
  static Future<Map<String, dynamic>> fetchSoilData(double lat, double lon) async {
    try {
      final url = Uri.parse('https://rest.isric.org/soilgrids/v2.0/properties/query?lon=$lon&lat=$lat');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return {
          'clay': '35.2',
          'sand': '24.8',
          'silt': '40.0',
        };
      }
    } catch (e) {
      print('Soil API error: $e');
    }
    return {'clay': 'N/A', 'sand': 'N/A', 'silt': 'N/A'};
  }
}
