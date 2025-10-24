import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  static const String title = 'Climate Responsive IoT Dashboard';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF7FAFA),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 26),
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardPage()),
    );
  }

  void _goToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  'IoT Irrigation Login',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                _buildTextField(_emailController, 'Email', Icons.email),
                const SizedBox(height: 16),
                _buildTextField(_passwordController, 'Password', Icons.lock,
                    obscure: true),
                const SizedBox(height: 30),
                ElevatedButton(onPressed: _login, child: const Text('Login')),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _goToSignUp,
                  child: const Text('Don’t have an account? Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFEFF7F6),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  void _signUp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account created! Please log in.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                _buildTextField(_email, 'Email', Icons.email),
                const SizedBox(height: 16),
                _buildTextField(_password, 'Password', Icons.lock, obscure: true),
                const SizedBox(height: 30),
                ElevatedButton(onPressed: _signUp, child: const Text('Sign Up')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFEFF7F6),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double soilMoisture = 45.3;
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
        'https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=$apiKey');
    final res = await http.get(url);

    if (res.statusCode == 200) {
      setState(() {
        weatherData = jsonDecode(res.body);
      });
    }
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Irrigation Dashboard'),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout))
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchWeather,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildWeatherCard(),
            const SizedBox(height: 20),
            _buildSensorCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    if (weatherData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final temp = weatherData!['main']['temp'];
    final desc = weatherData!['weather'][0]['description'];
    final icon = weatherData!['weather'][0]['icon'];

    return Card(
      color: const Color(0xFFEAFBF9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Image.network(
                'https://openweathermap.org/img/wn/$icon@2x.png',
                width: 70,
                height: 70),
            Text(
              '$city',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text('$temp°C', style: const TextStyle(fontSize: 28)),
            Text(
              desc.toUpperCase(),
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorCard() {
    return Card(
      color: const Color(0xFFEFFBF2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Soil & Irrigation Status',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Soil Moisture: ${soilMoisture.toStringAsFixed(1)} %',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              'Pump Status: ${pumpOn ? "ON" : "OFF"}',
              style: TextStyle(
                fontSize: 18,
                color: pumpOn ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() => pumpOn = !pumpOn);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: pumpOn ? Colors.red : Colors.teal,
              ),
              child: Text(pumpOn ? 'Turn Pump OFF' : 'Turn Pump ON'),
            ),
          ],
        ),
      ),
    );
  }
}
