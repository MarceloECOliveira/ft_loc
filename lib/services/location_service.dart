import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._();
  LocationService._();

  StreamController<Position>? _positionController;
  StreamSubscription<Position>? _positionSubscription;

  
  Stream<Position> get positionStream {
    _positionController ??= StreamController<Position>.broadcast();
    return _positionController!.stream;
  }

  
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  
  Future<bool> requestLocationPermission() async {
    
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      
      await openAppSettings();
      return false;
    }

    return true;
  }

  
  Future<Position?> getCurrentPosition() async {
    try {
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      return position;
    } catch (e) {
      debugPrint('Erro ao obter posição atual: $e');
      return null;
    }
  }

  
  Future<void> startLocationTracking() async {
    try {
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        return;
      }

      
      LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, 
      );

      
      await stopLocationTracking();

      _positionController ??= StreamController<Position>.broadcast();

      
      _positionSubscription =
          Geolocator.getPositionStream(
            locationSettings: locationSettings,
          ).listen(
            (Position position) {
              _positionController?.add(position);
            },
            onError: (error) {
              debugPrint('Erro no stream de localização: $error');
            },
          );
    } catch (e) {
      debugPrint('Erro ao iniciar rastreamento de localização: $e');
    }
  }

  
  Future<void> stopLocationTracking() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  
  void dispose() {
    stopLocationTracking();
    _positionController?.close();
    _positionController = null;
  }
}
