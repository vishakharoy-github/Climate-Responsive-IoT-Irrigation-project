import 'package:flutter/material.dart';
import '../services/cloud_service.dart';
import '../models/sensor_data.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class SensorDetailsScreen extends StatefulWidget {
  @override
  _SensorDetailsScreenState createState() => _SensorDetailsScreenState();
}

class _SensorDetailsScreenState extends State<SensorDetailsScreen> {
  final _cloudService = CloudService();
  SensorData? _currentData;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscribeSensorData();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _subscribeSensorData() {
    _subscription = _cloudService.getSensorDataStream().listen((data) {
      if (mounted) {
        setState(() => _currentData = data);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sensor Details')),
      body: _currentData == null
          ? Center(child: CircularProgressIndicator())
          : ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildLastUpdatedCard(),
          SizedBox(height: 16),
          _buildSensorCard(
            'Soil Moisture',
            '${_currentData!.soilMoisture.toStringAsFixed(1)}%',
            Icons.water_drop,
            Colors.blue,
          ),
          SizedBox(height: 16),
          _buildSensorCard(
            'Temperature',
            '${_currentData!.temperature.toStringAsFixed(1)}°C',
            Icons.thermostat,
            Colors.orange,
          ),
          SizedBox(height: 16),
          _buildSensorCard(
            'Humidity',
            '${_currentData!.humidity.toStringAsFixed(1)}%',
            Icons.cloud,
            Colors.teal,
          ),
          SizedBox(height: 16),
          _buildStressCard(),
        ],
      ),
    );
  }

  Widget _buildLastUpdatedCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.access_time, size: 20),
            SizedBox(width: 8),
            Text(
              'Last Updated: ${DateFormat('h:mm:ss a').format(_currentData!.timestamp)}',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16)),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStressCard() {
    Color stressColor;
    switch (_currentData!.plantStress.toLowerCase()) {
      case 'low':
        stressColor = Colors.green;
        break;
      case 'normal':
        stressColor = Colors.blue;
        break;
      case 'moderate':
        stressColor = Colors.orange;
        break;
      case 'high':
        stressColor = Colors.red;
        break;
      default:
        stressColor = Colors.grey;
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: stressColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.spa, color: stressColor, size: 32),
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Plant Stress Level', style: TextStyle(fontSize: 16)),
                SizedBox(height: 4),
                Text(
                  _currentData!.plantStress,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: stressColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
