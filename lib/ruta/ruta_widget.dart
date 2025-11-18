import '/auth/firebase_auth/auth_util.dart'; // <-- para currentUserUid
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
import 'ruta_model.dart';
export 'ruta_model.dart';
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

  // Sucursal seleccionada para trazar la ruta
  SucursalesRecord? _selectedSucursal;
  // Modo de viaje actual (para RouteViewStatic)
  String _travelMode = 'driving'; // 'walking' | 'driving'

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
                    if (s.ubicacion == null) return const SizedBox.shrink();
                    final dist = _distanceInKm(origin, s.ubicacion!);
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
                                    onPressed: () {
                                      onModeSelected(s, 'walking');
                                      Navigator.of(context).pop();
                                    },
                                    text: 'A pie',
                                    options: FFButtonOptions(
                                      height: 36,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
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
                                    onPressed: () {
                                      onModeSelected(s, 'driving'); // moto
                                      Navigator.of(context).pop();
                                    },
                                    text: 'Moto',
                                    options: FFButtonOptions(
                                      height: 36,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
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
                                    onPressed: () {
                                      onModeSelected(s, 'driving'); // auto
                                      Navigator.of(context).pop();
                                    },
                                    text: 'Auto',
                                    options: FFButtonOptions(
                                      height: 36,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      color:
                                          FlutterFlowTheme.of(context).primaryText,
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
        // final cartPharmacyIds = FFAppState().cartPharmacyIds;
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
                          'TU_API_KEY_IOS', // <--- pon aquí tus keys
                      androidGoogleMapsApiKey:
                          'TU_API_KEY_ANDROID', // <---
                      webGoogleMapsApiKey:
                          'TU_API_KEY_WEB', // <---
                      startCoordinate: currentLoc,
                      endCoordinate: rutaSucursalesRecord.ubicacion!,
                      travelMode: _travelMode, // NUEVO
                      onDestinationTap: () async {
                        // Sacar productos de esa sucursal desde el carrito
                        final items = await queryItemsRecordOnce(
                          parent: FirebaseFirestore.instance
                              .collection('carts')
                              .doc(currentUserUid),
                          queryBuilder: (q) => q.where(
                            'sucursalRef',
                            isEqualTo: rutaSucursalesRecord.reference,
                          ),
                        );

                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => InfoFarmaciaWidget(
                            sucursal: rutaSucursalesRecord,
                            items: items,
                          ),
                        );
                      },
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
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16.0),
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

                  // Barra inferior con texto y duración
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
