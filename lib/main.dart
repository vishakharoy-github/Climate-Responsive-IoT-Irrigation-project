import 'package:flutter/material.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/farm_setup_screen.dart';
import 'screens/irrigation_schedule_screen.dart';
import 'screens/sensor_details_screen.dart';
import 'screens/settings_screen.dart';
import 'utils/theme.dart';

void main() {
  runApp(IrrigationApp());
}

class IrrigationApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Climate-Responsive Irrigation',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => AuthScreen(),
        '/home': (context) => HomeScreen(),
        '/farm-setup': (context) => FarmSetupScreen(),
        '/schedule': (context) => IrrigationScheduleScreen(),
        '/sensor-details': (context) => SensorDetailsScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}
