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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff3DA7B8),
            Color(0xff515076)
          ],
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          Expanded(
            child: FutureBuilder<ApiResponse>(
              future: apiCall.weatherForecastAPI(),
              builder: (BuildContext context, AsyncSnapshot<ApiResponse> snapshot) {
                if (snapshot.hasData) {
                  var weatherForecastApi = snapshot.data?.list;
                  return SizedBox(
                    height: double.infinity,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data?.list.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Card(
                            elevation: 0,
                            color: Colors.white.withOpacity(0.3),
                            child: ListTile(
                              leading: Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(image: DecorationImage(image: NetworkImage('https://openweathermap.org/img/wn/${weatherForecastApi![index].weather[0].icon}@4x.png')))),
                              title: Text(
                               'Temp. Actual: ${weatherForecastApi[index].main.temp.toStringAsFixed(0).toString()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),),
                              subtitle: Row(
                                children: [
                                  Text('Min: ${weatherForecastApi[index].main.tempMin.toStringAsFixed(0).toString()}º ',  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15,color: Colors.white)),
                                  Text('Max: ${weatherForecastApi[index].main.tempMax.toStringAsFixed(0).toString()}º ',  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15,color: Colors.white)),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('${weatherForecastApi[index].dtTxt.day.toString()}/${weatherForecastApi[index].dtTxt.month.toString()}',  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10,color: Colors.white)),
                                  Text('${weatherForecastApi[index].dtTxt.hour.toString()}:00',  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10,color: Colors.white)),
                                ],
                              ),
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
            ),
          ),
        ],
      ),
    );
  }
}


