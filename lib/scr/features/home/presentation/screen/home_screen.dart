import 'dart:async';

import 'package:az_weather/api_call.dart';
import 'package:az_weather/scr/location_call.dart';
import 'package:az_weather/scr/models/weather_current_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../main.dart';
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
  double? lat, long;
  bool isDarkMode = false;
  late StreamController<LocationResponse?> _locationStreamController;

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _actualDataController = StreamController<WeatherDataCurrent?>.broadcast();
    _locationStreamController = StreamController<LocationResponse?>.broadcast();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    _locationCall.getLocation(_locationStreamController);
  }

  @override
  void dispose() {
    _actualDataController.close();
    _locationStreamController.close();
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

  Widget _connectionIcon(ConnectivityResult connectionStatus) {
    if (connectionStatus.name == 'wifi') return const Icon(Icons.wifi, color: Colors.white);
    if (connectionStatus.name == 'mobile') return const Icon(Icons.signal_cellular_alt, color: Colors.white);
    return const SizedBox();
  }

  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  void _saveTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', value);
  }


  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
      _saveTheme(isDarkMode);
      final mode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
      MyApp.of(context)!.setThemeMode(mode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: _connectionIcon(_connectionStatus.first),
          actions: [
            GestureDetector(
                onTap: () => _locationCall.longitude != null ||
                        _locationCall.latitude != null
                    ? apiCall.weatherAPI(
                        longitude: _locationCall.longitude,
                        latitude: _locationCall.latitude,
                        streamController: _actualDataController,
                        withRefresh: true,
                        isConnect: _connectionStatus.first.name == 'none'
                )
                    : null,
                child: const Icon(Icons.refresh, color: Colors.white)),
          ],
        ),
        body: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: !isDarkMode ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xff3DA7B8), Color(0xff515076)],
            ) : const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.black, Colors.white10],
            ),
          ),
          child: StreamBuilder<LocationResponse?>(
              stream: _locationStreamController.stream,
              builder: (BuildContext context,
                  AsyncSnapshot<LocationResponse?> snapshot) {
                ///TODO toca ver que poner en caso de errores
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: Text('Obteniendo localización ...',
                          style: TextStyle(color: Colors.white)));
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                            'Revisa que tengas los permisos y/o la ubicación activados',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white)),
                      ),
                      GestureDetector(
                          onTap: () => _locationCall
                              .getLocation(_locationStreamController),
                          child:
                              const Icon(Icons.refresh, color: Colors.white)),
                    ],
                  ));
                }

                if (snapshot.data == null) {
                  return const Center(
                      child: Text('Obteniendo localización ...',
                          style: TextStyle(color: Colors.white)));
                }

                if (snapshot.hasData) {
                  apiCall.weatherAPI(
                      longitude: _locationCall.longitude,
                      latitude: _locationCall.latitude,
                      streamController: _actualDataController,
                      withRefresh: false,
                      isConnect: _connectionStatus.first.name == 'none'
                  );

                  if (_connectionStatus.first.name == 'none' && !snapshot.hasData) {
                    return Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Expanded(child: SizedBox()),
                        Container(
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.signal_wifi_connected_no_internet_4,
                            size: MediaQuery.of(context).size.height * 0.150,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'No hay red disponible, por favor revisar su conexion',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                      ],
                    );
                  }

                  return StreamBuilder<WeatherDataCurrent?>(
                    stream: _actualDataController.stream,
                    initialData: null,
                    builder: (BuildContext context,
                        AsyncSnapshot<WeatherDataCurrent?> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.data == null) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasData && snapshot.data != null) {
                        return SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _connectionStatus.first.name == 'none'  ? Container(
                                  margin: EdgeInsets.only(
                                    top: MediaQuery.of(context).orientation ==
                                        Orientation.portrait
                                        ? MediaQuery.of(context).size.height *
                                        0.1
                                        : 0,
                                  ),
                                  height: 200,
                                  width: 200,
                                  child: const Icon(Icons.wifi_off, size: 150,)) : Container(
                                  height: 200,
                                  width: 200,
                                  margin: EdgeInsets.only(
                                    top: MediaQuery.of(context).orientation ==
                                            Orientation.portrait
                                        ? MediaQuery.of(context).size.height *
                                            0.1
                                        : 0,
                                  ),
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: NetworkImage(
                                              'https://openweathermap.org/img/wn/${snapshot.data!.weather.first.icon}@4x.png')))),
                              Card(
                                color: Colors.white.withOpacity(0.1),
                                elevation: 0,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        snapshot.data!.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colors.white),
                                      ),
                                      Text(
                                          '${(snapshot.data!.main.temp).toStringAsFixed(0).toString()} º',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 40,
                                              color: Colors.white)),
                                      Text(
                                          snapshot
                                              .data!.weather.first.description,
                                          style: const TextStyle(
                                              color: Colors.white)),
                                      Text(
                                        'Maxima: ${(snapshot.data!.main.tempMax).toStringAsFixed(0).toString()} º Minima: ${(snapshot.data!.main.tempMin).toStringAsFixed(0).toString()}º',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 25),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Card(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          _showData('Speed',
                                              '${(snapshot.data!.wind.speed).toStringAsFixed(0).toString()} m/s'),
                                          const SizedBox(width: 25),
                                          _showData('Humedad',
                                              '${(snapshot.data!.main.humidity).toStringAsFixed(0).toString()} %'),
                                          const SizedBox(width: 25),
                                          _showData(
                                              'Presión',
                                              (snapshot.data!.main.pressure /
                                                      1000)
                                                  .toStringAsFixed(2)
                                                  .toString()),
                                        ],
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          _showData('Latitud',
                                              '${(snapshot.data!.coord.lat).toStringAsFixed(0).toString()} º'),
                                          const SizedBox(
                                            width: 25,
                                          ),
                                          _showData('Longitud',
                                              '${(snapshot.data!.coord.lon).toStringAsFixed(0).toString()} º'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                  onPressed: () => Navigator.pushNamed(
                                      context, '/forecast',
                                      arguments: apiCall),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Pronosticos proximos',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      SizedBox(width: 20),
                                      Icon(Icons.arrow_forward_ios)
                                    ],
                                  )),
                              ElevatedButton(
                                  onPressed: _toggleTheme,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        isDarkMode ? 'Modo Claro' : 'Modo Oscuro',
                                        style: const TextStyle(color: Colors.black),
                                      ),
                                      const SizedBox(width: 20),
                                      Icon(isDarkMode ? Icons.light_mode : Icons.nightlight_round)
                                    ],
                                  )),
                            ],
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  );
                }
                return const SizedBox();
              }),
        ));
  }

  Widget _showData(String titleData, String data) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(titleData,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        Text(data,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }
}
