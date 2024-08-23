import 'package:az_weather/scr/models/weather_model.dart';
import 'package:flutter/material.dart';

import '../../../../../api_call.dart';

class DetailsWeather extends StatelessWidget {
  DetailsWeather({super.key});
  ApiCall apiCall = ApiCall();


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
                  color: Colors.black12,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(weatherForecastApi![index].main.temp.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                        Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(image: DecorationImage(image: NetworkImage('https://openweathermap.org/img/wn/${weatherForecastApi[index].weather[0].icon}@4x.png')))),
                        Text('${weatherForecastApi[index].main.tempMin.toString()}º',  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                        Text('${weatherForecastApi[index].main.tempMax.toString()}º',  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      ],
                    ),
                  ),
                );
              },
              // child: Card(
              //   child: Padding(
              //     padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         Text(weatherForecastApi!.first.main.temp.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
              //         Container(
              //             height: 60,
              //             width: 60,
              //             decoration: BoxDecoration(image: DecorationImage(image: NetworkImage('https://openweathermap.org/img/wn/${weatherForecastApi.first.weather[0].icon}@4x.png')))),
              //         Text('${weatherForecastApi!.first.main.tempMin.toString()}º',  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              //         Text('${weatherForecastApi!.first.main.tempMax.toString()}º',  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              //       ],
              //     ),
              //   ),
              // ),
            ),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}


