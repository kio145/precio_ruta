import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/components/menu_lateral_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import '/index.dart';
import 'buscar_farmacia_widget.dart' show BuscarFarmaciaWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:text_search/text_search.dart';

class BuscarFarmaciaModel extends FlutterFlowModel<BuscarFarmaciaWidget> {
  ///  Local state fields for this page.

  bool buscar = false;

  String? textoBuscado;

  bool mostrarEncontrados = false;

  ///  State fields for stateful widgets in this page.

  // Model for menuLateral5.
  late MenuLateralModel menuLateral5Model;
  // State field(s) for campoBusqueda8 widget.
  FocusNode? campoBusqueda8FocusNode;
  TextEditingController? campoBusqueda8TextController;
  String? Function(BuildContext, String?)?
      campoBusqueda8TextControllerValidator;
  List<ProductsRecord> simpleSearchResults = [];
  // State field(s) for DropDown widget.
  String? dropDownValue;
  FormFieldController<String>? dropDownValueController;

  @override
  void initState(BuildContext context) {
    menuLateral5Model = createModel(context, () => MenuLateralModel());
  }

  @override
  void dispose() {
    menuLateral5Model.dispose();
    campoBusqueda8FocusNode?.dispose();
    campoBusqueda8TextController?.dispose();
  }
}
