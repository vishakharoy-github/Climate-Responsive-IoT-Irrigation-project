import 'package:flutter/material.dart';
import '../services/cloud_service.dart';
import '../models/irrigation_schedule.dart';
import 'package:intl/intl.dart';

class IrrigationScheduleScreen extends StatefulWidget {
  @override
  _IrrigationScheduleScreenState createState() => _IrrigationScheduleScreenState();
}

class _IrrigationScheduleScreenState extends State<IrrigationScheduleScreen> {
  final _cloudService = CloudService();
  IrrigationSchedule? _schedule;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    setState(() => _isLoading = true);

    try {
      final schedule = await _cloudService.getIrrigationSchedule();
      setState(() {
        _schedule = schedule;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading schedule: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Irrigation Schedule')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadSchedule,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            _buildScheduleCard(),
            SizedBox(height: 16),
            _buildDetailsCard(),
            SizedBox(height: 16),
            _buildRecommendationCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard() {
    if (_schedule == null) return SizedBox.shrink();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: Theme.of(context).primaryColor),
                SizedBox(width: 8),
                Text(
                  'Next Irrigation',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              DateFormat('EEEE, MMM d, yyyy').format(_schedule!.nextIrrigationTime),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              DateFormat('h:mm a').format(_schedule!.nextIrrigationTime),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    if (_schedule == null) return SizedBox.shrink();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Irrigation Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            _detailRow('Water Volume', '${_schedule!.waterVolume.toStringAsFixed(1)} L'),
            _detailRow('Duration', '${_schedule!.duration.inMinutes} minutes'),
            _detailRow('Confidence', '${_schedule!.confidence.toStringAsFixed(1)}%'),
            _detailRow('Type', _schedule!.recommendationType),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Recommendations',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 12),
            Text(
              'This schedule is optimized based on current soil moisture, weather forecast, and crop water requirements.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
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
