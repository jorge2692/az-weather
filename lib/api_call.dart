import 'package:az_weather/scr/models/weather_current_model.dart';
import 'package:az_weather/scr/models/weather_model.dart';
import 'package:dio/dio.dart';

class ApiCall {
  Future<WeatherDataCurrent> weatherAPI() async {
    Dio dio = Dio();
    var response = await dio.get(
        'https://api.openweathermap.org/data/2.5/weather?lat=44.34&lon=10.99&appid=ae288ab0b86574e84f8fce427c9d8280');
    return WeatherDataCurrent.fromJson(response.data);
  }

  Future<ApiResponse> weatherForecastAPI() async {
    Dio dio = Dio();
    var response = await dio.get(
        'https://api.openweathermap.org/data/2.5/forecast?lat=44.34&lon=10.99&appid=ae288ab0b86574e84f8fce427c9d8280');
    return ApiResponse.fromJson(response.data);
  }
}
