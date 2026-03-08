import 'package:flutter/material.dart';

class IrrigationSchedule {
  final DateTime nextIrrigationTime;
  final DateTime irrigationTime;
  final double waterVolume;      // ✅ For Screen
  final double confidence;
  final int duration;            // ✅ int for CloudService, screen uses as minutes
  final List<bool> days;         // ✅ For CloudService
  final bool isActive;           // ✅ For CloudService
  final String recommendationType; // ✅ For Screen

  IrrigationSchedule({
    required this.nextIrrigationTime,
    required this.irrigationTime,
    required this.waterVolume,
    required this.confidence,
    required this.duration,
    required this.days,
    required this.isActive,
    required this.recommendationType,
  });

  factory IrrigationSchedule.fromJson(Map<String, dynamic> json) =>
      IrrigationSchedule(
        nextIrrigationTime: DateTime.parse(json['nextIrrigationTime']),
        irrigationTime: DateTime.parse(json['irrigationTime'] ?? json['nextIrrigationTime']),
        waterVolume: json['waterVolume']?.toDouble() ?? json['volume']?.toDouble() ?? 25.0,
        confidence: json['confidence']?.toDouble() ?? 0.0,
        duration: json['duration'] ?? json['durationMinutes'] ?? 30,
        days: List<bool>.from(json['days'] ?? [true, false, true, false, true, false, true]),
        isActive: json['isActive'] ?? false,
        recommendationType: json['recommendationType'] ?? 'AI-Optimized',
      );

  Map<String, dynamic> toJson() => {
    'nextIrrigationTime': nextIrrigationTime.toIso8601String(),
    'irrigationTime': irrigationTime.toIso8601String(),
    'waterVolume': waterVolume,
    'volume': waterVolume,  // ✅ Backward compatibility
    'confidence': confidence,
    'duration': duration,
    'durationMinutes': duration,  // ✅ For legacy
    'days': days,
    'isActive': isActive,
    'recommendationType': recommendationType,
  };
}
