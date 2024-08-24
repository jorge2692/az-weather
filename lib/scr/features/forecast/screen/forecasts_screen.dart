import 'package:az_weather/api_call.dart';
import 'package:az_weather/scr/features/home/presentation/widgets/details_weather.dart';
import 'package:flutter/material.dart';

class ForecastsScreen extends StatelessWidget {
  const ForecastsScreen({super.key, required this.apiCall});
  final ApiCall apiCall;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: const Text('Pronosticos proximos', style: TextStyle(color: Colors.white),),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white,),
        ),
      ),
      body: DetailsWeather(apiCall: apiCall),
    );
  }
}
