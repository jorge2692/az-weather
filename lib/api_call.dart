import 'dart:async';

import 'package:az_weather/scr/models/weather_current_model.dart';
import 'package:az_weather/scr/models/weather_model.dart';
import 'package:dio/dio.dart';

class ApiCall {
  final String appId;

  final Dio dio = Dio();

  double? _lat,_lon;

  ApiCall({required this.appId});

  Future<void> weatherAPI(
      {double? longitude, double? latitude, required StreamController streamController, required bool withRefresh}) async {
    if(withRefresh) streamController.sink.add(null);
    _lat = latitude;
    _lon = longitude;
    var response = await dio.get(
        'https://api.openweathermap.org/data/2.5/weather?lat=$_lat&lon=$_lon&appid=$appId&units=metric&lang=es');

    streamController.sink.add(WeatherDataCurrent.fromJson(response.data));
  }

  Future<ApiResponse> weatherForecastAPI() async {
    var response = await dio.get(
        'https://api.openweathermap.org/data/2.5/forecast?lat=$_lat&lon=$_lon&appid=$appId&units=metric&lang=es');
    return ApiResponse.fromJson(response.data);
  }
}
