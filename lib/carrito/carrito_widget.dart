import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/items_record.dart';
import '/components/menu_lateral_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'carrito_model.dart';
export 'carrito_model.dart';

// Servicio Firestore del carrito
import '/services/cart_fs.dart';

class CarritoWidget extends StatefulWidget {
  const CarritoWidget({super.key});

  static String routeName = 'Carrito';
  static String routePath = '/carrito';

  @override
  State<CarritoWidget> createState() => _CarritoWidgetState();
}

class _CarritoWidgetState extends State<CarritoWidget> {
  late CarritoModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CarritoModel());
    _model.campoBusqueda2TextController ??= TextEditingController();
    _model.campoBusqueda2FocusNode ??= FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // ====== Helpers para ItemsRecord (Firestore) ======
  String _safeImg(String? url) {
    final u = (url ?? '').trim();
    if (u.isEmpty) {
      return 'https://cdn-icons-png.flaticon.com/512/1988/1988002.png';
    }
    return u;
  }

  int _qty(ItemsRecord it) => it.qty;
  double _subtotal(ItemsRecord it) => it.unitPrice * it.qty;

  // ====== Agrupar por farmacia ======
  Map<String, _FarmGroup> _groupByPharmacy(List<ItemsRecord> items) {
    final Map<String, _FarmGroup> groups = {};
    for (final it in items) {
      final slug = (it.pharmacySlug).isNotEmpty ? it.pharmacySlug : 'desconocida';
      final label = (it.pharmacyLabel).isNotEmpty ? it.pharmacyLabel : 'Farmacia';
      final logo = it.pharmacyLogo;

      groups.putIfAbsent(
        slug,
        () => _FarmGroup(slug: slug, label: label, logo: logo, items: []),
      );
      groups[slug]!.items.add(it);
    }

    // Totales por grupo
    for (final g in groups.values) {
      double t = 0;
      for (final it in g.items) {
        t += _subtotal(it);
      }
      g.total = t;
    }
    return groups;
  }

  // ====== UI: buscador ======
  Widget _buildSearchBar() {
    return Align(
      alignment: const AlignmentDirectional(0.0, 0.0),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 22.0, 0.0, 12.0),
        child: SizedBox(
          width: 347.0,
          child: TextFormField(
            controller: _model.campoBusqueda2TextController,
            focusNode: _model.campoBusqueda2FocusNode,
            autofocus: false,
            textInputAction: TextInputAction.done,
            onChanged: (_) => safeSetState(() {}), // <<< para refrescar el filtro
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Buscar en tu carrito...',
              hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                    fontFamily: 'Hind Vadodara',
                    fontSize: 15.0,
                    letterSpacing: 0.0,
                  ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF969696), width: 1.0),
                borderRadius: BorderRadius.zero,
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF1DB954), width: 1.0),
                borderRadius: BorderRadius.zero,
              ),
              filled: true,
              fillColor: FlutterFlowTheme.of(context).secondaryBackground,
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF969696),
                size: 22.0,
              ),
            ),
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(
                    fontWeight:
                        FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
                  color: Colors.black,
                  letterSpacing: 0.0,
                ),
            cursorColor: const Color(0xFF1DB954),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
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
              padding: const EdgeInsetsDirectional.fromSTEB(11.0, 0.0, 0.0, 0.0),
              child: FlutterFlowIconButton(
                borderColor: Colors.transparent,
                borderRadius: 30.0,
                borderWidth: 1.0,
                buttonSize: 85.5,
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
              padding: const EdgeInsetsDirectional.fromSTEB(11.0, 0.0, 0.0, 0.0),
              child: Text(
                'BUSCAR  FARMACIA',
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                      fontFamily: 'Hind Vadodara',
                      color: Colors.white,
                      fontSize: 22.0,
                      letterSpacing: 0.0,
                    ),
              ),
            ),
            centerTitle: false,
            elevation: 2.0,
          ),
        ),
        body: SafeArea(
          top: true,
          child: StreamBuilder<List<ItemsRecord>>(
            stream: CartFS.watchItems(currentUserUid),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final items = snap.data!;
              if (items.isEmpty) {
                return Column(
                  children: [
                    _buildSearchBar(),
                    const Expanded(
                      child: Center(child: Text('Tu carrito está vacío')),
                    ),
                  ],
                );
              }

              // Texto de búsqueda
              final query =
                  _model.campoBusqueda2TextController.text.trim().toLowerCase();

              // Filtrar SOLO los productos del carrito según el nombre
              final visibleItems = query.isEmpty
                  ? items
                  : items
                      .where((it) =>
                          it.name.toLowerCase().contains(query))
                      .toList();

              // Agrupar por farmacia usando solo los items filtrados
              final groupsMap = _groupByPharmacy(visibleItems);
              final groups = groupsMap.values.toList();

              // Total general del carrito (con todos los items, no solo los filtrados)
              final grandTotal = items.fold<double>(
                0,
                (s, it) => s + _subtotal(it),
              );

              return Column(
                children: [
                  _buildSearchBar(),

                  // Lista por grupos (farmacias)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                      child: groups.isEmpty
                          ? const Center(
                              child: Text(
                                'No se encontraron productos que coincidan con la búsqueda',
                              ),
                            )
                          : ListView.separated(
                              itemCount: groups.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 14),
                              itemBuilder: (context, gi) {
                                final g = groups[gi];
                                return Container(
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFD6D6D6),
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        blurRadius: 2,
                                        color: Color(0x00000021),
                                        offset: Offset(1, 2),
                                      )
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Encabezado: Logo/label farmacia
                                        Row(
                                          children: [
                                            if (g.logo.isNotEmpty)
                                              Image.network(
                                                _safeImg(g.logo),
                                                height: 30,
                                                fit: BoxFit.contain,
                                                errorBuilder:
                                                    (_, __, ___) =>
                                                        const SizedBox(),
                                              ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                g.label,
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .titleMedium,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          height: 1,
                                          color: const Color(0xFFDDDDDD),
                                        ),
                                        const SizedBox(height: 6),

                                        // Items de la farmacia
                                        ...g.items.map((it) {
                                          final subtotal = _subtotal(it);
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8.0,
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                // Imagen
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  child: Image.network(
                                                    _safeImg(it.imageUrl),
                                                    width: 32,
                                                    height: 32,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (_, __, ___) =>
                                                        const Icon(
                                                      Icons
                                                          .image_not_supported,
                                                      size: 22,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),

                                                // Nombre + precio unitario
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        it.name,
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: FlutterFlowTheme
                                                                .of(context)
                                                            .bodyMedium
                                                            .override(
                                                              font:
                                                                  GoogleFonts
                                                                      .inter(
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                              ),
                                                              color:
                                                                  Colors.black,
                                                              letterSpacing:
                                                                  0.0,
                                                            ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        'Bs. ${it.unitPrice.toStringAsFixed(2)} c/u',
                                                        style: FlutterFlowTheme
                                                                .of(context)
                                                            .labelSmall
                                                            .override(
                                                              font:
                                                                  GoogleFonts
                                                                      .inter(
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmall
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmall
                                                                    .fontStyle,
                                                              ),
                                                              color:
                                                                  const Color(
                                                                      0xFF555555),
                                                              letterSpacing:
                                                                  0.0,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 10),

                                                // Subtotal
                                                Text(
                                                  'Bs. ${subtotal.toStringAsFixed(2)}',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        color: Colors.black,
                                                        letterSpacing: 0.0,
                                                      ),
                                                ),
                                                const SizedBox(width: 10),

                                                // Stepper: − qty +
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: const Color(
                                                          0xFF969696),
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      6,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      InkWell(
                                                        onTap: () async {
                                                          if (it.qty > 1) {
                                                            await CartFS
                                                                .increment(
                                                              uid:
                                                                  currentUserUid,
                                                              item: it,
                                                              delta: -1,
                                                            );
                                                          } else {
                                                            await CartFS
                                                                .removeItem(
                                                              item: it,
                                                            );
                                                          }
                                                        },
                                                        child: const Icon(
                                                          Icons
                                                              .remove_circle_outline,
                                                          size: 18,
                                                          color: Color(
                                                              0xFF969696),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        'x${_qty(it)}',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      InkWell(
                                                        onTap: () async {
                                                          await CartFS
                                                              .increment(
                                                            uid:
                                                                currentUserUid,
                                                            item: it,
                                                            delta: 1,
                                                          );
                                                        },
                                                        child: const Icon(
                                                          Icons
                                                              .add_circle_outline,
                                                          size: 18,
                                                          color: Color(
                                                              0xFF009FE3),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),

                                        const SizedBox(height: 6),
                                        Container(
                                          height: 1,
                                          color: const Color(0xFFDDDDDD),
                                        ),
                                        const SizedBox(height: 8),

                                        // Total por farmacia
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              'Sub Total:  ',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium,
                                            ),
                                            Text(
                                              'Bs. ${(g.total ?? 0).toStringAsFixed(2)}',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.inter(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),

                  // Total general + Botón inferior
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Total:  ',
                          style: FlutterFlowTheme.of(context).bodyMedium,
                        ),
                        Text(
                          'Bs. ${grandTotal.toStringAsFixed(2)}',
                          style: FlutterFlowTheme.of(context).bodyMedium
                              .override(
                            font: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: FFButtonWidget(
                      onPressed: () async {
                        context.pushNamed(RutaWidget.routeName);
                      },
                      text: 'Ver Ubicaciones',
                      options: FFButtonOptions(
                        width: 206.0,
                        height: 41.0,
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                        color: const Color.fromARGB(255, 33, 86, 52),
                        textStyle: FlutterFlowTheme.of(context)
                            .titleSmall
                            .override(
                              font: GoogleFonts.interTight(
                                fontWeight: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .fontStyle,
                              ),
                              color: Colors.white,
                              fontSize: 20.0,
                              letterSpacing: 0.0,
                            ),
                        elevation: 0.0,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ==== Modelo interno para agrupación ====
class _FarmGroup {
  _FarmGroup({
    required this.slug,
    required this.label,
    required this.logo,
    required this.items,
    this.total,
  });

  final String slug;
  final String label;
  final String logo;
  final List<ItemsRecord> items;
  double? total;
}
