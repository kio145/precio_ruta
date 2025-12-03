import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/menu_lateral_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_google_map.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'mis_rutas_model.dart';
export 'mis_rutas_model.dart';

// Producto comprado en una visita
class _ProductoHist {
  final String name;
  final int qty;
  final double unitPrice;
  final double subtotal;

  _ProductoHist({
    required this.name,
    required this.qty,
    required this.unitPrice,
    required this.subtotal,
  });
}

// Visita a una sucursal
class _RutaHist {
  final String id;
  final SucursalesRecord sucursal;
  final double total;
  final DateTime? createdAt;
  final List<_ProductoHist> productos;

  _RutaHist({
    required this.id,
    required this.sucursal,
    required this.total,
    required this.createdAt,
    required this.productos,
  });
}

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

  int? _selectedMonth;
  int? _selectedYear;

  // Años y (año-mes)
  Set<int> _availableYears = {};
  Set<String> _availableYearMonths = {};
  bool _loadingPeriods = true;

  // sucursal seleccionada
  String? _selectedSucursalId;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MisRutasModel());

    // Ubicación actual
    getCurrentUserLocation(defaultLocation: LatLng(0.0, 0.0), cached: true)
        .then((loc) => safeSetState(() => currentUserLocationValue = loc));

    // Mes y año actuales
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;

    _model.dropDownValue1 ??= now.month.toString();
    _model.dropDownValue2 ??= now.year.toString();

    // Cargar periodos disponibles
    _loadAvailablePeriods();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _loadAvailablePeriods() async {
    try {
      final ref = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .collection('rutas_history');

      final qs = await ref.get();

      final years = <int>{};
      final yearMonths = <String>{};

      for (final doc in qs.docs) {
        final data = doc.data();
        final y = (data['year'] as num?)?.toInt();
        final m = (data['month'] as num?)?.toInt();
        if (y != null && m != null) {
          years.add(y);
          yearMonths.add('$y-${m.toString().padLeft(2, '0')}');
        }
      }

      // Siempre incluir el año actual
      final currentYear = DateTime.now().year;
      years.add(currentYear);

      safeSetState(() {
        _availableYears = years;
        _availableYearMonths = yearMonths;
        _loadingPeriods = false;
      });
    } catch (e) {
      debugPrint('Error cargando periodos de rutas: $e');
      safeSetState(() {
        _loadingPeriods = false;
      });
    }
  }

  Future<List<_RutaHist>> _loadRutas(int year, int month) async {
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .collection('rutas_history');

    final qs = await ref
        .where('year', isEqualTo: year)
        .where('month', isEqualTo: month)
        .get();

    // Orden por fecha desc
    final docs = [...qs.docs];
    docs.sort((a, b) {
      final da =
          (a.data()['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
      final db =
          (b.data()['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
      return db.compareTo(da);
    });

    final List<_RutaHist> res = [];
    for (final doc in docs) {
      final data = doc.data();
      final sucRef = data['sucursalRef'] as DocumentReference?;
      if (sucRef == null) continue;

      final suc = await SucursalesRecord.getDocumentOnce(sucRef);
      if (suc.ubicacion == null) continue;

      final total =
          (data['total'] is num) ? (data['total'] as num).toDouble() : 0.0;
      final createdAtTs = data['createdAt'] as Timestamp?;
      final createdAt = createdAtTs?.toDate();

      final productos = <_ProductoHist>[];
      final rawProducts = data['products'] as List<dynamic>?;

      if (rawProducts != null) {
        for (final p in rawProducts) {
          if (p is Map<String, dynamic>) {
            final name = p['name'] as String? ?? '';
            final qty = (p['qty'] as num?)?.toInt() ?? 0;
            final unitPrice = (p['unitPrice'] as num?)?.toDouble() ?? 0.0;
            final subtotal =
                (p['subtotal'] as num?)?.toDouble() ?? qty * unitPrice;
            productos.add(
              _ProductoHist(
                name: name,
                qty: qty,
                unitPrice: unitPrice,
                subtotal: subtotal,
              ),
            );
          }
        }
      }

      res.add(
        _RutaHist(
          id: doc.id,
          sucursal: suc,
          total: total,
          createdAt: createdAt,
          productos: productos,
        ),
      );
    }
    return res;
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

    // Combos mes / año
    final monthValues =
        List<String>.generate(12, (i) => (i + 1).toString()); // '1'..'12'
    const monthLabels = [
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
      'DICIEMBRE',
    ];

    final yearsList = _availableYears.isEmpty
        ? [DateTime.now().year]
        : _availableYears.toList()..sort();
    final yearValues = yearsList.map((e) => e.toString()).toList();
    final yearLabels = yearValues;

    final selMonth = _selectedMonth ?? DateTime.now().month;
    final selYear = _selectedYear ?? DateTime.now().year;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFF5F5F5),
        drawer: SizedBox(
          width: 268.0,
          child: Drawer(
            elevation: 16.0,
            child: wrapWithModel(
              model: _model.menuLateralModel,
              updateCallback: () => safeSetState(() {}),
              child: const MenuLateralWidget(),
            ),
          ),
        ),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(59.0),
          child: AppBar(
            backgroundColor: const Color(0xFF222222),
            automaticallyImplyLeading: false,
            leading: Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(11.0, 0.0, 0.0, 0.0),
              child: FlutterFlowIconButton(
                borderColor: Colors.transparent,
                borderRadius: 30.0,
                borderWidth: 1.0,
                buttonSize: 85.53,
                icon: const Icon(
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
              padding:
                  const EdgeInsetsDirectional.fromSTEB(11.0, 0.0, 0.0, 0.0),
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
            actions: const [],
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
                alignment: const AlignmentDirectional(-1.0, 1.0),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      22.0, 19.0, 0.0, 0.0),
                  child: Text(
                    'Seleccione :',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Hind Vadodara',
                          color: const Color(0xFF222222),
                          fontSize: 20.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),

              /// FILTROS MES / AÑO
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            16.0, 0.0, 8.0, 0.0),
                        child: FlutterFlowDropDown<String>(
                          controller: _model.dropDownValueController1 ??=
                              FormFieldController<String>(
                            _model.dropDownValue1 ?? selMonth.toString(),
                          ),
                          options: monthValues,
                          optionLabels: monthLabels,
                          onChanged: (val) =>
                              safeSetState(() => _model.dropDownValue1 = val),
                          width: double.infinity,
                          height: 46.0,
                          textStyle:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.inter(
                                      fontWeight:
                                          FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .fontWeight,
                                      fontStyle:
                                          FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .fontStyle,
                                    ),
                                    color: const Color(0xFF212224),
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
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
                          borderColor: const Color(0xFF969696),
                          borderWidth: 0.0,
                          borderRadius: 0.0,
                          margin: const EdgeInsetsDirectional.fromSTEB(
                              12.0, 0.0, 12.0, 0.0),
                          hidesUnderline: true,
                          isOverButton: false,
                          isSearchable: false,
                          isMultiSelect: false,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            8.0, 0.0, 16.0, 0.0),
                        child: FlutterFlowDropDown<String>(
                          controller: _model.dropDownValueController2 ??=
                              FormFieldController<String>(
                            _model.dropDownValue2 ?? selYear.toString(),
                          ),
                          options: yearValues,
                          optionLabels: yearLabels,
                          onChanged: (val) =>
                              safeSetState(() => _model.dropDownValue2 = val),
                          width: double.infinity,
                          height: 46.0,
                          textStyle:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.inter(
                                      fontWeight:
                                          FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .fontWeight,
                                      fontStyle:
                                          FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .fontStyle,
                                    ),
                                    color: const Color(0xFF212224),
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
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
                          borderColor: const Color(0xFF969696),
                          borderWidth: 0.0,
                          borderRadius: 0.0,
                          margin: const EdgeInsetsDirectional.fromSTEB(
                              12.0, 0.0, 12.0, 0.0),
                          hidesUnderline: true,
                          isOverButton: false,
                          isSearchable: false,
                          isMultiSelect: false,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// BOTÓN FILTRAR
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 15.0, 0.0, 0.0),
                child: FFButtonWidget(
                  onPressed: () {
                    final m = int.tryParse(_model.dropDownValue1 ?? '');
                    final y = int.tryParse(_model.dropDownValue2 ?? '');
                    if (m == null || y == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Selecciona un mes y un año válidos.'),
                        ),
                      );
                      return;
                    }

                    final key = '$y-${m.toString().padLeft(2, '0')}';

                    if (!_availableYearMonths.contains(key)) {
                      final idx = m - 1;
                      final monthName =
                          (idx >= 0 && idx < monthLabels.length)
                              ? monthLabels[idx]
                              : 'mes seleccionado';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'No realizó compra alguna en este mes ($monthName) y año ($y).',
                          ),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      _selectedMonth = m;
                      _selectedYear = y;
                      _selectedSucursalId = null;
                    });
                  },
                  text: 'Filtrar',
                  options: FFButtonOptions(
                    width: 206.0,
                    height: 41.0,
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        16.0, 0.0, 16.0, 0.0),
                    iconPadding:
                        const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                    color: const Color(0xFF1DB954),
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

              /// MAPA + RESUMEN + PANEL
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      0.0, 15.0, 0.0, 0.0),
                  child: FutureBuilder<List<_RutaHist>>(
                    future: (_selectedYear != null && _selectedMonth != null)
                        ? _loadRutas(_selectedYear!, _selectedMonth!)
                        : Future.value(<_RutaHist>[]),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || _loadingPeriods) {
                        return Center(
                          child: SizedBox(
                            width: 50.0,
                            height: 50.0,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                          ),
                        );
                      }

                      final rutas = snapshot.data!;

                      // Agrupar por sucursal
                      final Map<String, List<_RutaHist>> rutasPorSucursal = {};
                      for (final r in rutas) {
                        final sucId = r.sucursal.reference.id;
                        rutasPorSucursal.putIfAbsent(sucId, () => []).add(r);
                      }

                      final visitasMes = rutas.length;
                      final totalMes =
                          rutas.fold<double>(0.0, (acc, r) => acc + r.total);

                      // Marcadores: usuario + uno por sucursal
                      final markers = <FlutterFlowMarker>[
                        FlutterFlowMarker(
                          'user',
                          currentUserLocationValue!,
                        ),
                        ...rutasPorSucursal.entries.map(
                          (entry) => FlutterFlowMarker(
                            entry.key,
                            entry.value.first.sucursal.ubicacion!,
                          ),
                        ),
                      ];

                      final initialLocation = rutas.isNotEmpty
                          ? rutas.first.sucursal.ubicacion!
                          : (currentUserLocationValue!);

                      // datos sucursal seleccionada
                      final selectedRutas = (_selectedSucursalId != null)
                          ? (rutasPorSucursal[_selectedSucursalId] ?? [])
                          : <_RutaHist>[];
                      final selectedSucursal = selectedRutas.isNotEmpty
                          ? selectedRutas.first.sucursal
                          : null;
                      final visitasSucursal = selectedRutas.length;
                      final totalSucursal = selectedRutas.fold<double>(
                          0.0, (acc, r) => acc + r.total);

                      return Column(
                        children: [
                          // MAPA
                          SizedBox(
                            width: double.infinity,
                            height: 260,
                            child: FlutterFlowGoogleMap(
                              controller: _model.googleMapsController,
                              onCameraIdle: (latLng) =>
                                  _model.googleMapsCenter = latLng,
                              initialLocation: _model.googleMapsCenter ??=
                                  initialLocation,
                              markers: markers,
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

                          // RESUMEN DEL MES
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Visitas en el mes: $visitasMes',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                ),
                                Text(
                                  'Total mes: Bs. ${totalMes.toStringAsFixed(2)}',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                ),
                              ],
                            ),
                          ),

                          // FILA DE SUCURSALES (chips)
                          if (rutasPorSucursal.isNotEmpty)
                            SizedBox(
                              height: 60,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                children: rutasPorSucursal.entries.map((entry) {
                                  final sucId = entry.key;
                                  final suc = entry.value.first.sucursal;
                                  final visitas = entry.value.length;
                                  final isSelected =
                                      sucId == _selectedSucursalId;

                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: ChoiceChip(
                                      label: Text(
                                        '${suc.nombre.isNotEmpty ? suc.nombre : "Sucursal"}\n$visitas visita(s)',
                                        textAlign: TextAlign.center,
                                      ),
                                      selected: isSelected,
                                      selectedColor:
                                          const Color(0xFF1DB954),
                                      labelStyle: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            font: GoogleFonts.inter(
                                              color: isSelected
                                                  ? Colors.white
                                                  : const Color(0xFF222222),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                      onSelected: (_) {
                                        setState(() {
                                          _selectedSucursalId = sucId;
                                          _model.googleMapsCenter =
                                              suc.ubicacion;
                                        });
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),

                          const SizedBox(height: 8),

                          // PANEL DETALLE SUCURSAL
                          Expanded(
                            child: selectedSucursal == null
                                ? Center(
                                    child: Text(
                                      rutasPorSucursal.isEmpty
                                          ? 'No hay visitas registradas para este periodo.'
                                          : 'Selecciona una sucursal en la fila superior para ver el detalle.',
                                      textAlign: TextAlign.center,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(),
                                          ),
                                    ),
                                  )
                                : ListView(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 6.0),
                                    children: [
                                      Card(
                                        color: const Color(0xFFF5F5F5),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                selectedSucursal.nombre
                                                        .isNotEmpty
                                                    ? selectedSucursal.nombre
                                                    : 'Sucursal sin nombre',
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .titleSmall
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Visitas en esta sucursal: $visitasSucursal',
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                              ),
                                              Text(
                                                'Total gastado aquí: Bs. ${totalSucursal.toStringAsFixed(2)}',
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                'Detalle de visitas:',
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                              ),
                                              const SizedBox(height: 6),
                                              ...selectedRutas.map((r) {
                                                final fechaStr =
                                                    r.createdAt != null
                                                        ? dateTimeFormat(
                                                            'dd/MM/yyyy HH:mm',
                                                            r.createdAt,
                                                          )
                                                        : '';
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 8.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        fechaStr,
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodySmall
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .inter(
                                                                    color: const Color(
                                                                        0xFF666666),
                                                                  ),
                                                                ),
                                                      ),
                                                      Text(
                                                        'Total: Bs. ${r.total.toStringAsFixed(2)}',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .inter(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                      ),
                                                      const SizedBox(
                                                          height: 2),
                                                      Text(
                                                        'Productos:',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .inter(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                      ),
                                                      ...r.productos.map(
                                                        (p) => Text(
                                                          '• ${p.name} (x${p.qty}) - Bs. ${p.subtotal.toStringAsFixed(2)}',
                                                          style:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmall
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .inter(),
                                                                  ),
                                                        ),
                                                      ),
                                                      const Divider(),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      );
                    },
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
