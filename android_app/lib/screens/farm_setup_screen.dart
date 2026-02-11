import 'package:flutter/material.dart';
import '../services/cloud_service.dart';
import '../models/farm_profile.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

class FarmSetupScreen extends StatefulWidget {
  @override
  _FarmSetupScreenState createState() => _FarmSetupScreenState();
}

class _FarmSetupScreenState extends State<FarmSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cloudService = CloudService();

  final _locationController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  String _cropType = AppConstants.cropTypes[0];
  String _growthStage = AppConstants.growthStages[0];
  bool _isLoading = false;

  @override
  void dispose() {
    _locationController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _saveFarmProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      FarmProfile profile = FarmProfile(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        cropType: _cropType,
        location: _locationController.text,
        latitude: double.parse(_latitudeController.text),
        longitude: double.parse(_longitudeController.text),
        growthStage: _growthStage,
        createdAt: DateTime.now(),
      );

      await _cloudService.saveFarmProfile(profile);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Farm profile saved successfully')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Farm Profile Setup')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Text(
              'Farm Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _cropType,
              decoration: InputDecoration(
                labelText: 'Crop Type',
                prefixIcon: Icon(Icons.agriculture),
              ),
              items: AppConstants.cropTypes
                  .map((crop) => DropdownMenuItem(
                value: crop,
                child: Text(crop),
              ))
                  .toList(),
              onChanged: (value) => setState(() => _cropType = value!),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location Name',
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (value) => Validators.required(value, 'Location'),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _latitudeController,
              decoration: InputDecoration(
                labelText: 'Latitude',
                prefixIcon: Icon(Icons.map),
                hintText: 'e.g., 28.6139',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) => Validators.number(value, 'Latitude'),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _longitudeController,
              decoration: InputDecoration(
                labelText: 'Longitude',
                prefixIcon: Icon(Icons.map),
                hintText: 'e.g., 77.2090',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) => Validators.number(value, 'Longitude'),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _growthStage,
              decoration: InputDecoration(
                labelText: 'Growth Stage',
                prefixIcon: Icon(Icons.eco),
              ),
              items: AppConstants.growthStages
                  .map((stage) => DropdownMenuItem(
                value: stage,
                child: Text(stage),
              ))
                  .toList(),
              onChanged: (value) => setState(() => _growthStage = value!),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveFarmProfile,
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
