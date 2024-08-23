import 'package:az_weather/scr/models/weather_model.dart';
import 'package:flutter/material.dart';

import '../../../../../api_call.dart';

///TODO aca le faltaria poner hora y fecha del pronostico
///ademas de revisar si pone todas o solo pone 3 dias entonces tiene que ver cual usa
class DetailsWeather extends StatelessWidget {

  const DetailsWeather({super.key, required this.apiCall});

  final ApiCall apiCall;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResponse>(
      future: apiCall.weatherForecastAPI(),
      builder: (BuildContext context, AsyncSnapshot<ApiResponse> snapshot) {
        if (snapshot.hasData) {
          var weatherForecastApi = snapshot.data?.list;
          return Container(
            height: double.infinity,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data?.list.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(image: DecorationImage(image: NetworkImage('https://openweathermap.org/img/wn/${weatherForecastApi![index].weather[0].icon}@4x.png')))),
                    title: Text(
                     'Temp. Actual: ${weatherForecastApi[index].main.temp.toStringAsFixed(0).toString()}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                    subtitle: Row(
                      children: [
                        Text('Min: ${weatherForecastApi[index].main.tempMin.toStringAsFixed(0).toString()}º ',  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('Max: ${weatherForecastApi[index].main.tempMax.toStringAsFixed(0).toString()}º ',  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${weatherForecastApi[index].dtTxt.day.toString()}/${weatherForecastApi[index].dtTxt.month.toString()}',  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                        Text('${weatherForecastApi[index].dtTxt.hour.toString()}:00',  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                      ],
                    ),
                  ),
                );
                },
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}


