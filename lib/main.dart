import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key); // Added key parameter

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT Irrigation Dashboard',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const DashboardPage(), // Marked const for consistency
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key); // Added key parameter

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double soilMoisture = 0.0;
  bool pumpON = false;
  Map<String, dynamic>? weatherData;

  final String weatherApiKey = '3fe50d5a19539aea9a0580f4a9e14a70'; // Replace with your API key
  final String weatherCity = 'Bangalore'; // Replace with your city

  @override
  void initState() {
    super.initState();
    fetchSensorData();
    fetchWeather();
  }

  Future<void> fetchSensorData() async {
    try {
      final response = await http.get(Uri.parse('http://your-backend-url/sensor'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          soilMoisture = (data['soilMoisture'] ?? 0).toDouble();
          pumpON = data['pump'] ?? false;
        });
      }
    } catch (e) {
      // Handle error, possibly set default or show error to user
    }
  }

  Future<void> fetchWeather() async {
    try {
      final url =
          'https://api.openweathermap.org/data/2.5/weather?q=$weatherCity&units=metric&appid=$weatherApiKey';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        setState(() {
          weatherData = parsed;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  String getWeatherDescription() {
    if (weatherData == null) return 'Loading weather...';
    return weatherData!['weather'][0]['description'];
  }

  double getTemperature() {
    if (weatherData == null) return 0.0;
    return (weatherData!['main']['temp'] ?? 0).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Irrigation Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              fetchSensorData();
              fetchWeather();
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Soil Moisture: ${soilMoisture.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Text('Pump Status: ${pumpON ? "ON" : "OFF"}',
                style: TextStyle(
                    fontSize: 20,
                    color: pumpON ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold)),
            const Divider(height: 40),
            Text('Weather in $weatherCity',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            if (weatherData != null)
              Column(
                children: [
                  Text(
                    '${getTemperature()} °C',
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(
                    getWeatherDescription(),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              )
            else
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
