import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:ft_loc/services/location_service.dart';
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
  bool _isLiveRouteActive = false;

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

  Future<void> _initializeLocation() async {
    try {
      Position? position = await _locationService.getCurrentPosition();
      if (position != null) {
        setState(() {
          _currentPosition = position;
        });
      }

      await _startLocationTracking();
    } catch (e) {
      debugPrint("Erro ao inicializar localização: $e");
      _showLocationError();
    }
  }

  Future<void> _startLocationTracking() async {
    await _locationService.startLocationTracking();

    _positionSubscription = _locationService.positionStream.listen(
      (Position position) {
        if (mounted) {
          setState(() {
            _currentPosition = position;
            _isTrackingLocation = true;
          });
          if (_centerOnUser) {
            _mapController.move(
              LatLng(position.latitude, position.longitude),
              _mapController.camera.zoom,
            );
          }
        }
      },
      onError: (error) {
        debugPrint("Erro no stream de localização: $error");
        if (mounted) {
          setState(() {
            _isTrackingLocation = false;
          });
        }
      },
    );
  }

  void _stopLocationTracking() {
    _positionSubscription?.cancel();
    _locationService.stopLocationTracking();
    setState(() {
      _isTrackingLocation = false;
    });
  }

  void _centerMapOnUser() async {
    bool hasPermission = await _locationService.requestLocationPermission();

    if (hasPermission && mounted) {
      if (_currentPosition != null) {
        _mapController.move(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          18.0,
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Para usar esta função, por favor, ative a permissão de localização.",
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _centerMapOnDestination() {
    _mapController.move(
      LatLng(widget.salaDestino["lat"], widget.salaDestino["lng"]),
      18.0,
    );
  }

  void _showLocationError() {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erro ao obter localização. Verifique as permissões."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getDistanceToDestination() {
    if (_currentPosition == null) return "";

    double distance = _locationService.calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      widget.salaDestino["lat"],
      widget.salaDestino["lng"],
    );

    if (distance < 1000) {
      return "${distance.toStringAsFixed(0)}m até o destino";
    } else {
      return "${(distance / 1000).toStringAsFixed(1)}km até o destino";
    }
  }

  @override
  Widget build(BuildContext context) {
    final startPoint = LatLng(
      widget.salaInicio["lat"],
      widget.salaInicio["lng"],
    );
    final endPoint = LatLng(
      widget.salaDestino["lat"],
      widget.salaDestino["lng"],
    );
    final userPoint = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : null;

    List<Marker> markers = [
      Marker(
        point: startPoint,
        child: const Icon(Icons.my_location, color: Colors.grey, size: 25),
      ),

      Marker(
        point: endPoint,
        child: const Icon(Icons.location_pin, color: Colors.red, size: 25),
      ),
    ];

    if (userPoint != null) {
      markers.add(
        Marker(
          height: 25,
          width: 25,
          point: userPoint,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.1 * 255).round()),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ),
      );
    }

    final routePoints = (_isLiveRouteActive && userPoint != null)
        ? [userPoint, endPoint]
        : [startPoint, endPoint];

    final routePolyline = Polyline(
      points: routePoints,
      strokeWidth: 4,
      color: Colors.blue,
    );

    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.salaInicio["id"]} → ${widget.salaDestino["id"]}"),
        actions: [
          IconButton(
            icon: Icon(
              Icons.directions_walk,
              color: _isLiveRouteActive ? Colors.greenAccent : Colors.grey,
            ),
            tooltip: _isLiveRouteActive
                ? "Mostrar rota a partir da sua localização"
                : "Mostrar rota original",
            onPressed: () async {
              if (!_isLiveRouteActive) {
                bool hasPermission = await _locationService
                    .requestLocationPermission();
                if (hasPermission) {
                  setState(() {
                    _isLiveRouteActive = true;
                  });
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Para usar esta função, por favor, ative a permissão de localização.",
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              } else {
                setState(() {
                  _isLiveRouteActive = false;
                });
              }
            },
          ),

          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == "toggle_tracking") {
                if (_isTrackingLocation) {
                  _stopLocationTracking();
                } else {
                  bool hasPermission = await _locationService
                      .requestLocationPermission();
                  if (hasPermission) {
                    _startLocationTracking();
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Para usar esta função, por favor, ative a permissão de localização.",
                        ),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                }
              } else if (value == "center_user") {
                setState(() {
                  _centerOnUser = true;
                });
                _centerMapOnUser();
              } else if (value == "center_destination") {
                _centerMapOnDestination();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: "toggle_tracking",
                child: ListTile(
                  leading: Icon(
                    _isTrackingLocation
                        ? Icons.location_on
                        : Icons.location_off,
                  ),
                  title: Text(
                    _isTrackingLocation
                        ? "Parar Localização"
                        : "Iniciar Localização",
                  ),
                ),
              ),
              const PopupMenuItem<String>(
                value: "center_user",
                child: ListTile(
                  leading: Icon(Icons.my_location),
                  title: Text("Centralizar em Mim"),
                ),
              ),
              const PopupMenuItem<String>(
                value: "center_destination",
                child: ListTile(
                  leading: Icon(Icons.location_pin),
                  title: Text("Centralizar no Destino"),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: startPoint,
              initialZoom: 18,
              maxZoom: 23,
              minZoom: 17,
              onTap: (tapPosition, point) {
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
              PolylineLayer(polylines: [routePolyline]),
            ],
          ),

          Positioned(
            bottom: 16 + bottomPadding,
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
                            ? "Localização ativa"
                            : "Localização inativa",
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
        ],
      ),
    );
  }
}
