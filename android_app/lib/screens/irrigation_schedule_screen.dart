import 'package:flutter/material.dart';
import '../services/cloud_service.dart';
import '../models/irrigation_schedule.dart';
import 'package:intl/intl.dart';

class IrrigationScheduleScreen extends StatefulWidget {
  const IrrigationScheduleScreen({super.key});  // ✅ Fix key warning

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
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final schedule = await _cloudService.getIrrigationSchedule();
      if (mounted) {
        setState(() {
          _schedule = schedule;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading schedule: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Irrigation Schedule')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadSchedule,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildScheduleCard(),
            const SizedBox(height: 16),
            _buildDetailsCard(),
            const SizedBox(height: 16),
            _buildRecommendationCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard() {
    if (_schedule == null) return const SizedBox.shrink();
    return Card(  // ✅ Removed private _ from public API
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Next Irrigation',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              DateFormat('EEEE, MMM d, yyyy').format(_schedule!.nextIrrigationTime),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              DateFormat('h:mm a').format(_schedule!.nextIrrigationTime),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    if (_schedule == null) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Irrigation Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _detailRow('Water Volume', '${_schedule!.waterVolume.toStringAsFixed(1)} L'),
            _detailRow('Duration', '${_schedule!.duration} minutes'),  // ✅ Duration type
            _detailRow('Confidence', '${(_schedule!.confidence * 100).toStringAsFixed(0)}%'),
            _detailRow('Type', _schedule!.recommendationType),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'AI Recommendations',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'AI-${_schedule?.recommendationType ?? 'Optimized'} schedule based on soil moisture, weather, and ${_schedule?.waterVolume.toStringAsFixed(1) ?? '0'}L crop needs.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
