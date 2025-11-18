import '/backend/schema/structs/index.dart';
import '/components/menu_lateral_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'carrito_widget.dart' show CarritoWidget;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CarritoModel extends FlutterFlowModel<CarritoWidget> {
  ///  Local state fields for this page.

  bool buscar = false;

  ///  State fields for stateful widgets in this page.

  // State field(s) for campoBusqueda2 widget.
  FocusNode? campoBusqueda2FocusNode;
  TextEditingController? campoBusqueda2TextController;
  String? Function(BuildContext, String?)?
      campoBusqueda2TextControllerValidator;
  // Model for menuLateral component.
  late MenuLateralModel menuLateralModel;

  @override
  void initState(BuildContext context) {
    menuLateralModel = createModel(context, () => MenuLateralModel());
  }

  @override
  void dispose() {
    campoBusqueda2FocusNode?.dispose();
    campoBusqueda2TextController?.dispose();

    menuLateralModel.dispose();
  }
}
