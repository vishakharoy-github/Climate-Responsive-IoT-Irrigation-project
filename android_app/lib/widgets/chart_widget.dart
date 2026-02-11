import 'package:flutter/material.dart';

class ChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;

  const ChartWidget({
    Key? key,
    required this.data,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            Container(
              height: 200,
              child: Center(
                child: Text('Chart placeholder - integrate fl_chart here'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
