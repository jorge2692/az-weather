import 'dart:async';

import 'package:az_weather/api_call.dart';
import 'package:az_weather/scr/location_call.dart';
import 'package:az_weather/scr/models/weather_current_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../models/location_response.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiCall apiCall = ApiCall(appId: 'ae288ab0b86574e84f8fce427c9d8280');

  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  late StreamController<WeatherDataCurrent?> _actualDataController;

  /// Uso de location
  final LocationCall _locationCall = LocationCall();
  double? lat,long;


  @override
  void initState() {
    super.initState();
    _actualDataController = StreamController<WeatherDataCurrent?>();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    _locationCall.getLocation();
  }

  @override
  void dispose() {
    _actualDataController.close();
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


  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    setState(() {
      _connectionStatus = result;
    });
  }

  Widget _connectionIcon(ConnectivityResult connectionStatus){
    if(connectionStatus.name == 'wifi') return const Icon(Icons.wifi);
    if(connectionStatus.name == 'mobile') return const Icon(Icons.signal_cellular_alt);
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        leading: _connectionIcon(_connectionStatus.first),
        actions: [
          GestureDetector(
              onTap: () => _locationCall.longitude != null || _locationCall.latitude != null ? apiCall.weatherAPI(
                  longitude: _locationCall.longitude,
                  latitude: _locationCall.latitude,
                  streamController: _actualDataController,
                  withRefresh: true
              ) : null,
              child: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<LocationResponse>(
          future: _locationCall.getLocation(),
          builder: (BuildContext context, AsyncSnapshot<LocationResponse> snapshot){
            ///TODO toca ver que poner en caso de errores
            if(snapshot.connectionState == ConnectionState.waiting){
              return const Center(child: Text('obteniendo localización ...'));
            }
            if(snapshot.hasData){
              apiCall.weatherAPI(longitude: _locationCall.longitude, latitude: _locationCall.latitude, streamController: _actualDataController, withRefresh: false);

              if(_connectionStatus.first.name == 'none'){
                return Column(
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
                    Text('No hay red disponible, por favor resvisar su conexion', textAlign: TextAlign.center),
                  ],
                );
              }

              return StreamBuilder<WeatherDataCurrent?>(
                stream: _actualDataController.stream,
                initialData: null,
                builder: (BuildContext context, AsyncSnapshot<WeatherDataCurrent?> snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return const Center(child: CircularProgressIndicator());
                  }
                  if(snapshot.hasData && snapshot.data == null){
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasData && snapshot.data != null) {
                    return Container(
                      height: double.infinity,
                      width: double.infinity,
                      color: Colors.deepPurpleAccent,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                height: 200,
                                width: 200,
                                decoration: BoxDecoration(image: DecorationImage(image: NetworkImage('https://openweathermap.org/img/wn/${snapshot.data!.weather.first.icon}@4x.png')))),
                            Card(
                              color: Colors.blueGrey.withOpacity(0.1),
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Text(snapshot.data!.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                                    Text((snapshot.data!.main.temp).toStringAsFixed(0).toString(),  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40)),
                                    Text(snapshot.data!.weather.first.main),
                                    Text('Maxima: ${(snapshot.data!.main.tempMax).toStringAsFixed(0).toString()} º Minima: ${(snapshot.data!.main.tempMin).toStringAsFixed(0).toString()}º' )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 25,),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Card(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _showData('Speed', '${(snapshot.data!.wind.speed).toStringAsFixed(0).toString()} m/s'),
                                        SizedBox(width: 25,),
                                        _showData('Humedad', '${(snapshot.data!.main.humidity).toStringAsFixed(0).toString()} %'),
                                        SizedBox(width: 25,),
                                        _showData('Presión', '${(snapshot.data!.main.pressure/1000).toStringAsFixed(2).toString()}'),
                                      ],
                                    ),Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _showData('Latitud', '${(snapshot.data!.coord.lat).toStringAsFixed(0).toString()} º'),
                                        SizedBox(width: 25,),
                                        _showData('Longitud', '${(snapshot.data!.coord.lon).toStringAsFixed(0).toString()} º'),
                                      ],
                                    ),
                                  ],
                                ),),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                                onPressed: () => Navigator.pushNamed(context, '/forecast', arguments: apiCall),
                                child: Text('Pronosticos proximos')),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              );
            }
            return const SizedBox();
          }
      )
    );
  }
Widget _showData(String titleData, String data){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(titleData, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        Text(data, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
}
}