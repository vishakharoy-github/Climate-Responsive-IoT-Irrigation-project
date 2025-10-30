import 'package:flutter/material.dart';
import '../services/cloud_service.dart';
import '../models/sensor_data.dart';
import '../models/irrigation_schedule.dart';
import '../models/weather_data.dart';
import '../widgets/sensor_card.dart';
import '../widgets/weather_card.dart';
import '../widgets/schedule_card.dart';
import '../widgets/irrigation_control_widget.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _cloudService = CloudService();

  SensorData? _currentSensorData;
  IrrigationSchedule? _schedule;
  WeatherData? _weatherData;
  bool _isLoading = true;
  StreamSubscription? _sensorSubscription;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _subscribeSensorData();
  }

  @override
  void dispose() {
    _sensorSubscription?.cancel();
    super.dispose();
  }

  void _subscribeSensorData() {
    _sensorSubscription = _cloudService.getSensorDataStream().listen((data) {
      if (mounted) {
        setState(() => _currentSensorData = data);
      }
    });
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);

    try {
      final schedule = await _cloudService.getIrrigationSchedule();
      final weather = await _cloudService.getWeatherData();

      if (mounted) {
        setState(() {
          _schedule = schedule;
          _weatherData = weather;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Irrigation Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _initializeData,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            SensorCard(sensorData: _currentSensorData),
            SizedBox(height: 16),
            WeatherCard(weatherData: _weatherData),
            SizedBox(height: 16),
            ScheduleCard(schedule: _schedule),
            SizedBox(height: 16),
            IrrigationControlWidget(
              onAutomatic: _handleAutomaticIrrigation,
              onManual: _handleManualIrrigation,
              onCancel: _handleCancelIrrigation,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/farm-setup');
          if (result == true) {
            _initializeData();
          }
        },
        child: Icon(Icons.add),
        tooltip: 'Add Farm Profile',
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.water_drop, size: 48, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  'Smart Irrigation',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.schedule),
            title: Text('Schedule'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/schedule');
            },
          ),
          ListTile(
            leading: Icon(Icons.sensors),
            title: Text('Sensor Details'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/sensor-details');
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: _handleLogout,
          ),
        ],
      ),
    );
  }

  Future<void> _handleAutomaticIrrigation() async {
    try {
      await _cloudService.startAutomaticIrrigation();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Automatic irrigation started')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start irrigation: $e')),
      );
    }
  }

  Future<void> _handleManualIrrigation(double volume) async {
    try {
      await _cloudService.startManualIrrigation(volume);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Manual irrigation started with ${volume.toInt()}L')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start irrigation: $e')),
      );
    }
  }

  Future<void> _handleCancelIrrigation() async {
    try {
      await _cloudService.cancelIrrigation();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Irrigation cancelled')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel irrigation: $e')),
      );
    }
  }

  Future<void> _handleLogout() async {
    // Implement logout logic
    Navigator.pushReplacementNamed(context, '/');
  }
}
