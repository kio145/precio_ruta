import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'iniciar_sesion_widget.dart' show IniciarSesionWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class IniciarSesionModel extends FlutterFlowModel<IniciarSesionWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for correoIni widget.
  FocusNode? correoIniFocusNode;
  TextEditingController? correoIniTextController;
  String? Function(BuildContext, String?)? correoIniTextControllerValidator;
  // State field(s) for contraIni widget.
  FocusNode? contraIniFocusNode;
  TextEditingController? contraIniTextController;
  late bool contraIniVisibility;
  String? Function(BuildContext, String?)? contraIniTextControllerValidator;

  @override
  void initState(BuildContext context) {
    contraIniVisibility = false;
  }

  @override
  void dispose() {
    correoIniFocusNode?.dispose();
    correoIniTextController?.dispose();

    contraIniFocusNode?.dispose();
    contraIniTextController?.dispose();
  }
}
