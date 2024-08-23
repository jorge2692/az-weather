import 'package:az_weather/scr/features/home/presentation/widgets/details_weather.dart';
import 'package:flutter/material.dart';

class ForecastsScreen extends StatelessWidget {
  const ForecastsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: DetailsWeather(),
    );
  }
}
