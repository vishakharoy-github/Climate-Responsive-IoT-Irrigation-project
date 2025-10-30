import 'dart:async';
import 'dart:math';
import '../models/sensor_data.dart';
import '../models/irrigation_schedule.dart';
import '../models/weather_data.dart';

class MockDataService {
  final Random _random = Random();
  Timer? _timer;

  final _sensorController = StreamController<SensorData>.broadcast();
  Stream<SensorData> get sensorStream => _sensorController.stream;

  void startMockSensorUpdates() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      final mockData = SensorData(
        soilMoisture: 30 + _random.nextDouble() * 40,
        temperature: 20 + _random.nextDouble() * 15,
        humidity: 40 + _random.nextDouble() * 40,
        plantStress: _getRandomStressLevel(),
        timestamp: DateTime.now(),
      );
      _sensorController.add(mockData);
    });
  }

  String _getRandomStressLevel() {
    final levels = ['Low', 'Normal', 'Moderate', 'High'];
    return levels[_random.nextInt(levels.length)];
  }

  Future<IrrigationSchedule> getMockSchedule() async {
    await Future.delayed(Duration(seconds: 1));

    return IrrigationSchedule(
      nextIrrigationTime: DateTime.now().add(Duration(hours: 6)),
      waterVolume: 150 + _random.nextDouble() * 100,
      confidence: 75 + _random.nextDouble() * 20,
      duration: Duration(minutes: 30),
      recommendationType: 'AI-Optimized',
    );
  }

  Future<WeatherData> getMockWeather() async {
    await Future.delayed(Duration(milliseconds: 500));

    return WeatherData(
      temperature: 25 + _random.nextDouble() * 10,
      humidity: 50 + _random.nextDouble() * 30,
      windSpeed: 5 + _random.nextDouble() * 10,
      rainfall: _random.nextDouble() * 5,
      solarRadiation: 200 + _random.nextDouble() * 600,
      forecast: ['Sunny', 'Partly Cloudy', 'Cloudy', 'Rainy'][_random.nextInt(4)],
    );
  }

  List<Map<String, dynamic>> getMockHistoricalData(int days) {
    List<Map<String, dynamic>> data = [];
    DateTime now = DateTime.now();

    for (int i = days; i > 0; i--) {
      data.add({
        'date': now.subtract(Duration(days: i)),
        'soilMoisture': 35 + _random.nextDouble() * 30,
        'waterUsed': 100 + _random.nextDouble() * 100,
        'temperature': 22 + _random.nextDouble() * 10,
      });
    }
    return data;
  }

  void dispose() {
    _timer?.cancel();
    _sensorController.close();
  }
}
