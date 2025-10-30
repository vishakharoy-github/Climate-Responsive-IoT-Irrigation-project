import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/farm_profile.dart';
import '../models/irrigation_schedule.dart';
import '../models/sensor_data.dart';
import '../models/weather_data.dart';
import '../utils/constants.dart';
import 'mock_data_service.dart';

class CloudService {
  final MockDataService _mockService = MockDataService();

  Future<void> saveFarmProfile(FarmProfile profile) async {
    if (AppConstants.useMockData) {
      await Future.delayed(Duration(seconds: 1));
      print('Mock: Farm profile saved');
      return;
    }

    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/farm-profile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(profile.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save farm profile');
    }
  }

  Future<IrrigationSchedule> getIrrigationSchedule() async {
    if (AppConstants.useMockData) {
      return _mockService.getMockSchedule();
    }

    final response = await http.get(Uri.parse('${AppConstants.baseUrl}/irrigation-schedule'));

    if (response.statusCode == 200) {
      return IrrigationSchedule.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load schedule');
    }
  }

  Future<WeatherData> getWeatherData() async {
    if (AppConstants.useMockData) {
      return _mockService.getMockWeather();
    }

    final response = await http.get(Uri.parse('${AppConstants.baseUrl}/weather'));

    if (response.statusCode == 200) {
      return WeatherData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<void> startAutomaticIrrigation() async {
    if (AppConstants.useMockData) {
      await Future.delayed(Duration(seconds: 1));
      print('Mock: Automatic irrigation started');
      return;
    }

    await http.post(
      Uri.parse('${AppConstants.baseUrl}/irrigation/start-automatic'),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<void> startManualIrrigation(double volume) async {
    if (AppConstants.useMockData) {
      await Future.delayed(Duration(seconds: 1));
      print('Mock: Manual irrigation started with $volume liters');
      return;
    }

    await http.post(
      Uri.parse('${AppConstants.baseUrl}/irrigation/start-manual'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'volume': volume}),
    );
  }

  Future<void> cancelIrrigation() async {
    if (AppConstants.useMockData) {
      await Future.delayed(Duration(milliseconds: 500));
      print('Mock: Irrigation cancelled');
      return;
    }

    await http.post(Uri.parse('${AppConstants.baseUrl}/irrigation/cancel'));
  }

  Stream<SensorData> getSensorDataStream() {
    if (AppConstants.useMockData) {
      _mockService.startMockSensorUpdates();
      return _mockService.sensorStream;
    }

    throw UnimplementedError('Real sensor stream not implemented yet');
  }

  List<Map<String, dynamic>> getHistoricalData(int days) {
    return _mockService.getMockHistoricalData(days);
  }
}
