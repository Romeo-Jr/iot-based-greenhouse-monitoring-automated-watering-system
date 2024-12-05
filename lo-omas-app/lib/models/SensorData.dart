class SensorData {
  final String id;
  final SensorReading reading;

  SensorData({required this.id, required this.reading});

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      id: json.keys.first,
      reading: SensorReading.fromJson(json[json.keys.first]),
    );
  }
}

class SensorReading {
  final DateTime dateTime;
  final double soilMoisture;
  final double temperature;
  final double humidity;
  final double ph;

  SensorReading({
    required this.dateTime,
    required this.soilMoisture,
    required this.temperature,
    required this.humidity,
    required this.ph,
  });

  factory SensorReading.fromJson(Map<String, dynamic> json) {
    return SensorReading(
      dateTime: DateTime.parse(json['datetime']),
      soilMoisture: json['soil_moisture'].toDouble(),
      temperature: json['temperature'].toDouble(),
      humidity: json['humidity'].toDouble(),
      ph: json['ph'].toDouble(),
    );
  }
}