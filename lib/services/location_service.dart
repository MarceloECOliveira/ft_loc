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

  /// Stream que emite a posição atual do usuário
  Stream<Position> get positionStream {
    _positionController ??= StreamController<Position>.broadcast();
    return _positionController!.stream;
  }

  /// Verifica se o serviço de localização está habilitado
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Solicita permissões de localização
  Future<bool> requestLocationPermission() async {
    // Verifica se o serviço de localização está habilitado
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Verifica a permissão atual
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Abre as configurações do app para o usuário habilitar manualmente
      await openAppSettings();
      return false;
    }

    return true;
  }

  /// Obtém a posição atual do usuário
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

  /// Inicia o monitoramento da localização em tempo real
  Future<void> startLocationTracking() async {
    try {
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        return;
      }

      // Configurações para o stream de localização
      LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Atualiza a cada 5 metros
      );

      // Cancela subscription anterior se existir
      await stopLocationTracking();

      _positionController ??= StreamController<Position>.broadcast();

      // Inicia o stream de posições
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

  /// Para o monitoramento da localização
  Future<void> stopLocationTracking() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  /// Calcula a distância entre duas posições em metros
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

  /// Libera recursos
  void dispose() {
    stopLocationTracking();
    _positionController?.close();
    _positionController = null;
  }
}
