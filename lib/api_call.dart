import 'dart:async';
import 'dart:convert';

import 'package:az_weather/scr/models/weather_current_model.dart';
import 'package:az_weather/scr/models/weather_model.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiCall {
  final String appId;

  final Dio dio = Dio();

  double? _lat,_lon;

  bool? isNConnect;

  ApiCall({required this.appId});

  Future<void> weatherAPI(
      {double? longitude, double? latitude, required StreamController streamController, required bool withRefresh, required bool isConnect}) async {
    final prefsWeather = await SharedPreferences.getInstance();
    if(withRefresh) streamController.sink.add(null);
    _lat = latitude;
    _lon = longitude;
    isNConnect = isConnect;

    if(isConnect) {
      final jsonData = prefsWeather.getString('weatherData');
      final dataW = jsonDecode(jsonData!);
      streamController.sink.add(WeatherDataCurrent.fromJson(dataW));
      return;
    }

    var response = await dio.get(
        'https://api.openweathermap.org/data/2.5/weather?lat=$_lat&lon=$_lon&appid=$appId&units=metric&lang=es');

    final jsonData = jsonEncode(response.data);
    await prefsWeather.setString('weatherData', jsonData);

    streamController.sink.add(WeatherDataCurrent.fromJson(response.data));
  }

  Future<ApiResponse> weatherForecastAPI() async {
    final prefsWeather = await SharedPreferences.getInstance();

    if(isNConnect!) {
      final jsonData = prefsWeather.getString('weatherDataCurrent');
      final dataW = jsonDecode(jsonData!);
      return ApiResponse.fromJson(dataW);
    }

    var response = await dio.get(
        'https://api.openweathermap.org/data/2.5/forecast?lat=$_lat&lon=$_lon&appid=$appId&units=metric&lang=es');

    final jsonData = jsonEncode(response.data);
    await prefsWeather.setString('weatherDataCurrent', jsonData);
    return ApiResponse.fromJson(response.data);
  }
}
