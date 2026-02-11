import 'package:flutter/material.dart';
import '../models/sensor_data.dart';

class SensorCard extends StatelessWidget {
  final SensorData? sensorData;

  const SensorCard({Key? key, this.sensorData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sensors, color: Theme.of(context).primaryColor),
                SizedBox(width: 8),
                Text(
                  'Real-Time Sensor Data',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            SizedBox(height: 16),
            if (sensorData != null) ...[
              _dataRow('Soil Moisture', '${sensorData!.soilMoisture.toStringAsFixed(1)}%'),
              _dataRow('Temperature', '${sensorData!.temperature.toStringAsFixed(1)}°C'),
              _dataRow('Humidity', '${sensorData!.humidity.toStringAsFixed(1)}%'),
              _dataRow('Plant Stress', sensorData!.plantStress),
            ] else
              Center(child: Text('Waiting for sensor data...')),
          ],
        ),
      ),
    );
  }

  Widget _dataRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
