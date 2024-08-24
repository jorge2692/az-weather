import 'dart:async';
import 'dart:io';

import 'package:location/location.dart';

import 'models/location_response.dart';

class LocationCall{

  Location location = Location();

  double? latitude,longitude;

  /// Use location library to get long and lat data
  Future<void> getLocation(StreamController<LocationResponse?> locationStreamController)async{
    try {
      locationStreamController.sink.add(null);
      /// check location is enabled
      var service = await location.serviceEnabled();
      if(!service) {
        var service2 = await location.requestService();
        if(!service2) throw ();
      }
      /// check permission
      var permission = await location.hasPermission();
      if (permission == PermissionStatus.denied) {
        var permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          throw();
        }
      }
      LocationData locationData = await location.getLocation();
      latitude = locationData.latitude;
      longitude = locationData.longitude;
      locationStreamController.sink.add(LocationResponse(latitude: locationData.latitude ?? 0.0, longitude: locationData.longitude ?? 0.0));
    } catch (e) {
      locationStreamController.sink.addError(HttpStatus.badRequest);
    }
  }
}