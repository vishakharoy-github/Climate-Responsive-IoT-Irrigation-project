class AppConstants {
  static const String appName = 'Smart Irrigation';
  static const String baseUrl = 'https://your-backend-api.com/api';
  static const String mqttBroker = 'your-mqtt-broker.com';
  static const int mqttPort = 1883;

  // Crop types
  static const List<String> cropTypes = [
    'Rice',
    'Wheat',
    'Corn',
    'Cotton',
    'Vegetables',
    'Fruits',
  ];

  // Growth stages
  static const List<String> growthStages = [
    'Initial',
    'Development',
    'Mid-Season',
    'Late-Season',
  ];

  // Mock mode toggle
  static const bool useMockData = true;
}
