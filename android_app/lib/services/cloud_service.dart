import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/farm_profile.dart';
import '../models/irrigation_schedule.dart';
import '../models/sensor_data.dart';
import 'mock_data_service.dart';

class CloudService {
  final MockDataService _mockService = MockDataService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveFarmProfile(FarmProfile profile) async {
    await _firestore.collection('farms').doc(profile.id).set({
      ...profile.toJson(),
      'weatherData': profile.weatherData,
      'soilData': profile.soilData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<FarmProfile>> getFarmProfiles() async {
    try {
      final snapshot = await _firestore
          .collection('farms')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return FarmProfile(
          id: doc.id,
          cropType: data['cropType'] ?? '',
          location: data['location'] ?? '',
          latitude: (data['latitude'] ?? 0.0).toDouble(),
          longitude: (data['longitude'] ?? 0.0).toDouble(),
          growthStage: data['growthStage'] ?? '',
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          weatherData: data['weatherData'],
          soilData: data['soilData'],
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Stream<SensorData> getSensorDataStream() {
    _mockService.startMockSensorUpdates();
    return _mockService.sensorStream;
  }

  // ✅ FIXED: Removed undefined named parameters
  Future<IrrigationSchedule> getIrrigationSchedule() async {
    return IrrigationSchedule(
      confidence: 0.85,
      nextIrrigationTime: DateTime.now().add(Duration(hours: 2)),
      irrigationTime: DateTime.now().add(Duration(hours: 2)),
      waterVolume: 25.0,        // ✅ Matches screen
      duration: 120,            // ✅ int minutes
      days: [true, false, true, false, true, false, true],
      isActive: true,
      recommendationType: 'AI-Optimized',  // ✅ Matches screen
    );
  }


  Future<void> startAutomaticIrrigation() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> startManualIrrigation(double volume) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> cancelIrrigation() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  List<Map<String, dynamic>> getHistoricalData(int days) {
    return _mockService.getMockHistoricalData(days);
  }
}
