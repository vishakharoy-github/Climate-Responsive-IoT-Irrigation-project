import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const ProIotApp());

class ProIotApp extends StatelessWidget {
  const ProIotApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: const Color(0xFFf2f4f8),
    );
    return MaterialApp(
      title: 'Smart IoT Irrigation',
      theme: theme,
      debugShowCheckedModeBanner: false,
      home: const SmartDashboardPage(),
    );
  }
}

class SmartDashboardPage extends StatefulWidget {
  const SmartDashboardPage({super.key});
  @override
  State<SmartDashboardPage> createState() => _SmartDashboardPageState();
}

class _SmartDashboardPageState extends State<SmartDashboardPage> {
  double soilMoisture = 45.7;
  bool pumpOn = false;
  Map<String, dynamic>? weatherData;

  final String apiKey = '3fe50d5a19539aea9a0580f4a9e14a70';
  final String city = 'Bangalore';

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=$apiKey',
    );
    final res = await http.get(url);
    if (res.statusCode == 200) {
      setState(() => weatherData = jsonDecode(res.body));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: PreferredSize(
      preferredSize: const Size.fromHeight(65),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF512DA8), Color(0xFF6A1B9A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: AppBar(
          title: const Text('IoT Irrigation Dashboard'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF512DA8), Color(0xFF6A1B9A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
      children: [
        _weatherCard(),
        const SizedBox(height: 28),
        _sensorCard(context),
      ],
    ),
  );

  Widget _weatherCard() {
    if (weatherData == null) return Center(child: _animatedLoader());
    final temp = weatherData!['main']['temp'];
    final desc = weatherData!['weather'][0]['description'];
    final icon = weatherData!['weather'][0]['icon'];
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
            colors: [Color(0xFF80DEEA), Color(0xFF9FA8DA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        boxShadow: [
          BoxShadow(
              color: Colors.deepPurple.withAlpha(60),
              blurRadius: 22,
              offset: const Offset(0, 14))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20),
        child: Row(
          children: [
            Image.network(
              'https://openweathermap.org/img/wn/$icon@2x.png',
              width: 70,
              height: 70,
            ),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$city',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo)),
                Text('$temp°C',
                    style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Colors.deepPurple)),
                Text(
                  desc.toUpperCase(),
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.indigo.shade700,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sensorCard(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      color: const Color(0xFFF1EAFF),
      boxShadow: [
        BoxShadow(
            color: Colors.deepPurple.withAlpha(35),
            blurRadius: 20,
            offset: const Offset(0, 12))
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 28.0, horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Soil & Irrigation',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 21,
                  color: Color(0xFF5227CC))),
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(Icons.invert_colors, color: Colors.teal, size: 30),
              const SizedBox(width: 10),
              Text('Soil Moisture: ',
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 18,
                      color: Colors.grey[800])),
              Text('${soilMoisture.toStringAsFixed(1)}%',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.deepPurple)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                pumpOn ? Icons.water_damage : Icons.water_damage_outlined,
                color: pumpOn ? Colors.blueAccent : Colors.grey,
                size: 28,
              ),
              const SizedBox(width: 10),
              Text('Pump Status: ',
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 18,
                      color: Colors.grey[800])),
              Text(pumpOn ? 'ON' : 'OFF',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 21,
                      color: pumpOn ? Colors.green : Colors.red)),
              const SizedBox(width: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: pumpOn
                    ? const Icon(Icons.toggle_on,
                    key: ValueKey(true), size: 32, color: Colors.green)
                    : const Icon(Icons.toggle_off,
                    key: ValueKey(false), size: 32, color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ButtonStyle(
                padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 16)),
                backgroundColor: WidgetStateProperty.resolveWith(
                        (states) =>
                    pumpOn ? Colors.deepPurple : Colors.teal),
              ),
              onPressed: () {
                setState(() => pumpOn = !pumpOn);
              },
              child: Text(pumpOn ? 'Turn Pump OFF' : 'Turn Pump ON',
                  style: const TextStyle(
                      fontSize: 19, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _animatedLoader() => const SizedBox(
      width: 48, height: 48, child: CircularProgressIndicator(strokeWidth: 4));
}
