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

    /// Mostrar o no el marcador azul del origen
    this.showStartMarker = true,

    /// Sucursales a marcar con pines rojos
    this.branchMarkers,

    /// Misma lista de sucursales (para saber cuál se tocó)
    this.branchSucursales,

    /// Callback al tocar un pin rojo
    this.onBranchTap,
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

  /// Si true, se pone un marcador en el origen
  final bool showStartMarker;

  /// Coordenadas de sucursales (LatLng de FlutterFlow)
  final List<LatLng>? branchMarkers;

  /// Registros de sucursales en el mismo orden que branchMarkers
  final List<SucursalesRecord>? branchSucursales;

  /// Callback al tocar un pin de sucursal
  final Future<void> Function(SucursalesRecord sucursal)? onBranchTap;

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

  String get _googleMapsApiKey {
    if (kIsWeb) return widget.webGoogleMapsApiKey;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return widget.iOSGoogleMapsApiKey;
      case TargetPlatform.android:
        return widget.androidGoogleMapsApiKey;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return widget.webGoogleMapsApiKey;
      default:
        return widget.webGoogleMapsApiKey;
    }
  }

  @override
  void initState() {
    super.initState();
    final startCoordinate = latlng.LatLng(
      widget.startCoordinate.latitude,
      widget.startCoordinate.longitude,
    );
    _initialLocation = CameraPosition(target: startCoordinate, zoom: 14);
  }

  bool _sameBranchMarkers(List<LatLng>? a, List<LatLng>? b) {
    if (identical(a, b)) return true;
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].latitude != b[i].latitude ||
          a[i].longitude != b[i].longitude) {
        return false;
      }
    }
    return true;
  }

  @override
  void didUpdateWidget(covariant RouteViewStatic oldWidget) {
    super.didUpdateWidget(oldWidget);
    final coordsChanged =
        oldWidget.startCoordinate != widget.startCoordinate ||
        oldWidget.endCoordinate != widget.endCoordinate;
    final modeChanged = oldWidget.travelMode != widget.travelMode;
    final markersChanged =
        !_sameBranchMarkers(oldWidget.branchMarkers, widget.branchMarkers);

    if ((coordsChanged || modeChanged || markersChanged) &&
        mapController != null) {
      _calculateAndDrawRoute();
    }
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  // ====== ROUTE CALC ======

  Future<void> _calculateAndDrawRoute() async {
    setState(() {
      _markers.clear();
      _polylines.clear();
      _polylineCoordinates.clear();
      _placeDistance = null;
    });

    final double startLat = widget.startCoordinate.latitude;
    final double startLng = widget.startCoordinate.longitude;
    final double destLat = widget.endCoordinate.latitude;
    final double destLng = widget.endCoordinate.longitude;

    debugPrint('MAP::Route ORIGEN = $startLat,$startLng');
    debugPrint('MAP::Route DESTINO = $destLat,$destLng');
    debugPrint('MAP::Route travelMode (raw) = ${widget.travelMode}');

    if (_googleMapsApiKey.isEmpty) {
      debugPrint('MAP::ERROR -> Google Maps API KEY vacía');
      return;
    } else {
      final keyPrefix = _googleMapsApiKey.length > 6
          ? '${_googleMapsApiKey.substring(0, 6)}...'
          : _googleMapsApiKey;
      debugPrint('MAP::Usando API KEY (prefijo) = $keyPrefix');
    }

    // === MARCADORES ===

    // Origen (azul)
    if (widget.showStartMarker) {
      _markers.add(
        Marker(
          markerId: const MarkerId('start'),
          position: latlng.LatLng(startLat, startLng),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );
    }

    // Sucursales (rojo, cada una con su SucursalesRecord)
    if (widget.branchMarkers != null) {
      for (int i = 0; i < widget.branchMarkers!.length; i++) {
        final b = widget.branchMarkers![i];
        final suc = (widget.branchSucursales != null &&
                i < widget.branchSucursales!.length)
            ? widget.branchSucursales![i]
            : null;

        _markers.add(
          Marker(
            markerId: MarkerId('branch_$i'),
            position: latlng.LatLng(b.latitude, b.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
            onTap: (suc != null && widget.onBranchTap != null)
                ? () async {
                    await widget.onBranchTap!(suc);
                  }
                : null,
          ),
        );
      }
    }

    // Destino (marcador normal, lo dejamos también en rojo por compatibilidad)
    final destId = 'dest_marker';
    _markers.add(
      Marker(
        markerId: MarkerId(destId),
        position: latlng.LatLng(destLat, destLng),
        onTap: () {
          if (widget.onDestinationTap != null) {
            widget.onDestinationTap!();
          }
        },
      ),
    );

    // === BOUNDS PARA VER TODO ===
    final List<latlng.LatLng> boundsPoints = [];
    boundsPoints.add(latlng.LatLng(startLat, startLng));
    boundsPoints.add(latlng.LatLng(destLat, destLng));

    if (widget.branchMarkers != null) {
      for (final b in widget.branchMarkers!) {
        boundsPoints.add(latlng.LatLng(b.latitude, b.longitude));
      }
    }

    if (boundsPoints.isNotEmpty) {
      double minLat = boundsPoints.first.latitude;
      double maxLat = boundsPoints.first.latitude;
      double minLng = boundsPoints.first.longitude;
      double maxLng = boundsPoints.first.longitude;

      for (final p in boundsPoints) {
        if (p.latitude < minLat) minLat = p.latitude;
        if (p.latitude > maxLat) maxLat = p.latitude;
        if (p.longitude < minLng) minLng = p.longitude;
        if (p.longitude > maxLng) maxLng = p.longitude;
      }

      final southWest = latlng.LatLng(minLat, minLng);
      final northEast = latlng.LatLng(maxLat, maxLng);

      await mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(southwest: southWest, northeast: northEast),
          60.0,
        ),
      );
    }

    // 1) Directions API
    final routeOk = await _fetchDirectionsAndBuildPolyline(
      startLat,
      startLng,
      destLat,
      destLng,
      widget.travelMode,
    );

    // 2) Distancia + duración
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

  String _normalizeMode(String mode) {
    var m = (mode.isEmpty ? 'driving' : mode.toLowerCase());
    const allowed = ['driving', 'walking', 'bicycling', 'transit'];
    if (!allowed.contains(m)) {
      debugPrint('MAP::Modo de viaje "$mode" no válido, usando "driving"');
      m = 'driving';
    }
    return m;
  }

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
      '&key=$_googleMapsApiKey',
    );

    debugPrint('MAP::Directions URL = $url');

    final resp = await http.get(url);
    if (resp.statusCode != 200) {
      debugPrint('MAP::Directions error HTTP ${resp.statusCode}');
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
      '&key=$_googleMapsApiKey',
    );

    debugPrint('MAP::DistanceMatrix URL = $url');

    final resp = await http.get(url);
    if (resp.statusCode != 200) {
      debugPrint('MAP::DistanceMatrix error HTTP ${resp.statusCode}');
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
        FFAppState().routeDuration = durationText;
        debugPrint('MAP::Duration = $durationText');
      }
    } catch (e) {
      debugPrint('MAP::DistanceMatrix parse error: $e');
    }
  }

  double _coordinateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    final p = 0.017453292519943295; // pi/180
    final c = cos;
    final a = 0.5 - c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

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
