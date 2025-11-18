import '/components/menu_lateral_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import 'fechas_widget.dart' show FechasWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FechasModel extends FlutterFlowModel<FechasWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for DropDown widget.
  String? dropDownValue1;
  FormFieldController<String>? dropDownValueController1;
  // State field(s) for DropDown widget.
  String? dropDownValue2;
  FormFieldController<String>? dropDownValueController2;
  // Model for menuLateral component.
  late MenuLateralModel menuLateralModel;

  @override
  void initState(BuildContext context) {
    menuLateralModel = createModel(context, () => MenuLateralModel());
  }

  @override
  void dispose() {
    menuLateralModel.dispose();
  }
}
