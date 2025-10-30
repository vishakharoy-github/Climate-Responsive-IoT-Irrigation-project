class IrrigationSchedule {
  final DateTime nextIrrigationTime;
  final double waterVolume;
  final double confidence;
  final Duration duration;
  final String recommendationType;

  IrrigationSchedule({
    required this.nextIrrigationTime,
    required this.waterVolume,
    required this.confidence,
    required this.duration,
    required this.recommendationType,
  });

  factory IrrigationSchedule.fromJson(Map<String, dynamic> json) =>
      IrrigationSchedule(
        nextIrrigationTime: DateTime.parse(json['nextIrrigationTime']),
        waterVolume: json['waterVolume']?.toDouble() ?? 0.0,
        confidence: json['confidence']?.toDouble() ?? 0.0,
        duration: Duration(minutes: json['durationMinutes'] ?? 30),
        recommendationType: json['recommendationType'] ?? 'AI-Optimized',
      );

  Map<String, dynamic> toJson() => {
    'nextIrrigationTime': nextIrrigationTime.toIso8601String(),
    'waterVolume': waterVolume,
    'confidence': confidence,
    'durationMinutes': duration.inMinutes,
    'recommendationType': recommendationType,
  };
}
