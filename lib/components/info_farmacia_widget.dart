import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'info_farmacia_model.dart';
export 'info_farmacia_model.dart';

class InfoFarmaciaWidget extends StatefulWidget {
  const InfoFarmaciaWidget({
    super.key,
    required this.sucursal,
    required this.items,

    /// Callbacks opcionales para pedir ruta
    this.onWalkPressed,
    this.onMotoPressed,
    this.onAutoPressed,
  });

  final SucursalesRecord sucursal;
  final List<ItemsRecord> items;

  /// Se ejecutan al pulsar los botones de ruta
  final Future<void> Function(SucursalesRecord sucursal)? onWalkPressed;
  final Future<void> Function(SucursalesRecord sucursal)? onMotoPressed;
  final Future<void> Function(SucursalesRecord sucursal)? onAutoPressed;

  @override
  State<InfoFarmaciaWidget> createState() => _InfoFarmaciaWidgetState();
}

class _InfoFarmaciaWidgetState extends State<InfoFarmaciaWidget> {
  late InfoFarmaciaModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => InfoFarmaciaModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  /// Horario fijo: 07:00 - 22:30
  bool _isOpenNow() {
    final now = TimeOfDay.fromDateTime(DateTime.now());
    final minutesNow = now.hour * 60 + now.minute;

    const openMinutes = 7 * 60; // 07:00
    const closeMinutes = 22 * 60 + 30; // 22:30

    return minutesNow >= openMinutes && minutesNow <= closeMinutes;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    final suc = widget.sucursal;
    final items = widget.items;
    final nombreSucursal =
        suc.nombre.isNotEmpty ? suc.nombre : 'Sucursal sin nombre';

    final isOpen = _isOpenNow();
    final statusText = isOpen ? 'Abierto' : 'Cerrado';
    final statusColor =
        isOpen ? const Color(0xFF49CA77) : const Color(0xFFFF5B5B);

    return Container(
      width: 393.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(32.0, 16.0, 16.0, 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ===== TÍTULO + CERRAR =====
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Align(
                    alignment: const AlignmentDirectional(-1.0, 0.0),
                    child: Text(
                      nombreSucursal,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                            color: Colors.black,
                            fontSize: 20.0,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.close,
                    color: Color(0xFF222222),
                    size: 31.0,
                  ),
                ),
              ],
            ),

            // ===== ESTADO + HORARIO =====
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  FFButtonWidget(
                    onPressed: () {},
                    text: statusText,
                    options: FFButtonOptions(
                      height: 40.0,
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          16.0, 0.0, 16.0, 0.0),
                      color: statusColor,
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .fontStyle,
                                ),
                                color: Colors.white,
                                fontSize: 18.0,
                                letterSpacing: 0.0,
                              ),
                      elevation: 0.0,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        8.0, 0.0, 0.0, 0.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: const AlignmentDirectional(-1.0, 1.0),
                          child: Text(
                            'Horario de atención:',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: const Color(0xFF3F3E3E),
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                        Text(
                          'Viernes - Jueves   07:00 - 22:30',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: const Color(0xFF3F3E3E),
                                    letterSpacing: 0.0,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ===== IMAGEN =====
            Align(
              alignment: const AlignmentDirectional(-1.0, 0.0),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                    0.0, 8.0, 0.0, 0.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(0.0),
                  child: Image.asset(
                    'assets/images/logoubi.png',
                    width: 328.0,
                    height: 89.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // ===== BOTONES A PIE / MOTO / AUTO =====
            Align(
              alignment: const AlignmentDirectional(0.0, 0.0),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                    0.0, 10.0, 16.0, 12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // A PIE
                    Expanded(
                      child: FFButtonWidget(
                        onPressed: () async {
                          if (widget.onWalkPressed != null) {
                            await widget.onWalkPressed!(suc);
                          }
                        },
                        text: 'A pie',
                        icon: const Icon(
                          Icons.directions_walk,
                          size: 20,
                        ),
                        options: FFButtonOptions(
                          height: 32.0,
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              4.0, 0.0, 4.0, 0.0),
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          iconColor: Colors.white,
                          color: const Color(0xFF49CA77),
                          textStyle:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                    color: Colors.white,
                                    fontSize: 13.0,
                                    letterSpacing: 0.0,
                                  ),
                          elevation: 0.0,
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8.0),

                    // MOTO
                    Expanded(
                      child: FFButtonWidget(
                        onPressed: () async {
                          if (widget.onMotoPressed != null) {
                            await widget.onMotoPressed!(suc);
                          }
                        },
                        text: 'Moto',
                        icon: const Icon(
                          Icons.motorcycle,
                          size: 18,
                        ),
                        options: FFButtonOptions(
                          height: 32.0,
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              4.0, 0.0, 4.0, 0.0),
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          color: const Color(0xFF009FE3),
                          textStyle:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                    color: Colors.white,
                                    fontSize: 13.0,
                                    letterSpacing: 0.0,
                                  ),
                          elevation: 0.0,
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8.0),

                    // AUTO
                    Expanded(
                      child: FFButtonWidget(
                        onPressed: () async {
                          if (widget.onAutoPressed != null) {
                            await widget.onAutoPressed!(suc);
                          }
                        },
                        text: 'Auto',
                        icon: const Icon(
                          Icons.directions_car,
                          size: 18,
                        ),
                        options: FFButtonOptions(
                          height: 32.0,
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              4.0, 0.0, 4.0, 0.0),
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          iconColor: Colors.white,
                          color: const Color(0xFF333333),
                          textStyle:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                    color: Colors.white,
                                    fontSize: 13.0,
                                    letterSpacing: 0.0,
                                  ),
                          elevation: 0.0,
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ===== RESUMEN DE PRODUCTOS =====
            Align(
              alignment: const AlignmentDirectional(-1.0, 0.0),
              child: Text(
                'Productos en esta sucursal: ${items.length}',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        fontStyle: FlutterFlowTheme.of(context)
                            .bodyMedium
                            .fontStyle,
                      ),
                      letterSpacing: 0.0,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
