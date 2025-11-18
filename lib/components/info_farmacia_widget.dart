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
  });

  final SucursalesRecord sucursal;
  final List<ItemsRecord> items;

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

  @override
  Widget build(BuildContext context) {
    // Para que escuche cambios en FFAppState (routeDuration, etc.)
    context.watch<FFAppState>();

    final suc = widget.sucursal;
    final items = widget.items;
    final nombreSucursal =
        suc.nombre.isNotEmpty ? suc.nombre : 'Sucursal sin nombre';

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
                    text: 'Cerrado',
                    options: FFButtonOptions(
                      height: 40.0,
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          16.0, 0.0, 16.0, 0.0),
                      color: const Color(0xFFFF5B5B),
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

            // ===== TIEMPOS A PIE / MOTO / AUTO =====
            Align(
              alignment: const AlignmentDirectional(0.0, 0.0),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                    0.0, 10.0, 31.0, 12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // A PIE
                    FFButtonWidget(
                      onPressed: () {},
                      text: FFAppState().routeDuration.isNotEmpty
                          ? FFAppState().routeDuration
                          : '16 min',
                      icon: const Icon(
                        Icons.directions_walk,
                        size: 22.89,
                      ),
                      options: FFButtonOptions(
                        width: 92.0,
                        height: 29.0,
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            2.0, 0.0, 4.0, 0.0),
                        iconPadding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 0.0, 0.0),
                        iconColor: const Color(0xFF49CA77),
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        textStyle:
                            FlutterFlowTheme.of(context).titleSmall.override(
                                  font: GoogleFonts.interTight(
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                                  color: const Color(0xFF49CA77),
                                  fontSize: 13.0,
                                  letterSpacing: 0.0,
                                ),
                        elevation: 0.0,
                        borderSide: const BorderSide(
                          color: Color(0xFF49CA77),
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),

                    // MOTO
                    FFButtonWidget(
                      onPressed: () {},
                      text: FFAppState().routeDuration.isNotEmpty
                          ? FFAppState().routeDuration
                          : '16 min',
                      icon: const Icon(
                        Icons.motorcycle,
                        size: 17.4,
                      ),
                      options: FFButtonOptions(
                        width: 92.0,
                        height: 29.0,
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            2.0, 0.0, 4.0, 0.0),
                        iconPadding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 0.0, 0.0),
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        textStyle:
                            FlutterFlowTheme.of(context).titleSmall.override(
                                  font: GoogleFonts.interTight(
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                                  color: const Color(0xFF49CA77),
                                  fontSize: 13.0,
                                  letterSpacing: 0.0,
                                ),
                        elevation: 0.0,
                        borderSide: const BorderSide(
                          color: Color(0xFF49CA77),
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),

                    // AUTO
                    FFButtonWidget(
                      onPressed: () {},
                      text: FFAppState().routeDuration.isNotEmpty
                          ? FFAppState().routeDuration
                          : '16 min',
                      icon: const Icon(
                        Icons.directions_car,
                        size: 18.99,
                      ),
                      options: FFButtonOptions(
                        width: 92.0,
                        height: 29.0,
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            2.0, 0.0, 4.0, 0.0),
                        iconPadding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 0.0, 0.0),
                        iconColor: const Color(0xFF49CA77),
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        textStyle:
                            FlutterFlowTheme.of(context).titleSmall.override(
                                  font: GoogleFonts.interTight(
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                                  color: const Color(0xFF49CA77),
                                  fontSize: 13.0,
                                  letterSpacing: 0.0,
                                ),
                        elevation: 0.0,
                        borderSide: const BorderSide(
                          color: Color(0xFF49CA77),
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                  ].divide(const SizedBox(width: 22.0)),
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
