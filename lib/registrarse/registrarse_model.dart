import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'registrarse_widget.dart' show RegistrarseWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class RegistrarseModel extends FlutterFlowModel<RegistrarseWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for campoCorreo widget.
  FocusNode? campoCorreoFocusNode;
  TextEditingController? campoCorreoTextController;
  String? Function(BuildContext, String?)? campoCorreoTextControllerValidator;
  // State field(s) for campoContrasena widget.
  FocusNode? campoContrasenaFocusNode;
  TextEditingController? campoContrasenaTextController;
  late bool campoContrasenaVisibility;
  String? Function(BuildContext, String?)?
      campoContrasenaTextControllerValidator;
  // State field(s) for campoRepetirContra widget.
  FocusNode? campoRepetirContraFocusNode;
  TextEditingController? campoRepetirContraTextController;
  late bool campoRepetirContraVisibility;
  String? Function(BuildContext, String?)?
      campoRepetirContraTextControllerValidator;

  @override
  void initState(BuildContext context) {
    campoContrasenaVisibility = false;
    campoRepetirContraVisibility = false;
  }

  @override
  void dispose() {
    campoCorreoFocusNode?.dispose();
    campoCorreoTextController?.dispose();

    campoContrasenaFocusNode?.dispose();
    campoContrasenaTextController?.dispose();

    campoRepetirContraFocusNode?.dispose();
    campoRepetirContraTextController?.dispose();
  }
}
