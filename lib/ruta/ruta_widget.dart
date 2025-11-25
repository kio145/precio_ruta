import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'dart:math' as math;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'ruta_model.dart';
export 'ruta_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import '/components/info_farmacia_widget.dart';

class RutaWidget extends StatefulWidget {
  const RutaWidget({super.key});

  static String routeName = 'ruta';
  static String routePath = '/ruta';

  @override
  State<RutaWidget> createState() => _RutaWidgetState();
}

class _RutaWidgetState extends State<RutaWidget> {
  late RutaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  LatLng? currentUserLocationValue;

  // Dirección legible de la ubicación actual
  String? _currentAddress;

  // Sucursal seleccionada para trazar la ruta
  SucursalesRecord? _selectedSucursal;

  // Modo de viaje actual (para RouteViewStatic)
  String _travelMode = 'driving'; // 'walking' | 'driving'

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RutaModel());

    _initLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  Future<void> _initLocation() async {
    final loc = await getCurrentUserLocation(
      defaultLocation: LatLng(0.0, 0.0),
      cached: true,
    );

    String? address;
    try {
      final placemarks = await geocoding.placemarkFromCoordinates(
        loc.latitude,
        loc.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        // Ejemplo: "Calle Sucre, Cercado, Cochabamba"
        final parts = <String>[
          if ((p.street ?? '').isNotEmpty) p.street!,
          if ((p.subLocality ?? '').isNotEmpty) p.subLocality!,
          if ((p.locality ?? '').isNotEmpty) p.locality!,
        ];
        address = parts.join(', ');
      }
    } catch (e) {
      debugPrint('Error obteniendo dirección: $e');
    }

    safeSetState(() {
      currentUserLocationValue = loc;
      _currentAddress = address;
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // Distancia en km (Haversine)
  double _distanceInKm(LatLng a, LatLng b) {
    const earthRadius = 6371.0; // km
    final dLat = (b.latitude - a.latitude) * math.pi / 180.0;
    final dLng = (b.longitude - a.longitude) * math.pi / 180.0;
    final la1 = a.latitude * math.pi / 180.0;
    final la2 = b.latitude * math.pi / 180.0;

    final sinDLat = math.sin(dLat / 2);
    final sinDLng = math.sin(dLng / 2);

    final aa = sinDLat * sinDLat +
        math.cos(la1) * math.cos(la2) * sinDLng * sinDLng;
    final c = 2 * math.asin(math.sqrt(aa));

    return earthRadius * c;
  }

  // Modal con la lista de sucursales cercanas
  Widget _buildSucursalesSheet(
    List<SucursalesRecord> sucursales,
    LatLng origin,
    void Function(SucursalesRecord suc, String mode) onModeSelected,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFCCCCCC),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Sucursales asociadas a tu carrito',
              style: FlutterFlowTheme.of(context).titleMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontStyle:
                          FlutterFlowTheme.of(context).titleMedium.fontStyle,
                    ),
                    letterSpacing: 0,
                  ),
            ),
            const SizedBox(height: 8),
            if (sucursales.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No hay sucursales asociadas a tu carrito dentro del radio configurado.',
                  textAlign: TextAlign.center,
                ),
              )
            else
              SizedBox(
                height: 320,
                child: ListView.builder(
                  itemCount: sucursales.length,
                  itemBuilder: (context, index) {
                    final s = sucursales[index];
                    if (s.ubicacion == null) return const SizedBox.shrink();
                    final dist = _distanceInKm(origin, s.ubicacion!);
                    final nombre = s.nombre.isNotEmpty ? s.nombre : 'Sucursal';

                    return Card(
                      color: const Color(0xFFF5F5F5), // fondo claro
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nombre,
                              style: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Distancia: ${dist.toStringAsFixed(2)} km',
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .fontStyle,
                                    ),
                                    color: const Color(0xFF555555),
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                // A pie
                                Expanded(
                                  child: FFButtonWidget(
                                    onPressed: () {
                                      onModeSelected(s, 'walking');
                                      Navigator.of(context).pop();
                                    },
                                    text: 'A pie',
                                    icon: const Icon(
                                      Icons.directions_walk,
                                      size: 18,
                                    ),
                                    options: FFButtonOptions(
                                      height: 36,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      iconPadding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0, 0, 0, 0),
                                      iconColor: Colors.white,
                                      color: const Color(0xFF4CAF50),
                                      textStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontStyle,
                                            ),
                                            color: Colors.white,
                                          ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                // Moto
                                Expanded(
                                  child: FFButtonWidget(
                                    onPressed: () {
                                      onModeSelected(s, 'driving'); // moto
                                      Navigator.of(context).pop();
                                    },
                                    text: 'Moto',
                                    icon: const Icon(
                                      Icons.motorcycle,
                                      size: 18,
                                    ),
                                    options: FFButtonOptions(
                                      height: 36,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      iconPadding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0, 0, 0, 0),
                                      iconColor: Colors.white,
                                      color: const Color(0xFF009FE3),
                                      textStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontStyle,
                                            ),
                                            color: Colors.white,
                                          ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                // Auto
                                Expanded(
                                  child: FFButtonWidget(
                                    onPressed: () {
                                      onModeSelected(s, 'driving'); // auto
                                      Navigator.of(context).pop();
                                    },
                                    text: 'Auto',
                                    icon: const Icon(
                                      Icons.directions_car,
                                      size: 18,
                                    ),
                                    options: FFButtonOptions(
                                      height: 36,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      iconPadding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0, 0, 0, 0),
                                      iconColor: Colors.white,
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      textStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontStyle,
                                            ),
                                            color: Colors.white,
                                          ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    if (currentUserLocationValue == null) {
      return Container(
        color: FlutterFlowTheme.of(context).primaryBackground,
        child: Center(
          child: SizedBox(
            width: 50.0,
            height: 50.0,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                FlutterFlowTheme.of(context).primary,
              ),
            ),
          ),
        ),
      );
    }

    final currentLoc = currentUserLocationValue!;

    return StreamBuilder<List<SucursalesRecord>>(
      stream: querySucursalesRecord(),
      builder: (context, sucSnap) {
        if (!sucSnap.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            ),
          );
        }

        final allSucursales = sucSnap.data!;

        // Solo sucursales que aparezcan en el carrito (por sucursalRef)
        return FutureBuilder<List<ItemsRecord>>(
          future: queryItemsRecordOnce(
            parent: FirebaseFirestore.instance
                .collection('carts')
                .doc(currentUserUid),
          ),
          builder: (context, cartSnap) {
            if (!cartSnap.hasData) {
              return Scaffold(
                backgroundColor:
                    FlutterFlowTheme.of(context).primaryBackground,
                body: Center(
                  child: SizedBox(
                    width: 50.0,
                    height: 50.0,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                  ),
                ),
              );
            }

            final cartItems = cartSnap.data!;

            final cartSucursalPaths = cartItems
                .map((i) => i.sucursalRef?.path)
                .whereType<String>()
                .toSet();

            final sucursalesDeCarrito = allSucursales.where((s) {
              return cartSucursalPaths.contains(s.reference.path);
            }).toList();

            if (sucursalesDeCarrito.isEmpty) {
              return Scaffold(
                backgroundColor:
                    FlutterFlowTheme.of(context).primaryBackground,
                body: SafeArea(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'No hay sucursales asociadas a los productos de tu carrito.\n\nVerifica que los ítems tengan el campo "sucursalRef" guardado.',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              fontSize: 16,
                            ),
                      ),
                    ),
                  ),
                ),
              );
            }

            // Radio de búsqueda (5 km)
            const maxRadioKm = 5.0;
            final sucursalesCercanas = sucursalesDeCarrito.where((s) {
              final loc = s.ubicacion;
              if (loc == null) return false;
              final d = _distanceInKm(currentLoc, loc);
              return d <= maxRadioKm;
            }).toList()
              ..sort((a, b) {
                final da = _distanceInKm(currentLoc, a.ubicacion!);
                final db = _distanceInKm(currentLoc, b.ubicacion!);
                return da.compareTo(db);
              });

            final hasDestination = _selectedSucursal != null;
            final LatLng endCoord =
                hasDestination ? _selectedSucursal!.ubicacion! : currentLoc;

            return GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: Scaffold(
                key: scaffoldKey,
                backgroundColor:
                    FlutterFlowTheme.of(context).primaryBackground,
                body: SafeArea(
                  top: true,
                  child: Stack(
                    children: [
                      // Fondo con la ruta dibujada
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width,
                        height: MediaQuery.sizeOf(context).height,
                        child: custom_widgets.RouteViewStatic(
                          width: double.infinity,
                          height: double.infinity,
                          lineColor: FlutterFlowTheme.of(context).primary,
                          startAddress: '',
                          destinationAddress: '',
                          iOSGoogleMapsApiKey:
                              'AIzaSyCshROPEm_7o7-Vob-rGwrChIJbl0PvX9M',
                          androidGoogleMapsApiKey:
                              'AIzaSyCshROPEm_7o7-Vob-rGwrChIJbl0PvX9M',
                          webGoogleMapsApiKey:
                              'AIzaSyCshROPEm_7o7-Vob-rGwrChIJbl0PvX9M',
                          startCoordinate: currentLoc,
                          endCoordinate: endCoord,
                          travelMode: _travelMode,
                          onDestinationTap: hasDestination
                              ? () async {
                                  final items = await queryItemsRecordOnce(
                                    parent: FirebaseFirestore.instance
                                        .collection('carts')
                                        .doc(currentUserUid),
                                    queryBuilder: (q) => q.where(
                                      'sucursalRef',
                                      isEqualTo:
                                          _selectedSucursal!.reference,
                                    ),
                                  );

                                  await showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    barrierColor: Colors.black
                                        .withOpacity(0.15),
                                    builder: (_) => InfoFarmaciaWidget(
                                      sucursal: _selectedSucursal!,
                                      items: items,
                                    ),
                                  );
                                }
                              : null,
                        ),
                      ),

                      // Botón "Sucursales"
                      Align(
                        alignment: const AlignmentDirectional(0.85, -0.99),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 20.0, 12.0, 0.0),
                          child: FFButtonWidget(
                            onPressed: () async {
                              await showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                barrierColor:
                                    Colors.black.withOpacity(0.15),
                                builder: (context) {
                                  return _buildSucursalesSheet(
                                    sucursalesCercanas,
                                    currentLoc,
                                    (sucursal, mode) {
                                      setState(() {
                                        _selectedSucursal = sucursal;
                                        _travelMode = mode;
                                      });
                                    },
                                  );
                                },
                              );
                            },
                            text: 'Sucursales',
                            options: FFButtonOptions(
                              height: 40.0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0),
                              color: const Color(0xFF1DB954),
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontStyle:
                                          FlutterFlowTheme.of(context)
                                              .titleSmall
                                              .fontStyle,
                                    ),
                                    color: Colors.white,
                                  ),
                              elevation: 2.0,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                        ),
                      ),

                      // Barra inferior con ubicación y duración
                      Align(
                        alignment: const AlignmentDirectional(0.0, 1.0),
                        child: Container(
                          width: MediaQuery.sizeOf(context).width,
                          height: 70.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primaryText,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12.0),
                              topRight: Radius.circular(12.0),
                            ),
                            border: Border.all(
                              color: const Color(0xFF969696),
                            ),
                          ),
                          alignment: const AlignmentDirectional(0.0, 1.0),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                8.0, 0.0, 8.0, 0.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Te encuentras en: ${_currentAddress ?? 'Ubicación actual'}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          color:
                                              FlutterFlowTheme.of(context)
                                                  .primaryBackground,
                                          fontSize: 16.0,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                if (FFAppState().routeDuration.isNotEmpty)
                                  Text(
                                    '${FFAppState().routeDuration} min',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          color:
                                              FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
