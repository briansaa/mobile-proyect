import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  String _currentAddress = "Obteniendo dirección...";
  bool _isLoading = true;
  bool _isLocationEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndGetLocation();
  }

  // Verificar permisos y obtener ubicación
  Future<void> _checkPermissionsAndGetLocation() async {
    try {
      // Verificar si el servicio de ubicación está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
        });
        _showLocationServiceDialog();
        return;
      }

      // Verificar permisos de ubicación
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoading = false;
          });
          _showPermissionDeniedDialog();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
        });
        _showPermissionDeniedForeverDialog();
        return;
      }

      // Obtener ubicación actual
      await _getCurrentLocation();
    } catch (e) {
      print('Error al obtener ubicación: $e');
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error al obtener la ubicación: $e');
    }
  }

  // Obtener ubicación actual
  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLocationEnabled = true;
        _isLoading = false;
      });

      // Agregar marcador en la ubicación actual
      _addCurrentLocationMarker();
      
      // Obtener dirección
      await _getAddressFromCoordinates();
      
      // Mover cámara a la ubicación actual
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 16.0,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error al obtener posición: $e');
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('No se pudo obtener la ubicación actual');
    }
  }

  // Agregar marcador en la ubicación actual
  void _addCurrentLocationMarker() {
    if (_currentPosition != null) {
      setState(() {
        _markers.clear();
        _markers.add(
          Marker(
            markerId: MarkerId('current_location'),
            position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            infoWindow: InfoWindow(
              title: 'Mi Ubicación',
              snippet: _currentAddress,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );
      });
    }
  }

  // Obtener dirección a partir de coordenadas
  Future<void> _getAddressFromCoordinates() async {
    try {
      if (_currentPosition != null) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          setState(() {
            _currentAddress = 
              "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
          });
          
          // Actualizar marcador con nueva dirección
          _addCurrentLocationMarker();
        }
      }
    } catch (e) {
      print('Error al obtener dirección: $e');
      setState(() {
        _currentAddress = "Dirección no disponible";
      });
    }
  }

  // Actualizar ubicación
  Future<void> _updateLocation() async {
    setState(() {
      _isLoading = true;
    });
    await _getCurrentLocation();
  }

  // Mostrar diálogo de servicio de ubicación deshabilitado
  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Servicio de Ubicación'),
          content: Text('El servicio de ubicación está deshabilitado. Por favor, habilítalo en la configuración.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Geolocator.openLocationSettings();
              },
              child: Text('Configuración'),
            ),
          ],
        );
      },
    );
  }

  // Mostrar diálogo de permisos denegados
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permisos de Ubicación'),
          content: Text('Se necesitan permisos de ubicación para mostrar tu posición en el mapa.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _checkPermissionsAndGetLocation();
              },
              child: Text('Reintentar'),
            ),
          ],
        );
      },
    );
  }

  // Mostrar diálogo de permisos denegados permanentemente
  void _showPermissionDeniedForeverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permisos Requeridos'),
          content: Text('Los permisos de ubicación fueron denegados permanentemente. Por favor, habilítalos en la configuración de la aplicación.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: Text('Configuración'),
            ),
          ],
        );
      },
    );
  }

  // Mostrar diálogo de error
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Ubicación'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _isLoading ? null : _updateLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Mapa
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              if (_currentPosition != null) {
                controller.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      zoom: 16.0,
                    ),
                  ),
                );
              }
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(-12.0464, -77.0428), // Lima, Perú por defecto
              zoom: 10.0,
            ),
            markers: _markers,
            myLocationEnabled: _isLocationEnabled,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
          ),
          
          // Indicador de carga
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Obteniendo ubicación...'),
                    ],
                  ),
                ),
              ),
            ),
          
          // Panel de información
          if (!_isLoading && _currentPosition != null)
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Mi Ubicación Actual',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      _currentAddress,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.my_location, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        SizedBox(width: 16),
                        Icon(Icons.my_location, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          'Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      
      // Botón flotante para centrar en mi ubicación
      floatingActionButton: _currentPosition != null
          ? FloatingActionButton(
              onPressed: () {
                if (_mapController != null) {
                  _mapController!.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                        zoom: 16.0,
                      ),
                    ),
                  );
                }
              },
              child: Icon(Icons.my_location),
              backgroundColor: Colors.blue,
            )
          : null,
    );
  }
}