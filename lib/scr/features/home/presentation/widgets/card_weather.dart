import 'package:az_weather/api_call.dart';
import 'package:flutter/material.dart';


class CardWeather extends StatelessWidget {
  const CardWeather({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Column(
          children: [
            Icon(Icons.cloud, size: 60,),
            Text('',  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Text('Nublado'),
          ],
        ),
      ),
    );
  }
}
