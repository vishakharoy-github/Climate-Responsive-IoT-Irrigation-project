import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT Irrigation Dashboard',
      theme: ThemeData(primarySwatch: Colors.green),
      home: DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double soilMoisture = 0.0;
  bool pumpON = false;
  Map<String, dynamic>? weatherData;

  final String weatherApiKey = 'YOUR_OPENWEATHERMAP_API_KEY';
  final String weatherCity = 'YourCity'; // Change to nearby city or location

  @override
  void initState() {
    super.initState();
    fetchSensorData();
    fetchWeather();
  }

  Future<void> fetchSensorData() async {
    // Replace below URL with your IoT backend API that returns JSON like {"soilMoisture": 45.0, "pump": true}
    final response = await http.get(Uri.parse('http://your-backend-url/sensor'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        soilMoisture = data['soilMoisture']?.toDouble() ?? 0.0;
        pumpON = data['pump'] ?? false;
      });
    }
  }

  Future<void> fetchWeather() async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$weatherCity&units=metric&appid=$weatherApiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      setState(() {
        weatherData = parsed;
      });
    }
  }

  String getWeatherDescription() {
    if (weatherData == null) return 'Loading weather...';
    return weatherData!['weather'][0]['description'];
  }

  double getTemperature() {
    if (weatherData == null) return 0.0;
    return weatherData!['main']['temp'].toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IoT Irrigation Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              fetchSensorData();
              fetchWeather();
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Soil Moisture: ${soilMoisture.toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 20)),
            SizedBox(height: 8),
            Text('Pump Status: ${pumpON ? "ON" : "OFF"}',
                style: TextStyle(
                    fontSize: 20,
                    color: pumpON ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold)),
            Divider(height: 40),
            Text('Weather in $weatherCity',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            if (weatherData != null)
              Column(
                children: [
                  Text(
                    '${getTemperature()} °C',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    getWeatherDescription(),
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              )
            else
              CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
