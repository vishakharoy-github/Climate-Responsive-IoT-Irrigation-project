import 'package:flutter/material.dart';
import '../services/cloud_service.dart';
import '../models/sensor_data.dart';
import '../models/irrigation_schedule.dart';
import '../models/weather_data.dart';
import '../models/farm_profile.dart';
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
  Map<String, dynamic>? _soilData;
  bool _isLoading = true;
  StreamSubscription? _sensorSubscription;
  List<FarmProfile> _farmProfiles = [];
  bool _hasRealFarmData = false;

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
      if (mounted) setState(() => _currentSensorData = data);
    });
  }

  // 🔥 FIXED: Enhanced data loading with DEBUG logs
  Future<void> _initializeData() async {
    setState(() => _isLoading = true);

    try {
      print('🔍 [DEBUG] Loading farm profiles...');

      // 🔥 STEP 1: Get ALL farm profiles with full document data
      final farmProfiles = await _cloudService.getFarmProfiles();

      print('🔍 [DEBUG] Raw farmProfiles count: ${farmProfiles.length}');
      for (var farm in farmProfiles) {
        print('🔍 [DEBUG] Farm ID: ${farm.id}');
        print('🔍 [DEBUG] Farm weatherData exists: ${farm.weatherData != null}');
        print('🔍 [DEBUG] Farm soilData exists: ${farm.soilData != null}');
        if (farm.soilData != null) {
          print('🔍 [DEBUG] Soil keys: ${farm.soilData!.keys.toList()}');
        }
      }

      final schedule = await _cloudService.getIrrigationSchedule();

      if (mounted) {
        setState(() {
          _farmProfiles = farmProfiles;
          _schedule = schedule;

          if (farmProfiles.isNotEmpty) {
            final farm = farmProfiles.first;
            _hasRealFarmData = true;

            // 🔥 FORCE parse even if null checks pass
            if (farm.weatherData != null) {
              try {
                _weatherData = WeatherData.fromJson(Map<String, dynamic>.from(farm.weatherData!));
                print('✅ [SUCCESS] Weather parsed');
              } catch (e) {
                print('❌ [ERROR] Weather parse failed: $e');
              }
            }

            if (farm.soilData != null) {
              try {
                _soilData = Map<String, dynamic>.from(farm.soilData!);
                print('✅ [SUCCESS] Soil parsed: clay=${_soilData!['clay']}');
              } catch (e) {
                print('❌ [ERROR] Soil parse failed: $e');
              }
            }
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ [ERROR] Dashboard init FAILED: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }


  // 🔥 NEW: Unified weather/soil section
  Widget _buildWeatherAndSoilSection() {
    if (_farmProfiles.isEmpty) {
      return _buildSetupCard();
    }

    List<Widget> cards = [];

    // Weather card
    if (_weatherData != null) {
      cards.add(WeatherCard(weatherData: _weatherData!));
      cards.add(SizedBox(height: 16));
    }

    // Soil card
    if (_soilData != null && _soilData!.isNotEmpty) {
      cards.add(_buildSoilCards());
      cards.add(SizedBox(height: 16));
    }

    // Partial data message
    if (cards.isEmpty && _hasRealFarmData) {
      cards.add(_buildPartialDataCard());
    }

    return Column(children: cards);
  }

  Widget _buildSoilCards() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.layers, color: Colors.brown[700], size: 24),
                SizedBox(width: 8),
                Text(
                  '🌾 Soil Properties (SoilGrids)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _buildSoilCard('${_soilData!['clay'] ?? 'N/A'}%', 'Clay', Colors.brown[600]!),
              _buildSoilCard('${_soilData!['sand'] ?? 'N/A'}%', 'Sand', Colors.yellow[700]!),
              _buildSoilCard('${_soilData!['silt'] ?? 'N/A'}%', 'Silt', Colors.grey[600]!),
            ]),
            SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _buildSoilCard(_soilData!['ph']?.toStringAsFixed(1) ?? 'N/A', 'pH', Colors.blue[600]!),
              _buildSoilCard('${_soilData!['organic_carbon'] ?? 'N/A'}%', 'OC', Colors.green[600]!),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSoilCard(String value, String label, Color color) {
    return Container(
      width: 85,
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Icon(Icons.layers, color: color, size: 28),
          SizedBox(height: 8),
          Text(value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16
              ),
              textAlign: TextAlign.center
          ),
          Text(label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center
          ),
        ],
      ),
    );
  }

  Widget _buildSetupCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.agriculture, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text('🌱 Setup Farm Profile',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center
            ),
            SizedBox(height: 8),
            Text('Add farm location for NASA POWER weather + SoilGrids data',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.pushNamed(context, '/farm-setup');
                if (result == true && mounted) {
                  await Future.delayed(Duration(seconds: 2)); // Wait for Firebase + API
                  await _initializeData();
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('🔄 Data refreshed from Firebase!'))
                  );
                }
              },
              icon: Icon(Icons.add_location_alt),
              label: Text('Setup Farm'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartialDataCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.info, color: Colors.blue),
            SizedBox(width: 12),
            Expanded(child: Text('Farm profile found. Tap refresh for latest weather/soil data.')),
            ElevatedButton(
              onPressed: _initializeData,
              child: Text('Refresh'),
            ),
          ],
        ),
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
              gradient: LinearGradient(
                  colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColorDark ?? Colors.green[800]!]
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.water_drop, size: 48, color: Colors.white),
                SizedBox(height: 8),
                Text('Smart Irrigation',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
                ),
              ],
            ),
          ),
          ListTile(leading: Icon(Icons.dashboard), title: Text('Dashboard'), onTap: () => Navigator.pop(context)),
          ListTile(leading: Icon(Icons.schedule), title: Text('Schedule'), onTap: () => Navigator.pushNamed(context, '/schedule')),
          ListTile(leading: Icon(Icons.sensors), title: Text('Sensor Details'), onTap: () => Navigator.pushNamed(context, '/sensor-details')),
          ListTile(leading: Icon(Icons.settings), title: Text('Settings'), onTap: () => Navigator.pushNamed(context, '/settings')),
          Divider(),
          ListTile(leading: Icon(Icons.logout), title: Text('Logout'), onTap: _handleLogout),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Irrigation Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              await _initializeData();
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('🔄 Refreshed from Firebase!'))
              );
            },
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading farm data...'),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _initializeData,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            SensorCard(sensorData: _currentSensorData),
            SizedBox(height: 16),

            // 🔥 FIXED: Unified section - shows cards OR setup
            _buildWeatherAndSoilSection(),

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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/farm-setup');
          if (result == true && mounted) {
            await Future.delayed(Duration(seconds: 2));
            await _initializeData();
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('✅ Weather + Soil data loaded!'))
            );
          }
        },
        icon: Icon(Icons.agriculture, color: Colors.white),
        label: Text('Farm Setup'),
        backgroundColor: Colors.green[600],
      ),
    );
  }

  Future<void> _handleAutomaticIrrigation() async {
    try {
      await _cloudService.startAutomaticIrrigation();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Automatic irrigation started')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Failed: $e')));
    }
  }

  Future<void> _handleManualIrrigation(double volume) async {
    try {
      await _cloudService.startManualIrrigation(volume);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Manual: ${volume.toInt()}L')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Failed: $e')));
    }
  }

  Future<void> _handleCancelIrrigation() async {
    try {
      await _cloudService.cancelIrrigation();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Cancelled')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Failed: $e')));
    }
  }

  Future<void> _handleLogout() async {
    Navigator.pushReplacementNamed(context, '/');
  }
}
