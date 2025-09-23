import 'package:flutter/material.dart';
import 'weather_model.dart';

class WeatherProvider extends ChangeNotifier {
  Weather? _currentWeather;
  List<WeatherForecast> _forecast = [];
  bool _isLoading = false;

  Weather? get currentWeather => _currentWeather;
  List<WeatherForecast> get forecast => _forecast;
  bool get isLoading => _isLoading;

  WeatherProvider() {
    _loadMockData();
  }

  void _loadMockData() {
    _isLoading = true;
    notifyListeners();

    // Simulate API delay
    Future.delayed(const Duration(seconds: 1), () {
      _currentWeather = Weather(
        city: 'New York',
        temperature: 22.5,
        condition: 'Partly Cloudy',
        description: 'A pleasant day with some clouds',
        humidity: 65.0,
        windSpeed: 8.5,
        icon: '⛅',
      );

      _forecast = [
        WeatherForecast(
          day: 'Today',
          maxTemp: 25.0,
          minTemp: 18.0,
          condition: 'Partly Cloudy',
          icon: '⛅',
        ),
        WeatherForecast(
          day: 'Tomorrow',
          maxTemp: 28.0,
          minTemp: 20.0,
          condition: 'Sunny',
          icon: '☀️',
        ),
        WeatherForecast(
          day: 'Wednesday',
          maxTemp: 24.0,
          minTemp: 16.0,
          condition: 'Rainy',
          icon: '🌧️',
        ),
        WeatherForecast(
          day: 'Thursday',
          maxTemp: 26.0,
          minTemp: 19.0,
          condition: 'Cloudy',
          icon: '☁️',
        ),
        WeatherForecast(
          day: 'Friday',
          maxTemp: 29.0,
          minTemp: 22.0,
          condition: 'Sunny',
          icon: '☀️',
        ),
      ];

      _isLoading = false;
      notifyListeners();
    });
  }

  void refreshWeather() {
    _loadMockData();
  }
}