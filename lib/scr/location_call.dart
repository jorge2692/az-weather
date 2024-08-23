import 'package:location/location.dart';

import 'models/location_response.dart';

class LocationCall{

  Location location = Location();

  double? latitude,longitude;

  /// TODO esto pide permisos lanza errores y lanza localizacion pero revise si se coloca
  Future<void> requestPermission() async {

    bool? _serviceEnabled;
    PermissionStatus? _permissionGranted;

    // Verificar si los servicios están habilitados.
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        print('error perro');
        return;
      }
    }

    // Verificar el estado del permiso.
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        print('error');
        return;
      }
    }

    // Obtener la ubicación actual.
    try {
      LocationData locationData = await location.getLocation();
      print('perro aca hace location');
      print('longitude: ${locationData.longitude}');
      print('longitude: ${locationData.longitude}');
    } catch (e) {
      print('error perro');
    }
  }


  Future<LocationResponse> getLocation()async{
    try {
      LocationData locationData = await location.getLocation();
      print('longitude: ${locationData.longitude}');
      print('latitude: ${locationData.latitude}');
      latitude = locationData.latitude;
      longitude = locationData.longitude;
      return LocationResponse(latitude: locationData.latitude ?? 0.0, longitude: locationData.longitude ?? 0.0);
    } catch (e) {
      throw();
    }
  }
}