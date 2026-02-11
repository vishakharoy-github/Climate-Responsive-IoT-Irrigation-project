import 'package:flutter/material.dart';

class IrrigationControlWidget extends StatelessWidget {
  final VoidCallback onAutomatic;
  final Function(double) onManual;
  final VoidCallback onCancel;

  const IrrigationControlWidget({
    Key? key,
    required this.onAutomatic,
    required this.onManual,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Irrigation Control',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showModeDialog(context),
                    icon: Icon(Icons.play_arrow),
                    label: Text('Start'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCancel,
                    icon: Icon(Icons.stop),
                    label: Text('Cancel'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showModeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choose Irrigation Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.smart_toy, color: Theme.of(context).primaryColor),
              title: Text('Automatic'),
              subtitle: Text('AI-controlled irrigation'),
              onTap: () {
                Navigator.pop(context);
                onAutomatic();
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.touch_app, color: Theme.of(context).primaryColor),
              title: Text('Manual'),
              subtitle: Text('You control the irrigation'),
              onTap: () {
                Navigator.pop(context);
                _showManualDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showManualDialog(BuildContext context) {
    double volume = 100;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Manual Irrigation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Water Volume: ${volume.toInt()} Liters'),
              Slider(
                value: volume,
                min: 50,
                max: 500,
                divisions: 45,
                label: '${volume.toInt()} L',
                onChanged: (value) => setState(() => volume = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onManual(volume);
              },
              child: Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}
