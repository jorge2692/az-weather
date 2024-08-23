import 'package:az_weather/api_call.dart';
import 'package:az_weather/scr/features/home/presentation/widgets/details_weather.dart';
import 'package:flutter/material.dart';

class ForecastsScreen extends StatelessWidget {
  const ForecastsScreen({super.key, required this.apiCall});
  final ApiCall apiCall;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Pronosticos proximos'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: DetailsWeather(apiCall: apiCall),
    );
  }
}
