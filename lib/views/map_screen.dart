import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:ft_loc/services/location_service.dart'; // Importe o serviço de localização
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    required this.salaInicio,
    required this.salaDestino,
  });

  final Map<String, dynamic> salaInicio;
  final Map<String, dynamic> salaDestino;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService.instance;

  Position? _currentPosition;
  StreamSubscription<Position>? _positionSubscription;
  bool _isTrackingLocation = false;
  bool _centerOnUser = true;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  /// Inicializa a localização do usuário
  Future<void> _initializeLocation() async {
    try {
      // Obtém a posição atual
      Position? position = await _locationService.getCurrentPosition();
      if (position != null) {
        setState(() {
          _currentPosition = position;
        });
      }

      // Inicia o rastreamento em tempo real
      await _startLocationTracking();
    } catch (e) {
      debugPrint('Erro ao inicializar localização: $e');
      _showLocationError();
    }
  }

  /// Inicia o rastreamento da localização em tempo real
  Future<void> _startLocationTracking() async {
    await _locationService.startLocationTracking();

    _positionSubscription = _locationService.positionStream.listen(
      (Position position) {
        setState(() {
          _currentPosition = position;
          _isTrackingLocation = true;
        });

        // Centraliza o mapa na posição do usuário se a opção estiver ativada
        if (_centerOnUser) {
          _mapController.move(
            LatLng(position.latitude, position.longitude),
            _mapController.camera.zoom,
          );
        }
      },
      onError: (error) {
        debugPrint('Erro no stream de localização: $error');
        setState(() {
          _isTrackingLocation = false;
        });
      },
    );
  }

  /// Para o rastreamento da localização
  void _stopLocationTracking() {
    _positionSubscription?.cancel();
    _locationService.stopLocationTracking();
    setState(() {
      _isTrackingLocation = false;
    });
  }

  /// Centraliza o mapa na posição atual do usuário
  void _centerMapOnUser() {
    if (_currentPosition != null) {
      _mapController.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        18.0,
      );
    }
  }

  /// Mostra erro de localização
  void _showLocationError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Erro ao obter localização. Verifique as permissões.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Calcula a distância até o destino
  String _getDistanceToDestination() {
    if (_currentPosition == null) return '';

    double distance = _locationService.calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      widget.salaDestino["lat"],
      widget.salaDestino["lng"],
    );

    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)}m até o destino';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km até o destino';
    }
  }

  @override
  Widget build(BuildContext context) {
    final start = LatLng(widget.salaInicio["lat"], widget.salaInicio["lng"]);
    final end = LatLng(widget.salaDestino["lat"], widget.salaDestino["lng"]);

    // Lista de marcadores
    List<Marker> markers = [
      // Marcador da sala de início
      Marker(
        point: start,
        child: const Icon(Icons.location_on, color: Colors.green, size: 25),
      ),
      // Marcador da sala de destino
      Marker(
        point: end,
        child: const Icon(Icons.flag, color: Colors.red, size: 25),
      ),
    ];

    // Adiciona marcador da posição atual do usuário se disponível
    if (_currentPosition != null) {
      markers.add(
        Marker(
          point: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 5),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 15),
          ),
        ),
      );
    }

    // Linha da rota
    final polyline = Polyline(
      points: [start, end],
      strokeWidth: 3,
      color: Colors.blue,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Rota: ${widget.salaInicio["nome"]} → ${widget.salaDestino["nome"]}",
        ),
        actions: [
          // Botão para alternar rastreamento
          IconButton(
            icon: Icon(
              _isTrackingLocation ? Icons.location_on : Icons.location_off,
              color: _isTrackingLocation ? Colors.green : Colors.grey,
            ),
            onPressed: () {
              if (_isTrackingLocation) {
                _stopLocationTracking();
              } else {
                _startLocationTracking();
              }
            },
          ),
          // Botão para centralizar no usuário
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _centerMapOnUser,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: start,
              initialZoom: 18,
              maxZoom: 23,
              // minZoom: 17,
              onTap: (tapPosition, point) {
                // Desativa centralização automática quando o usuário toca no mapa
                setState(() {
                  _centerOnUser = false;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "com.example.ft_loc",
              ),
              MarkerLayer(markers: markers),
              PolylineLayer(polylines: [polyline]),
            ],
          ),
          // Informações na parte inferior
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.1 * 255).round()),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isTrackingLocation ? Icons.gps_fixed : Icons.gps_off,
                        color: _isTrackingLocation ? Colors.green : Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isTrackingLocation
                            ? 'Localização ativa'
                            : 'Localização inativa',
                        style: TextStyle(
                          color: _isTrackingLocation
                              ? Colors.green
                              : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (_currentPosition != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _getDistanceToDestination(),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Botão para reativar centralização automática
          if (!_centerOnUser)
            Positioned(
              top: 16,
              right: 16,
              child: FloatingActionButton.small(
                onPressed: () {
                  setState(() {
                    _centerOnUser = true;
                  });
                  _centerMapOnUser();
                },
                child: const Icon(Icons.center_focus_strong),
              ),
            ),
        ],
      ),
    );
  }
}
