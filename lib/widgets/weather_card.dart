import 'package:flutter/material.dart';
import '../models/weather_data.dart';

class WeatherCard extends StatelessWidget {
  final WeatherData? weatherData;

  const WeatherCard({Key? key, this.weatherData}) : super(key: key);

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
                Icon(Icons.wb_sunny, color: Theme.of(context).primaryColor),
                SizedBox(width: 8),
                Text(
                  'Weather Forecast',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            SizedBox(height: 16),
            if (weatherData != null) ...[
              _dataRow('Temperature', '${weatherData!.temperature.toStringAsFixed(1)}°C'),
              _dataRow('Humidity', '${weatherData!.humidity.toStringAsFixed(1)}%'),
              _dataRow('Wind Speed', '${weatherData!.windSpeed.toStringAsFixed(1)} km/h'),
              _dataRow('Forecast', weatherData!.forecast),
            ] else
              Center(child: Text('Loading weather data...')),
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
