// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:math' show cos, sqrt, asin;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' hide LatLng;
import 'package:google_maps_flutter/google_maps_flutter.dart' as latlng;

class RouteViewStatic extends StatefulWidget {
  const RouteViewStatic({
    Key? key,
    this.width,
    this.height,
    required this.startCoordinate,
    required this.endCoordinate,
    this.lineColor = Colors.black,
    required this.iOSGoogleMapsApiKey,
    required this.androidGoogleMapsApiKey,
    required this.webGoogleMapsApiKey,
    this.startAddress,
    this.destinationAddress,
    this.travelMode = 'driving', // 'walking' | 'driving' | ...
    this.onDestinationTap,
  }) : super(key: key);

  final double? height;
  final double? width;

  /// Coordenadas de FlutterFlow (LatLng de FF, NO de google_maps_flutter)
  final LatLng startCoordinate;
  final LatLng endCoordinate;

  final Color lineColor;
  final String iOSGoogleMapsApiKey;
  final String androidGoogleMapsApiKey;
  final String webGoogleMapsApiKey;
  final String? startAddress;
  final String? destinationAddress;

  /// Modo de viaje para Directions/DistanceMatrix
  /// valores válidos: 'driving', 'walking', 'bicycling', 'transit'
  final String travelMode;

  /// Se ejecuta cuando el usuario toca el marcador de destino
  final VoidCallback? onDestinationTap;

  @override
  _RouteViewStaticState createState() => _RouteViewStaticState();
}

class _RouteViewStaticState extends State<RouteViewStatic> {
  late final CameraPosition _initialLocation;
  GoogleMapController? mapController;

  String? _placeDistance;
  final Set<Marker> _markers = {};
  final Map<PolylineId, Polyline> _polylines = {};
  final List<latlng.LatLng> _polylineCoordinates = [];

  /// IMPORTANTE:
  /// Para las llamadas HTTP (Directions / Distance Matrix) usaremos SIEMPRE
  /// la API key "web", independientemente de la plataforma.
  /// El SDK de mapas usa la key que está en el AndroidManifest/iOS plist.
  String get _directionsApiKey => widget.webGoogleMapsApiKey;

  @override
  void initState() {
    super.initState();
    final startCoordinate = latlng.LatLng(
      widget.startCoordinate.latitude,
      widget.startCoordinate.longitude,
    );
    _initialLocation = CameraPosition(target: startCoordinate, zoom: 14);
  }

