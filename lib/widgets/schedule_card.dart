import 'package:flutter/material.dart';
import '../models/irrigation_schedule.dart';
import 'package:intl/intl.dart';

class ScheduleCard extends StatelessWidget {
  final IrrigationSchedule? schedule;

  const ScheduleCard({Key? key, this.schedule}) : super(key: key);

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
                Icon(Icons.schedule, color: Theme.of(context).primaryColor),
                SizedBox(width: 8),
                Text(
                  'Next Irrigation',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            SizedBox(height: 16),
            if (schedule != null) ...[
              Text(
                'Time: ${DateFormat('MMM d, h:mm a').format(schedule!.nextIrrigationTime)}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Volume: ${schedule!.waterVolume.toStringAsFixed(1)} liters',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Confidence: ${schedule!.confidence.toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Chip(
                label: Text(schedule!.recommendationType),
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
              ),
            ] else
              Center(child: Text('No schedule available')),
          ],
        ),
      ),
    );
  }
}
