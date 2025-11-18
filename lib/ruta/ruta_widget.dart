import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'dart:math' as math; // Para calcular distancias
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // Para abrir Google Maps
import 'ruta_model.dart';
export 'ruta_model.dart';

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

  // Sucursal seleccionada para trazar la ruta
  SucursalesRecord? _selectedSucursal;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RutaModel());

    getCurrentUserLocation(defaultLocation: LatLng(0.0, 0.0), cached: true)
        .then((loc) => safeSetState(() => currentUserLocationValue = loc));
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // Distancia en km (fórmula de Haversine)
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

  // Abrir ruta en Google Maps con el modo indicado
  Future<void> _openGoogleMapsRoute({
    required LatLng origin,
    required LatLng destination,
    required String travelMode, // walking / driving / bicycling / transit
  }) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=${origin.latitude},${origin.longitude}'
      '&destination=${destination.latitude},${destination.longitude}'
      '&travelmode=$travelMode',
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir Google Maps.'),
          ),
        );
      }
    }
  }

  // Modal con la lista de sucursales cercanas
  Widget _buildSucursalesSheet(
    List<SucursalesRecord> sucursales,
    LatLng origin,
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
            // barrita de agarre
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
              'Sucursales cercanas',
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
                  'No hay sucursales dentro de 1.5 km de tu ubicación.',
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
                    if (s.ubicacion == null) {
                      return const SizedBox.shrink();
                    }
                    final dist = _distanceInKm(origin, s.ubicacion!);

                    // TODO: ajusta estos campos según tu SucursalesRecord
                    final nombre = s.nombre.isNotEmpty ? s.nombre : 'Sucursal';

                    return Card(
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
                            // Ya no mostramos dirección porque no existe ese campo todavía
                            // Text(
                            //   direccion,
                            //   style: FlutterFlowTheme.of(context).bodySmall,
                            // ),
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
                                Expanded(
                                  child: FFButtonWidget(
                                    onPressed: () async {
                                      setState(() {
                                        _selectedSucursal = s;
                                      });
                                      Navigator.of(context).pop();
                                      await _openGoogleMapsRoute(
                                        origin: origin,
                                        destination: s.ubicacion!,
                                        travelMode: 'walking',
                                      );
                                    },
                                    text: 'A pie',
                                    options: FFButtonOptions(
                                      height: 36,
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 12),
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
                                Expanded(
                                  child: FFButtonWidget(
                                    onPressed: () async {
                                      setState(() {
                                        _selectedSucursal = s;
                                      });
                                      Navigator.of(context).pop();
                                      // Moto -> usamos driving para Google Maps
                                      await _openGoogleMapsRoute(
                                        origin: origin,
                                        destination: s.ubicacion!,
                                        travelMode: 'driving',
                                      );
                                    },
                                    text: 'Moto',
                                    options: FFButtonOptions(
                                      height: 36,
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 12),
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
                                Expanded(
                                  child: FFButtonWidget(
                                    onPressed: () async {
                                      setState(() {
                                        _selectedSucursal = s;
                                      });
                                      Navigator.of(context).pop();
                                      await _openGoogleMapsRoute(
                                        origin: origin,
                                        destination: s.ubicacion!,
                                        travelMode: 'driving',
                                      );
                                    },
                                    text: 'Auto',
                                    options: FFButtonOptions(
                                      height: 36,
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 12),
                                      color: FlutterFlowTheme.of(context).primaryText,
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

    return StreamBuilder<List<SucursalesRecord>>(
      stream: querySucursalesRecord(), // <- YA NO singleRecord
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
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

        final allSucursales = snapshot.data!;
        if (allSucursales.isEmpty) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Center(
              child: Text(
                'No hay sucursales disponibles.',
                style: FlutterFlowTheme.of(context).bodyMedium,
              ),
            ),
          );
        }

        final currentLoc = currentUserLocationValue!;
        const maxRadioKm = 1.5;

        // 🔹 (Opcional) filtrar por farmacias del carrito
        // Supongamos que tienes en FFAppState una lista de IDs de farmacia:
        // final cartPharmacyIds = FFAppState().cartPharmacyIds; // TODO: ajusta si ya lo tienes
        //
        // y en SucursalesRecord un campo farmaciaId:
        // List<SucursalesRecord> filtradasPorCarrito = allSucursales.where((s) {
        //   return cartPharmacyIds.contains(s.farmaciaId);
        // }).toList();
        //
        // Por ahora usamos todas:
        final baseList = allSucursales;

        // 🔹 Filtrar por radio (1.5 km alrededor de la ubicación actual)
        final sucursalesCercanas = baseList.where((s) {
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

        // Elegir sucursal para mostrar la ruta
        if (sucursalesCercanas.isNotEmpty) {
          _selectedSucursal ??= sucursalesCercanas.first;
        } else {
          _selectedSucursal ??= allSucursales.first;
        }

        final rutaSucursalesRecord = _selectedSucursal!;

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
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
                      startAddress: 'inicio',
                      destinationAddress: 'fin',
                      iOSGoogleMapsApiKey:
                          'AIzaSyBWlWGnu6osur9X2_ncDGe5ANsYnpUZJdA',
                      androidGoogleMapsApiKey:
                          'AIzaSyBbie_NfyxJ-nqAYA6IJI7GhdtUAPTyeyc',
                      webGoogleMapsApiKey:
                          'AIzaSyBbie_NfyxJ-nqAYA6IJI7GhdtUAPTyeyc',
                      startCoordinate: currentLoc,
                      endCoordinate: rutaSucursalesRecord.ubicacion!,
                    ),
                  ),

                  // Botón volver
                  Align(
                    alignment: const AlignmentDirectional(-0.87, -0.99),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 20.0, 0.0, 0.0),
                      child: FFButtonWidget(
                        onPressed: () async {
                          context.pushNamed(BuscarFarmaciaWidget.routeName);
                        },
                        text: 'Button',
                        icon: const Icon(
                          Icons.west,
                          size: 29.0,
                        ),
                        options: FFButtonOptions(
                          width: 49.0,
                          height: 49.0,
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              10.0, 0.0, 16.0, 0.0),
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          iconColor:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          color: FlutterFlowTheme.of(context).primaryText,
                          textStyle:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                    color: Colors.white,
                                    letterSpacing: 0.0,
                                  ),
                          elevation: 0.0,
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).primaryText,
                          ),
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                      ),
                    ),
                  ),

                  // Botón "Sucursales" para abrir el modal
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
                            builder: (context) {
                              return _buildSucursalesSheet(
                                sucursalesCercanas,
                                currentLoc,
                              );
                            },
                          );
                        },
                        text: 'Sucursales',
                        options: FFButtonOptions(
                          height: 40.0,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          color: const Color(0xFF1DB954),
                          textStyle: FlutterFlowTheme.of(context)
                              .titleSmall
                              .override(
                                font: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FlutterFlowTheme.of(context)
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

                  // Barra inferior con texto y duración (siempre como lo tenías)
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
                            8.0, 0.0, 0.0, 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Align(
                              alignment: const AlignmentDirectional(0.0, 0.0),
                              child: Text(
                                'Tu ubicación: Plaza Sucre',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                      fontSize: 20.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              '${FFAppState().routeDuration} min',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
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
  }
}
