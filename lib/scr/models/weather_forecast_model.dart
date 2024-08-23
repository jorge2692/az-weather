import 'dart:convert';

import 'package:az_weather/scr/models/weather_model.dart';

class WeatherForecastApi {
  int dt;
  MainClass main;
  List<Weather> weather;
  Clouds clouds;
  Wind wind;
  int visibility;
  double pop;
  Sys sys;
  DateTime dtTxt;
  Rain? rain;

  WeatherForecastApi({
    required this.dt,
    required this.main,
    required this.weather,
    required this.clouds,
    required this.wind,
    required this.visibility,
    required this.pop,
    required this.sys,
    required this.dtTxt,
    this.rain,
  });

  factory WeatherForecastApi.fromRawJson(String str) => WeatherForecastApi.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory WeatherForecastApi.fromJson(Map<String, dynamic> json) => WeatherForecastApi(
    dt: json["dt"],
    main: MainClass.fromJson(json["main"]),
    weather: List<Weather>.from(json["weather"].map((x) => Weather.fromJson(x))),
    clouds: Clouds.fromJson(json["clouds"]),
    wind: Wind.fromJson(json["wind"]),
    visibility: json["visibility"],
    pop: json["pop"]?.toDouble(),
    sys: Sys.fromJson(json["sys"]),
    dtTxt: DateTime.parse(json["dt_txt"]),
    rain: json["rain"] == null ? null : Rain.fromJson(json["rain"]),
  );

  Map<String, dynamic> toJson() => {
    "dt": dt,
    "main": main.toJson(),
    "weather": List<dynamic>.from(weather.map((x) => x.toJson())),
    "clouds": clouds.toJson(),
    "wind": wind.toJson(),
    "visibility": visibility,
    "pop": pop,
    "sys": sys.toJson(),
    "dt_txt": dtTxt.toIso8601String(),
    "rain": rain?.toJson(),
  };
}