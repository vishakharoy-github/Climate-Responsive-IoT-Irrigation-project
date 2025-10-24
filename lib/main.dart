import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const ProIotApp());

class ProIotApp extends StatelessWidget {
  const ProIotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart IoT Irrigation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFf2f4f8),
      ),
      home: const LoginPage(),
    );
  }
}

// ------------- LOGIN, SIGNUP, LOGOUT FLOW ------------

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AppHomeNav()),
    );
  }

  void _goToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpPage()),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
              const SizedBox(height: 20),
              _buildTextField(_passwordController, 'Password', Icons.lock,
                  obscure: true),
              const SizedBox(height: 26),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 56),
                    textStyle: const TextStyle(fontSize: 18)),
                child: const Text('Login'),
              ),
              const SizedBox(height: 14),
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
  const SignUpPage({super.key});
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
  Widget build(BuildContext context) => Scaffold(
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
              const SizedBox(height: 20),
              _buildTextField(_password, 'Password', Icons.lock,
                  obscure: true),
              const SizedBox(height: 26),
              ElevatedButton(
                onPressed: _signUp,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 56),
                    textStyle: const TextStyle(fontSize: 18)),
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    ),
  );

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

// ------------- NAVIGATION BAR + TABS --------------

class AppHomeNav extends StatefulWidget {
  const AppHomeNav({super.key});
  @override
  State<AppHomeNav> createState() => _AppHomeNavState();
}

class _AppHomeNavState extends State<AppHomeNav> {
  int _selectedIdx = 0;
  static const _pages = [
    DashboardPage(),
    HistoryPage(),
    ProfilePage(),
  ];

  void _onTap(int idx) => setState(() => _selectedIdx = idx);

  @override
  Widget build(BuildContext context) => Scaffold(
    body: _pages[_selectedIdx],
    bottomNavigationBar: NavigationBar(
      selectedIndex: _selectedIdx,
      onDestinationSelected: _onTap,
      destinations: const [
        NavigationDestination(
            icon: Icon(Icons.dashboard),
            selectedIcon: Icon(Icons.dashboard_customize),
            label: "Dashboard"),
        NavigationDestination(
            icon: Icon(Icons.history), label: "History"),
        NavigationDestination(
            icon: Icon(Icons.account_circle), label: "Profile"),
      ],
    ),
  );
}

// ------------- DASHBOARD TAB --------------

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double soilMoisture = 45.7;
  double waterLevel = 62.3;
  double temperature = 25.8;
  double humidity = 82;
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
    appBar: AppBar(
      title: const Text('IoT Irrigation Dashboard'),
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false),
          tooltip: "Logout",
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      children: [
        _weatherCard(),
        const SizedBox(height: 20),
        _statusSummaryCard(),
        const SizedBox(height: 20),
        _sensorCards(),
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
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
            colors: [Color(0xFFCE93D8), Color(0xFFBBDEFB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        boxShadow: [
          BoxShadow(
              color: Colors.deepPurple.withAlpha(60),
              blurRadius: 18,
              offset: const Offset(0, 10))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        child: Row(
          children: [
            Image.network(
              'https://openweathermap.org/img/wn/$icon@2x.png',
              width: 56,
              height: 56,
            ),
            const SizedBox(width: 18),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$city',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo)),
                Text('$temp°C',
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
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

  Widget _statusSummaryCard() => Container(
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.purple.shade50,
        boxShadow: [
          BoxShadow(
              color: Colors.deepPurple.withAlpha(28),
              blurRadius: 14,
              offset: const Offset(0, 5))
        ]),
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _verticalInfo('Water Level', '${waterLevel.toStringAsFixed(1)}%', Icons.opacity, Colors.indigo),
          _verticalInfo('Temperature', '${temperature.toStringAsFixed(1)}°C', Icons.thermostat, Colors.deepPurple),
          _verticalInfo('Humidity', '${humidity.toStringAsFixed(0)}%', Icons.water_drop, Colors.blue),
        ],
      ),
    ),
  );

  Widget _verticalInfo(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[800])),
        Text(value,
            style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: color)),
      ],
    );
  }

  Widget _sensorCards() => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.deepPurple.shade100.withAlpha(220),
      boxShadow: [
        BoxShadow(
            color: Colors.deepPurple.withAlpha(26),
            blurRadius: 12,
            offset: const Offset(0, 10))
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 28.0, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Soil/Irrigation Info',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF5227CC))),
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(Icons.invert_colors, color: Colors.teal, size: 28),
              const SizedBox(width: 10),
              Text('Soil Moisture: ',
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 18,
                      color: Colors.grey[800])),
              Text('${soilMoisture.toStringAsFixed(1)}%',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 21,
                      color: Colors.deepPurple)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                pumpOn ? Icons.water_damage : Icons.water_damage_outlined,
                color: pumpOn ? Colors.blueAccent : Colors.grey,
                size: 25,
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
                    key: ValueKey(true), size: 30, color: Colors.green)
                    : const Icon(Icons.toggle_off,
                    key: ValueKey(false), size: 30, color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                pumpOn ? Colors.green.shade700 : Colors.deepPurple,
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 68),
                textStyle: const TextStyle(fontSize: 17),
              ),
              onPressed: () {
                setState(() => pumpOn = !pumpOn);
              },
              child: Text(pumpOn ? 'Turn Pump OFF' : 'Turn Pump ON'),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _animatedLoader() => const SizedBox(
      width: 48, height: 48, child: CircularProgressIndicator(strokeWidth: 4));
}

// ----------- HISTORY TAB -------

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('History'),
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: List.generate(8, (idx) {
        final time = DateTime.now()
            .subtract(Duration(hours: idx * 6 + 2))
            .toString()
            .substring(0, 16);
        return Card(
          color: Colors.purple.shade50,
          margin: const EdgeInsets.only(bottom: 18),
          elevation: 4,
          child: ListTile(
            leading: Icon(
                idx % 2 == 0
                    ? Icons.opacity_rounded
                    : Icons.water_damage_rounded,
                color: idx % 2 == 0 ? Colors.teal : Colors.blue,
                size: 32),
            title: Text(
              idx % 2 == 0
                  ? 'Soil Moisture Recorded'
                  : 'Pump Operation',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
                idx % 2 == 0
                    ? 'Value: ${48.0 + idx * 3} %'
                    : idx % 3 == 0
                    ? "Pump turned OFF"
                    : "Pump turned ON",
                style: const TextStyle(fontSize: 15)),
            trailing:
            Text(time, style: const TextStyle(color: Colors.grey)),
          ),
        );
      }),
    ),
  );
}

// ----------- PROFILE TAB -------

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Profile'),
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
    ),
    body: Center(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 44),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(36.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                child: Icon(Icons.account_circle, size: 80),
              ),
              SizedBox(height: 24),
              Text('Your Name',
                  style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
              SizedBox(height: 8),
              Text(
                'IoT Smart Agriculture User\n\nEmail: youremail@example.com\nRole: Student/Developer',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
