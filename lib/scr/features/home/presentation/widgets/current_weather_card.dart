import 'package:az_weather/api_call.dart';
import 'package:az_weather/scr/models/weather_current_model.dart';
import 'package:flutter/material.dart';

class CurrentWeatherCard extends StatelessWidget {
  CurrentWeatherCard({super.key});
  ApiCall apiCall = ApiCall();


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WeatherDataCurrent>(
      future: apiCall.weatherAPI(),
      builder: (BuildContext context, AsyncSnapshot<WeatherDataCurrent> snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: [
              Card(
                color: Colors.red,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(snapshot.data!.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                      Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(image: DecorationImage(image: NetworkImage('https://openweathermap.org/img/wn/${snapshot.data!.weather[0].icon}@4x.png')))),
                      Text((snapshot.data!.main.temp - 273.15).toStringAsFixed(0).toString(),  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40)),
                      Text(snapshot.data!.weather[0].main),
                      Text('Maxima: ${(snapshot.data!.main.tempMax - 273.15).toStringAsFixed(0).toString()} º Minima: ${(snapshot.data!.main.tempMin - 273.15).toStringAsFixed(0).toString()}º' )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20,),
            ],
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
