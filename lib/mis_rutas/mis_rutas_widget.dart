import '/components/menu_lateral_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_google_map.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'mis_rutas_model.dart';
export 'mis_rutas_model.dart';

class MisRutasWidget extends StatefulWidget {
  const MisRutasWidget({super.key});

  static String routeName = 'MisRutas';
  static String routePath = '/misRutas';

  @override
  State<MisRutasWidget> createState() => _MisRutasWidgetState();
}

class _MisRutasWidgetState extends State<MisRutasWidget> {
  late MisRutasModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  LatLng? currentUserLocationValue;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MisRutasModel());

    getCurrentUserLocation(defaultLocation: LatLng(0.0, 0.0), cached: true)
        .then((loc) => safeSetState(() => currentUserLocationValue = loc));
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: Color(0xFFF5F5F5),
        drawer: Container(
          width: 268.0,
          child: Drawer(
            elevation: 16.0,
            child: wrapWithModel(
              model: _model.menuLateralModel,
              updateCallback: () => safeSetState(() {}),
              child: MenuLateralWidget(),
            ),
          ),
        ),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(59.0),
          child: AppBar(
            backgroundColor: Color(0xFF222222),
            automaticallyImplyLeading: false,
            leading: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(11.0, 0.0, 0.0, 0.0),
              child: FlutterFlowIconButton(
                borderColor: Colors.transparent,
                borderRadius: 30.0,
                borderWidth: 1.0,
                buttonSize: 85.53,
                icon: Icon(
                  Icons.menu,
                  color: Color(0xFF1DB954),
                  size: 45.0,
                ),
                onPressed: () async {
                  scaffoldKey.currentState!.openDrawer();
                },
              ),
            ),
            title: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(11.0, 0.0, 0.0, 0.0),
              child: Text(
                'MIS RUTAS',
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                      fontFamily: 'Hind Vadodara',
                      color: Colors.white,
                      fontSize: 22.0,
                      letterSpacing: 0.0,
                    ),
              ),
            ),
            actions: [],
            centerTitle: false,
            elevation: 2.0,
          ),
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Align(
                alignment: AlignmentDirectional(-1.0, 1.0),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(22.0, 19.0, 0.0, 0.0),
                  child: Text(
                    'Seleccione :',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Hind Vadodara',
                          color: Color(0xFF222222),
                          fontSize: 20.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            22.0, 0.0, 35.0, 0.0),
                        child: FlutterFlowDropDown<String>(
                          controller: _model.dropDownValueController1 ??=
                              FormFieldController<String>(
                            _model.dropDownValue1 ??= '',
                          ),
                          options: List<String>.from([
                            'ENERO',
                            'Option 2',
                            'Option 3',
                            '3',
                            '4',
                            '5',
                            '6',
                            '7',
                            '8',
                            '9',
                            '10',
                            '11'
                          ]),
                          optionLabels: [
                            'ENERO',
                            'FEBRERO',
                            'MARZO',
                            'ABRIL',
                            'MAYO',
                            'JUNIO',
                            'JULIO',
                            'AGOSTO',
                            'SEPTIEMBRE',
                            'OCTUBRE',
                            'NOVIEMBRE',
                            'DICIEMBRE'
                          ],
                          onChanged: (val) =>
                              safeSetState(() => _model.dropDownValue1 = val),
                          width: 157.0,
                          height: 46.0,
                          textStyle:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: Color(0xFF212224),
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                          hintText: 'MES',
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            size: 19.68,
                          ),
                          fillColor:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          elevation: 2.0,
                          borderColor: Color(0xFF969696),
                          borderWidth: 0.0,
                          borderRadius: 0.0,
                          margin: EdgeInsetsDirectional.fromSTEB(
                              12.0, 0.0, 12.0, 0.0),
                          hidesUnderline: true,
                          isOverButton: false,
                          isSearchable: false,
                          isMultiSelect: false,
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 22.0, 0.0),
                      child: FlutterFlowDropDown<String>(
                        controller: _model.dropDownValueController2 ??=
                            FormFieldController<String>(
                          _model.dropDownValue2 ??= '',
                        ),
                        options: List<String>.from(['2026', '1', '2']),
                        optionLabels: ['2026', '2025', '2024'],
                        onChanged: (val) =>
                            safeSetState(() => _model.dropDownValue2 = val),
                        width: 157.0,
                        height: 46.0,
                        textStyle:
                            FlutterFlowTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: Color(0xFF212224),
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                        hintText: 'AÑO',
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: FlutterFlowTheme.of(context).secondaryText,
                          size: 19.68,
                        ),
                        fillColor:
                            FlutterFlowTheme.of(context).secondaryBackground,
                        elevation: 2.0,
                        borderColor: Color(0xFF969696),
                        borderWidth: 0.0,
                        borderRadius: 0.0,
                        margin: EdgeInsetsDirectional.fromSTEB(
                            12.0, 0.0, 12.0, 0.0),
                        hidesUnderline: true,
                        isOverButton: false,
                        isSearchable: false,
                        isMultiSelect: false,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 15.0, 0.0, 0.0),
                child: FFButtonWidget(
                  onPressed: () {
                    print('Button pressed ...');
                  },
                  text: 'Filtrar',
                  options: FFButtonOptions(
                    width: 206.0,
                    height: 41.0,
                    padding:
                        EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                    iconPadding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                    color: Color(0xFF1DB954),
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: 'Hind Vadodara',
                          color: Colors.white,
                          fontSize: 20.0,
                          letterSpacing: 0.0,
                        ),
                    elevation: 0.0,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 15.0, 0.0, 0.0),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(),
                    child: FlutterFlowGoogleMap(
                      controller: _model.googleMapsController,
                      onCameraIdle: (latLng) =>
                          _model.googleMapsCenter = latLng,
                      initialLocation: _model.googleMapsCenter ??=
                          currentUserLocationValue!,
                      markerColor: GoogleMarkerColor.violet,
                      mapType: MapType.normal,
                      style: GoogleMapStyle.standard,
                      initialZoom: 14.0,
                      allowInteraction: true,
                      allowZoom: true,
                      showZoomControls: true,
                      showLocation: true,
                      showCompass: false,
                      showMapToolbar: false,
                      showTraffic: false,
                      centerMapOnMarkerTap: true,
                      mapTakesGesturePreference: false,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