  @override
  void didUpdateWidget(covariant RouteViewStatic oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si cambia el origen, destino o modo de viaje, recalculamos la ruta
    if (oldWidget.startCoordinate != widget.startCoordinate ||
        oldWidget.endCoordinate != widget.endCoordinate ||
        oldWidget.travelMode != widget.travelMode) {
      if (mapController != null) {
        _calculateAndDrawRoute();
      }
    }
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  // ====== ROUTE CALC ======

  Future<void> _calculateAndDrawRoute() async {
    // Limpia estado previo
    setState(() {
      _markers.clear();
      _polylines.clear();
      _polylineCoordinates.clear();
      _placeDistance = null;
    });

    // Coordenadas
    final double startLat = widget.startCoordinate.latitude;
    final double startLng = widget.startCoordinate.longitude;
    final double destLat = widget.endCoordinate.latitude;
    final double destLng = widget.endCoordinate.longitude;

    // Logs para debug
    debugPrint('MAP::Route ORIGEN = $startLat,$startLng');
    debugPrint('MAP::Route DESTINO = $destLat,$destLng');
    debugPrint('MAP::Route travelMode (raw) = ${widget.travelMode}');

    if (_directionsApiKey.isEmpty) {
      debugPrint('MAP::ERROR -> Directions API KEY vacía');
      return;
    } else {
      final keyPrefix = _directionsApiKey.length > 6
          ? '${_directionsApiKey.substring(0, 6)}...'
          : _directionsApiKey;
      debugPrint('MAP::Usando Directions KEY (prefijo) = $keyPrefix');
    }

    // ---- SOLO MARCADOR DE DESTINO (el origen NO se dibuja) ----
    final destId = '($destLat, $destLng)';

    _markers.add(
      Marker(
        markerId: MarkerId(destId),
        position: latlng.LatLng(destLat, destLng),
        infoWindow: InfoWindow(
          title: 'Destino',
          snippet: widget.destinationAddress ?? '',
        ),
        onTap: () {
          if (widget.onDestinationTap != null) {
            widget.onDestinationTap!();
          }
        },
      ),
    );

    // Ajustar cámara para ver ambos puntos (origen + destino)
    final southWest = latlng.LatLng(
      (startLat <= destLat) ? startLat : destLat,
      (startLng <= destLng) ? startLng : destLng,
    );
    final northEast = latlng.LatLng(
      (startLat <= destLat) ? destLat : startLat,
      (startLng <= destLng) ? destLng : startLng,
    );
    await mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: southWest, northeast: northEast),
        60.0,
      ),
    );

    // 1) Directions API para polyline (usando el travelMode recibido)
    final routeOk = await _fetchDirectionsAndBuildPolyline(
      startLat,
      startLng,
      destLat,
      destLng,
      widget.travelMode,
    );

    // 2) Distancia total en km + Distance Matrix para duración
    if (routeOk && _polylineCoordinates.length >= 2) {
      double totalKm = 0.0;
      for (int i = 0; i < _polylineCoordinates.length - 1; i++) {
        totalKm += _coordinateDistance(
          _polylineCoordinates[i].latitude,
          _polylineCoordinates[i].longitude,
          _polylineCoordinates[i + 1].latitude,
          _polylineCoordinates[i + 1].longitude,
        );
      }
      _placeDistance = totalKm.toStringAsFixed(2);
      FFAppState().routeDistance = '$_placeDistance km';

      // Distance Matrix para estimar la duración
      await _updateDurationWithDistanceMatrix(
        startLat,
        startLng,
        destLat,
        destLng,
        widget.travelMode,
      );
    }

    setState(() {});
  }

  // Normaliza el modo de viaje y asegura valores válidos
  String _normalizeMode(String mode) {
    var m = (mode.isEmpty ? 'driving' : mode.toLowerCase());
    const allowed = ['driving', 'walking', 'bicycling', 'transit'];
    if (!allowed.contains(m)) {
      debugPrint('MAP::Modo de viaje "$mode" no válido, usando "driving"');
      m = 'driving';
    }
    return m;
  }

  // Pide Directions API y decodifica overview_polyline
  Future<bool> _fetchDirectionsAndBuildPolyline(
    double startLat,
    double startLng,
    double destLat,
    double destLng,
    String mode,
  ) async {
    final safeMode = _normalizeMode(mode);

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=$startLat,$startLng'
      '&destination=$destLat,$destLng'
      '&mode=$safeMode'
      '&key=$_directionsApiKey',
    );

    debugPrint('MAP::Directions URL = $url');

    final resp = await http.get(url);
    if (resp.statusCode != 200) {
      debugPrint('MAP::Directions error HTTP ${resp.statusCode}');
      debugPrint('MAP::Directions body = ${resp.body}');
      return false;
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final status = data['status'] as String? ?? 'NO_STATUS';
    final errorMessage = data['error_message'] as String? ?? 'sin mensaje';

    debugPrint('MAP::Directions status = $status');
    if (status != 'OK') {
      debugPrint('MAP::Directions ERROR -> $errorMessage');
      return false;
    }

    final routes = (data['routes'] as List?) ?? [];
    if (routes.isEmpty) {
      debugPrint('MAP::Directions sin rutas (routes vacío)');
      return false;
    }

    final polyStr =
        (routes.first['overview_polyline']?['points'] as String?) ?? '';
    if (polyStr.isEmpty) {
      debugPrint('MAP::Directions sin overview_polyline');
      return false;
    }

    final decoded = _decodePolyline(polyStr);
    if (decoded.isEmpty) {
      debugPrint('MAP::Polyline decodificado vacío');
      return false;
    }

    _polylineCoordinates.addAll(decoded);

    final polyId = const PolylineId('route_poly');
    final poly = Polyline(
      polylineId: polyId,
      color: widget.lineColor,
      width: 4,
      points: _polylineCoordinates,
    );
    _polylines[polyId] = poly;

    return true;
  }

  // Distance Matrix para estimación de duración
  Future<void> _updateDurationWithDistanceMatrix(
    double startLat,
    double startLng,
    double destLat,
    double destLng,
    String mode,
  ) async {
    final safeMode = _normalizeMode(mode);

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/distancematrix/json'
      '?origins=$startLat,$startLng'
      '&destinations=$destLat,$destLng'
      '&mode=$safeMode'
      '&key=$_directionsApiKey',
    );

    debugPrint('MAP::DistanceMatrix URL = $url');

    final resp = await http.get(url);
    if (resp.statusCode != 200) {
      debugPrint('MAP::DistanceMatrix error HTTP ${resp.statusCode}');
      debugPrint('MAP::DistanceMatrix body = ${resp.body}');
      return;
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final status = data['status'] as String? ?? 'NO_STATUS';
    final errorMessage = data['error_message'] as String? ?? 'sin mensaje';
    debugPrint('MAP::DistanceMatrix status = $status');
    if (status != 'OK') {
      debugPrint('MAP::DistanceMatrix ERROR -> $errorMessage');
      return;
    }

    try {
      final rows = (data['rows'] as List?) ?? [];
      final elements = (rows.first['elements'] as List?) ?? [];
      final elem = elements.first as Map<String, dynamic>;
      final elemStatus = elem['status'] as String? ?? 'NO_STATUS';
      debugPrint('MAP::DistanceMatrix element status = $elemStatus');

      if (elemStatus != 'OK') {
        return;
      }

      final durationText =
          (elem['duration']?['text'] as String?) ?? '';
      if (durationText.isNotEmpty) {
        // Ej: "12 min"
        FFAppState().routeDuration = durationText;
        debugPrint('MAP::Duration = $durationText');
      }
    } catch (e) {
      debugPrint('MAP::DistanceMatrix parse error: $e');
    }
  }

  // Haversine entre 2 coordenadas (km)
  double _coordinateDistance(double lat1, double lon1, double lat2, double lon2) {
    final p = 0.017453292519943295; // pi/180
    final c = cos;
    final a = 0.5 - c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  /// Decodifica una polyline encoded de Google (retorna puntos lat/lng)
  List<latlng.LatLng> _decodePolyline(String encoded) {
    final List<latlng.LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(latlng.LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: GoogleMap(
        markers: _markers,
        polylines: Set<Polyline>.of(_polylines.values),
        initialCameraPosition: _initialLocation,
        myLocationEnabled: true, // puntito azul
        myLocationButtonEnabled: false,
        mapType: MapType.normal,
        zoomGesturesEnabled: true,
        zoomControlsEnabled: false,
        onMapCreated: (GoogleMapController controller) async {
          mapController = controller;
          await _calculateAndDrawRoute();
        },
      ),
    );
  }
}
