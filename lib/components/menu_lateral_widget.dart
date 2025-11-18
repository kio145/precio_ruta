import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'menu_lateral_model.dart';
export 'menu_lateral_model.dart';

class MenuLateralWidget extends StatefulWidget {
  const MenuLateralWidget({super.key});

  @override
  State<MenuLateralWidget> createState() => _MenuLateralWidgetState();
}

class _MenuLateralWidgetState extends State<MenuLateralWidget> {
  late MenuLateralModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MenuLateralModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Correo del usuario autenticado
    final String emailToShow = currentUserEmail.isNotEmpty
        ? currentUserEmail
        : 'correo_no_disponible';

    return Container(
      width: 268.0,
      height: 788.0,
      decoration: const BoxDecoration(
        color: Color(0x4E4E4E3D),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: 268.0,
            height: 64.0,
            decoration: const BoxDecoration(
              color: Color(0xFF222222),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(0.0, 11.0, 0.0, 0.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      'assets/images/logoSin.png',
                      width: 155.0,
                      height: 36.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Align(
                  alignment: const AlignmentDirectional(1.0, -1.0),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 0.0, 68.0, 0.0),
                    child: Text(
                      'Cochabamba- Bolivia',
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: 'Hind Vadodara',
                            color: const Color(0xFF969696),
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w500,
                            lineHeight: 1.0,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
            child: Container(
              width: 112.0,
              height: 112.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: Image.asset(
                    'assets/images/user.png',
                  ).image,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF1DB954),
                ),
              ),
            ),
          ),
          // 🔹 SOLO correo del usuario (nombre eliminado)
          Padding(
            padding:
                const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
            child: Text(
              emailToShow,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Hind Vadodara',
                    color: const Color(0xFF969696),
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                  ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 12.0),
            child: FFButtonWidget(
              onPressed: () async {
                GoRouter.of(context).prepareAuthEvent();
                await authManager.signOut();
                GoRouter.of(context).clearRedirectLocation();

                context.goNamedAuth(
                    BienvenidaWidget.routeName, context.mounted);
              },
              text: 'Cerrar Sesión',
              options: FFButtonOptions(
                width: 118.7,
                height: 25.35,
                padding: const EdgeInsetsDirectional.fromSTEB(
                    16.0, 0.0, 16.0, 0.0),
                iconPadding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                color: const Color(0xFF1DB954),
                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
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
                      fontWeight: FlutterFlowTheme.of(context)
                          .titleSmall
                          .fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).titleSmall.fontStyle,
                      shadows: const [
                        Shadow(
                          color: Color(0x00000040),
                          offset: Offset(3.0, 3.0),
                          blurRadius: 2.0,
                        )
                      ],
                    ),
                elevation: 0.0,
                borderSide: const BorderSide(
                  color: Color(0xFF1DB954),
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          Container(
            width: 242.0,
            height: 1.0,
            decoration: const BoxDecoration(
              color: Color(0xFF969696),
            ),
          ),
          InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              context.pushNamed(BuscarFarmaciaWidget.routeName);
            },
            child: Container(
              width: 268.0,
              height: 77.0,
              decoration: const BoxDecoration(
                color: Color(0xFF2D2D2D),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        39.0, 0.0, 0.0, 0.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        'assets/images/lupa.png',
                        width: 40.0,
                        height: 40.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        16.0, 0.0, 0.0, 0.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment:
                              const AlignmentDirectional(-1.0, -1.0),
                          child: Padding(
                            padding:
                                const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 16.0, 0.0, 0.0),
                            child: Text(
                              'Buscar Productos',
                              textAlign: TextAlign.start,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Hind Vadodara',
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    fontSize: 20.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                        ),
                        Align(
                          alignment:
                              const AlignmentDirectional(1.0, 1.0),
                          child: Text(
                            'Lo más cerca y al mejor precio',
                            textAlign: TextAlign.start,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Hind Vadodara',
                                  color: const Color(0xFF969696),
                                  fontSize: 12.0,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 242.0,
            height: 1.0,
            decoration: const BoxDecoration(
              color: Color(0xFF969696),
            ),
          ),
          InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              context.pushNamed(MisRutasWidget.routeName);
            },
            child: Container(
              width: 268.0,
              height: 77.0,
              decoration: const BoxDecoration(
                color: Color(0xFF2D2D2D),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        39.0, 0.0, 0.0, 0.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        'assets/images/iconMap.png',
                        width: 40.0,
                        height: 40.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        16.0, 0.0, 0.0, 0.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment:
                              const AlignmentDirectional(-1.0, -1.0),
                          child: Padding(
                            padding:
                                const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 16.0, 0.0, 0.0),
                            child: Text(
                              'Mis Rutas',
                              textAlign: TextAlign.start,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Hind Vadodara',
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    fontSize: 20.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                        ),
                        Align(
                          alignment:
                              const AlignmentDirectional(1.0, 1.0),
                          child: Text(
                            'Historial de rutas',
                            textAlign: TextAlign.start,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Hind Vadodara',
                                  color: const Color(0xFF969696),
                                  fontSize: 12.0,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 242.0,
            height: 1.0,
            decoration: const BoxDecoration(
              color: Color(0xFF969696),
            ),
          ),
          InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              context.pushNamed(CarritoWidget.routeName);
            },
            child: Container(
              width: 268.0,
              height: 77.0,
              decoration: const BoxDecoration(
                color: Color(0xFF2D2D2D),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        39.0, 0.0, 0.0, 0.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        'https://cdn-icons-png.flaticon.com/512/8567/8567808.png',
                        width: 40.0,
                        height: 40.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        16.0, 0.0, 0.0, 0.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment:
                              const AlignmentDirectional(-1.0, -1.0),
                          child: Padding(
                            padding:
                                const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 16.0, 0.0, 0.0),
                            child: Text(
                              'Carrito',
                              textAlign: TextAlign.start,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Hind Vadodara',
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    fontSize: 20.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                        ),
                        Align(
                          alignment:
                              const AlignmentDirectional(1.0, 1.0),
                          child: Text(
                            'Productos seleccionados',
                            textAlign: TextAlign.start,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Hind Vadodara',
                                  color: const Color(0xFF969696),
                                  fontSize: 12.0,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 242.0,
            height: 1.0,
            decoration: const BoxDecoration(
              color: Color(0xFF969696),
            ),
          ),
          Flexible(
            child: Align(
              alignment: const AlignmentDirectional(0.0, 1.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        39.0, 0.0, 0.0, 0.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        'assets/images/iconexcla.png',
                        width: 29.0,
                        height: 29.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        14.0, 0.0, 0.0, 0.0),
                    child: Text(
                      'Sobre nosotros',
                      style: FlutterFlowTheme.of(context)
                          .bodyMedium
                          .override(
                            fontFamily: 'Hind Vadodara',
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            fontSize: 20.0,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsetsDirectional.fromSTEB(0.0, 21.0, 0.0, 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(
                          39.0, 0.0, 0.0, 0.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      'assets/images/iconquestion.png',
                      width: 29.0,
                      height: 29.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(
                          14.0, 0.0, 0.0, 0.0),
                  child: Text(
                    'Ayuda y \ncomentarios',
                    style: FlutterFlowTheme.of(context)
                        .bodyMedium
                        .override(
                          fontFamily: 'Hind Vadodara',
                          color: FlutterFlowTheme.of(context)
                              .secondaryBackground,
                          fontSize: 20.0,
                          letterSpacing: 0.0,
                          lineHeight: 1.0,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
