class Weather {
  final String city;
  final double temperature;
  final String condition;
  final String description;
  final double humidity;
  final double windSpeed;
  final String icon;

  Weather({
    required this.city,
    required this.temperature,
    required this.condition,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.icon,
  });
}

class WeatherForecast {
  final String day;
  final double maxTemp;
  final double minTemp;
  final String condition;
  final String icon;

  WeatherForecast({
    required this.day,
    required this.maxTemp,
    required this.minTemp,
    required this.condition,
    required this.icon,
  });
}