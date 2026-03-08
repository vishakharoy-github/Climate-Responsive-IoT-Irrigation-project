import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';  // ✅ NEW: Auto-generated!
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/farm_setup_screen.dart';
import 'screens/irrigation_schedule_screen.dart';
import 'screens/sensor_details_screen.dart';
import 'screens/settings_screen.dart';
import 'utils/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ USE Generated options!
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
