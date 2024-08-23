import 'dart:async';

import 'package:az_weather/api_call.dart';
import 'package:az_weather/scr/features/home/presentation/widgets/card_weather.dart';
import 'package:az_weather/scr/features/home/presentation/widgets/details_weather.dart';
import 'package:az_weather/scr/models/weather_current_model.dart';
import 'package:az_weather/scr/models/weather_forecast_model.dart';
import 'package:az_weather/scr/models/weather_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ApiCall apiCall = ApiCall();
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;


  @override
  void initState() {
    super.initState();
    initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      await Permission.location.request();
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e);
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  // Future<dynamic> _getLocation() async{
  //   LocationData _currentLocation = await location.getLocation();
  //
  //   return _currentLocation;
  // }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    setState(() {
      _connectionStatus = result;
    });
  }

  Widget _connectionIcon(ConnectivityResult connectionStatus){
    if(connectionStatus.name == 'wifi') return Icon(Icons.wifi);
    if(connectionStatus.name == 'mobile') return Icon(Icons.signal_cellular_alt);
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        leading: _connectionIcon(_connectionStatus.first)
      ),
      body: Container(
        width: double.infinity,
        color: Colors.deepPurpleAccent,
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: List.generate(
                _connectionStatus.length,
                (index) =>
                    Center(
                      child: _connectionStatus[index].name == 'none' ? Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 100),
                            child: Container(
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.grey.withOpacity(0.3)),
                              alignment: Alignment.center,
                              child: Icon(
                                  Icons.signal_wifi_connected_no_internet_4, size: MediaQuery.of(context).size.height * 0.150,),
                            ),
                          ),
                          Text('No hay red disposible, por favor resvisar su conexion', textAlign: TextAlign.center),
                        ],
                      ) :
                      FutureBuilder<WeatherDataCurrent>(
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
                                            decoration: BoxDecoration(image: DecorationImage(image: NetworkImage('https://openweathermap.org/img/wn/${snapshot.data!.weather[index].icon}@4x.png')))),
                                        Text((snapshot.data!.main.temp - 273.15).toStringAsFixed(0).toString(),  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40)),
                                        Text(snapshot.data!.weather[index].main),
                                        Text('Maxima: ${(snapshot.data!.main.tempMax - 273.15).toStringAsFixed(0).toString()} º Minima: ${(snapshot.data!.main.tempMin - 273.15).toStringAsFixed(0).toString()}º' )
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20,),
                                Container(
                                  height: 150,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: 3,
                                    itemBuilder: (context, index) {
                                      return CardWeather();
                                    },
                                  ),
                                ),
                                SizedBox(height: 20,),
                                DetailsWeather(),
                              ],
                            );
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        },
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}



// Column(
//   children: [
//     const Card(
//       child: Padding(
//         padding: EdgeInsets.all(8.0),
//         child: Column(
//           children: [
//             Text('Bogota', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
//             Icon(Icons.cloud, size: 60,),
//             Text('13 º',  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40)),
//             Text('Nublado'),
//             Text('Maxima: 21 º Minima: 9 º' )
//           ],
//         ),
//       ),
//     ),
//     SizedBox(height: 20,),
//     Container(
//       height: 150,
//       child: ListView.builder(
//         shrinkWrap: true,
//         scrollDirection: Axis.horizontal,
//         itemCount: 3,
//         itemBuilder: (context, index) {
//           return CardWeather();
//         },
//       ),
//     ),
//     SizedBox(height: 20,),
//     Container(
//       height: double.maxFinite,
//       child: ListView.builder(
//         shrinkWrap: true,
//         itemCount: 3,
//         itemBuilder: (context, index) {
//           return DetailsWeather();
//         },
//       ),
//     ),
//   ],
// ),