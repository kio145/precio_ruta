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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:text_search/text_search.dart';
import 'package:route_price/services/maintenance_service.dart';

// <<< IMPORTANTE: servicio del carrito >>>
import '/services/cart_fs.dart';

import 'buscar_farmacia_model.dart';
export 'buscar_farmacia_model.dart';
// cart_fs.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '/backend/schema/items_record.dart';

class CartFS {
  static CollectionReference<Map<String, dynamic>> _col(String uid) =>
      FirebaseFirestore.instance
          .collection('carts')
          .doc(uid)
          .collection('items');

  // Ver carrito
  static Stream<List<ItemsRecord>> watchItems(String uid) {
    return _col(uid).snapshots().map(
          (s) => s.docs
              .map((d) => ItemsRecord.fromSnapshot(d))
              .toList(),
        );
  }

  // Agregar o incrementar
  static Future<void> addOrIncrementItem({
    required String uid,
    required DocumentReference productRef,
    DocumentReference? skuRef,
    DocumentReference? sucursalRef,
    required String name,
    required String imageUrl,
    required double unitPrice,
    required int qtyToAdd,
    required String currency,
    double? priceBefore,
    required String pharmacySlug,
    required String pharmacyLabel,
    required String pharmacyLogo,
  }) async {
    final col = _col(uid);

    // Buscamos si ya existe el mismo renglón
    final snap = await col
        .where('productRef', isEqualTo: productRef)
        .where('pharmacySlug', isEqualTo: pharmacySlug)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) {
      // No existe → lo creamos con qty inicial = qtyToAdd
      await col.add({
        'productRef': productRef,
        'skuRef': skuRef,
        'sucursalRef': sucursalRef,
        'name': name,
        'imageUrl': imageUrl,
        'unitPrice': unitPrice,
        'qty': qtyToAdd,
        'currency': currency,
        'priceBefore': priceBefore,
        'pharmacySlug': pharmacySlug,
        'pharmacyLabel': pharmacyLabel,
        'pharmacyLogo': pharmacyLogo,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Ya existe → solo incrementamos qty
      final doc = snap.docs.first.reference;
      await doc.update({
        'qty': FieldValue.increment(qtyToAdd),
        'unitPrice': unitPrice, // por si el precio cambió
      });
    }
  }

  // Cambiar cantidad desde Carrito
  static Future<void> increment({
    required String uid,
    required ItemsRecord item,
    required int delta,
  }) async {
    final docRef = _col(uid).doc(item.reference.id);
    await docRef.update({
      'qty': FieldValue.increment(delta),
    });
  }

  // Eliminar renglón
  static Future<void> removeItem({required ItemsRecord item}) async {
    await item.reference.delete();
  }
}

class BuscarFarmaciaWidget extends StatefulWidget {
  const BuscarFarmaciaWidget({
    super.key,
    this.palabras,
  });

  final List<String>? palabras;

  static String routeName = 'buscarFarmacia';
  static String routePath = '/buscarFarmacia';

  @override
  State<BuscarFarmaciaWidget> createState() => _BuscarFarmaciaWidgetState();
}

/// ====== Marcas (colores + logos con fallback Storage para CORS) ======
const _ALLOWED_SLUGS_ORDERED = [
  'farmacorp',
  'farmacias-chavez',
  'farmacia-hipermaxi',
];

const _BRAND = {
  'farmacorp': {
    'label': 'Farmacorp',
    'color': 0xFF0A7CC2,
    'logo':
        'https://farmacorp.com/cdn/shop/files/farmacorp_-_copia_672x180_671x180_671x180_1570e736-2830-4a88-9469-2cffd4cb908e_671x180.webp?v=1659640712',
    'logo_fallback':
        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/route-price-kekvrl/assets/qjqvws9otljb/farma.jpeg',
  },
  'farmacias-chavez': {
    'label': 'Farmacias Chávez',
    'color': 0xFFE53935,
    'logo':
        'https://ecommerce-image-catalog.s3.us-east-1.amazonaws.com/farmacias-chavez/staging/ecommerce/logo.png',
    'logo_fallback':
        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/route-price-kekvrl/assets/4bqpazwlyurx/farmacia-chavez-1080x675.png',
  },
  'farmacia-hipermaxi': {
    'label': 'Hipermaxi',
    'color': 0xFF2E7D32,
    'logo':
        'https://trabajito.com.bo/uploads/0004/4444/2023/05/19/diseno-sin-titulo-4.png',
    'logo_fallback':
        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/route-price-kekvrl/assets/14utkeui7dy9/hiper.jpeg',
  },
};

class _BuscarFarmaciaWidgetState extends State<BuscarFarmaciaWidget> {
  late BuscarFarmaciaModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// Selección actual (por slug) y ref a farmacia:
  String? _selectedSlug; // ej. 'farmacorp'
  DocumentReference? _selectedFarmRef;

  /// Cantidades por producto (key = product.ref.id)
  final Map<String, int> _qtyByProductId = {};

  int _getQty(ProductsRecord p) => _qtyByProductId[p.reference.id] ?? 1;
  void _incQty(ProductsRecord p) {
    final v = _getQty(p);
    setState(() => _qtyByProductId[p.reference.id] = (v + 1).clamp(1, 999));
  }

  void _decQty(ProductsRecord p) {
    final v = _getQty(p);
    setState(() => _qtyByProductId[p.reference.id] = (v - 1).clamp(1, 999));
  }

  /// =============== Carrito (estado local usado ANTES de persistir) =================
  void _addOrIncrementCartItem({
    required ProductsRecord product,
    required int qtyToAdd,
    required double price,
    required String pharmacySlug,
    required String pharmacyLabel,
    required String pharmacyLogo,
  }) {
    final items = FFAppState().cartItems;

    // clave para considerar el mismo renglón en el carrito
    int existingIndex = items.indexWhere((e) {
      final m = e.toMap();
      final sameProd = (e.productRef?.path == product.reference.path);
      final sameSlug = (m['pharmacySlug'] == pharmacySlug);
      final samePrice = (m['price'] == price);
      return sameProd && sameSlug && samePrice;
    });

    if (existingIndex >= 0) {
      final m = items[existingIndex].toMap();
      final current = (m['qty'] is int) ? m['qty'] as int : 1;
      m['qty'] = current + qtyToAdd;
      FFAppState().update(() {
        items[existingIndex] = CartItemStruct.maybeFromMap(m)!;
      });
    } else {
      final map = {
        'productRef': product.reference,
        'productName': product.nombre,
        'productImage': product.imagenUrl,
        'price': price,
        'qty': qtyToAdd,
        'pharmacySlug': pharmacySlug,
        'pharmacyLabel': pharmacyLabel,
        'pharmacyLogo': pharmacyLogo,
      };
      FFAppState().update(() {
        items.add(CartItemStruct.maybeFromMap(map)!);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BuscarFarmaciaModel());
    _model.campoBusqueda8TextController ??=
        TextEditingController(text: _model.textoBuscado);
    _model.campoBusqueda8FocusNode ??= FocusNode();

    _model.buscar = false;
    _model.mostrarEncontrados = false;

    /// Por defecto: Farmacorp
    _selectedSlug = 'farmacorp';

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  bool _productHasFarmacia(ProductsRecord p, DocumentReference farmRef) {
    final ids = p.pharmacyIds; // List<String>
    final farmId = farmRef.id; // id del doc de farmacia
    final slug = _selectedSlug; // p.ej. "farmacorp"
    return ids.contains(farmId) || (slug != null && ids.contains(slug));
  }

  // Filtra por texto y por farmacia seleccionada (usando farmRef si existe)
  List<ProductsRecord> _applyFilters(
    List<ProductsRecord> all,
    DocumentReference? farmRef,
  ) {
    final q =
        _model.campoBusqueda8TextController?.text.trim().toLowerCase() ?? '';
    final hasQuery = q.isNotEmpty;
    final hasFarm = farmRef != null;

    return all.where((p) {
      final okFarm =
          !hasFarm || !p.hasPharmacyIds() || _productHasFarmacia(p, farmRef!);
      final name = (p.nombre ?? '').toLowerCase();
      final okQuery = !hasQuery || name.contains(q);
      return okFarm && okQuery;
    }).toList();
  }

  // Helpers de marca
  String _brandLabel(String slug) =>
      (_BRAND[slug]?['label'] as String?) ?? 'Farmacia';
  String _brandLogo(String slug) =>
      (_BRAND[slug]?['logo_fallback'] as String?) ??
      (_BRAND[slug]?['logo'] as String? ?? '');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductsRecord>>(
      future: queryProductsRecordOnce(
        queryBuilder: (productsRecord) =>
            productsRecord.orderBy('precio_actual'),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F5F5),
            body: Center(
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
        final allProducts = snapshot.data!;

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
                  model: _model.menuLateral5Model,
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
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(11.0, 0.0, 0.0, 0.0),
                  child: Text(
                    'BUSCAR PRODUCTO',
                    style: FlutterFlowTheme.of(context).headlineMedium.override(
                          fontFamily: 'Hind Vadodara',
                          color: Colors.white,
                          fontSize: 22.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
                actions: [
                  IconButton(
                    tooltip: 'Backfill pharmacyIds desde skus',
                    icon: const Icon(Icons.build_circle,
                        color: Color(0xFF1DB954)),
                    onPressed: () async {
                      try {
                        await MaintenanceService.instance
                            .backfillPharmacyIdsFromSkus();
                        await MaintenanceService.instance
                            .logCoverageSample(take: 5);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Backfill completado ✅')),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error en backfill: $e')),
                        );
                      }
                    },
                  ),
                ],
                centerTitle: false,
                elevation: 2.0,
              ),
            ),
            body: SafeArea(
              top: true,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // ===== BUSCADOR =====
                  Align(
                    alignment: const AlignmentDirectional(0.0, 0.0),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 22.0, 0.0, 0.0),
                      child: SizedBox(
                        width: 347.0,
                        child: TextFormField(
                          controller: _model.campoBusqueda8TextController,
                          focusNode: _model.campoBusqueda8FocusNode,
                          onChanged: (_) => EasyDebounce.debounce(
                            '_buscador_live',
                            const Duration(milliseconds: 120),
                            () => setState(() {}),
                          ),
                          onFieldSubmitted: (_) async {
                            _model.buscar = false;
                            _model.mostrarEncontrados = true;
                            safeSetState(() {});
                          },
                          autofocus: false,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Buscar y añadir producto...',
                            hintStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  fontFamily: 'Hind Vadodara',
                                  fontSize: 15.0,
                                  letterSpacing: 0.0,
                                ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFF969696),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.zero,
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFF1DB954),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.zero,
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.zero,
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.zero,
                            ),
                            filled: true,
                            fillColor: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: Color(0xFF969696),
                              size: 22.0,
                            ),
                          ),
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
                                    color: Colors.black,
                                    letterSpacing: 0.0,
                                  ),
                          maxLength: 50,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          buildCounter: (_,
                                  {required currentLength,
                                  required isFocused,
                                  maxLength}) =>
                              null,
                          cursorColor: const Color(0xFF1DB954),
                          enableInteractiveSelection: true,
                          validator: _model
                              .campoBusqueda8TextControllerValidator
                              .asValidator(context),
                        ),
                      ),
                    ),
                  ),

                  // ===== LOGO + DROPDOWN (solo 3 farmacias, por slug) =====
                  Align(
                    alignment: const AlignmentDirectional(1.0, 0.0),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 8.0, 23.0, 0.0),
                      child: StreamBuilder<List<FarmaciasRecord>>(
                        stream: queryFarmaciasRecord(limit: 50),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(),
                            );
                          }

                          final farmsAll = snapshot.data!;

                          // Indexar por slug (lowercase)
                          final Map<String, FarmaciasRecord> bySlug = {
                            for (final f in farmsAll)
                              (f.slug.isNotEmpty ? f.slug.toLowerCase() : ''): f
                          };

                          // Ordenadas y filtradas (solo las 3)
                          final farms = _ALLOWED_SLUGS_ORDERED
                              .where((s) => bySlug.containsKey(s))
                              .map((s) => bySlug[s]!)
                              .toList();

                          // Resolver ref y selección por defecto
                          if (_selectedSlug == null ||
                              !bySlug.containsKey(_selectedSlug)) {
                            _selectedSlug =
                                farms.isNotEmpty ? farms.first.slug : null;
                          }
                          _selectedFarmRef = (_selectedSlug != null)
                              ? bySlug[_selectedSlug!]!.reference
                              : null;

                          // Labels y values del dropdown (guardamos slugs)
                          final options = farms.map((f) => f.slug).toList();
                          final optionLabels = farms.map((f) {
                            final meta = _BRAND[f.slug] ?? {};
                            return (meta['label'] as String?) ??
                                f.nombreComercial;
                          }).toList();

                          // UI: logo + dropdown
                          final meta = (_selectedSlug != null)
                              ? (_BRAND[_selectedSlug!] ?? {})
                              : {};
                          final brandColor =
                              Color((meta['color'] as int?) ?? 0xFF444444);
                          final logoUrl = (meta['logo'] as String?) ?? '';
                          final logoFallback =
                              (meta['logo_fallback'] as String?) ?? '';

                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Badge/logo con fondo del color de marca
                              Container(
                                height: 32,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: brandColor.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: brandColor.withOpacity(0.45)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (logoUrl.isNotEmpty ||
                                        logoFallback.isNotEmpty)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Image.network(
                                          logoUrl.isNotEmpty
                                              ? logoUrl
                                              : logoFallback,
                                          width: 72,
                                          height: 18,
                                          fit: BoxFit.contain,
                                          errorBuilder: (c, e, s) {
                                            // Fallback Storage (evita CORS)
                                            if (logoFallback.isNotEmpty) {
                                              return Image.network(
                                                logoFallback,
                                                width: 72,
                                                height: 18,
                                                fit: BoxFit.contain,
                                              );
                                            }
                                            return Icon(Icons.local_pharmacy,
                                                size: 18, color: brandColor);
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              FlutterFlowDropDown<String>(
                                controller: _model.dropDownValueController ??=
                                    FormFieldController<String>(_selectedSlug),
                                options: options,
                                optionLabels: optionLabels,
                                onChanged: (val) {
                                  safeSetState(() {
                                    _selectedSlug = val;
                                    _selectedFarmRef = (val != null)
                                        ? bySlug[val]?.reference
                                        : null;
                                    _model.dropDownValue = val;
                                    _model.mostrarEncontrados = false;
                                  });
                                },
                                width: 175.0,
                                height: 35.0,
                                maxHeight: 240.0,
                                textStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
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
                                      fontSize: 12.0,
                                    ),
                                hintText: 'FARMACIA',
                                icon: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color:
                                      FlutterFlowTheme.of(context).secondaryText,
                                  size: 19.68,
                                ),
                                fillColor: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                elevation: 2.0,
                                borderColor: const Color(0xFF969696),
                                borderWidth: 0.0,
                                borderRadius: 8.0,
                                margin: const EdgeInsetsDirectional.fromSTEB(
                                    12, 0, 12, 0),
                                hidesUnderline: true,
                                isOverButton: false,
                                isSearchable: false,
                                isMultiSelect: false,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  // ===== LISTADO =====
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          23.0, 16.0, 23.0, 0.0),
                      child: Builder(
                        builder: (context) {
                          final base = _model.mostrarEncontrados
                              ? _model.simpleSearchResults
                              : allProducts;

                          final products = _applyFilters(base, _selectedFarmRef)
                              .take(30)
                              .toList();

                          return GridView.builder(
                            padding: EdgeInsets.zero,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10.0,
                              mainAxisSpacing: 10.0,
                              mainAxisExtent: 290.0,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];

                              return Container(
                                width: 170.0,
                                height: 275.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  boxShadow: const [
                                    BoxShadow(
                                      blurRadius: 2.0,
                                      color: Color(0x00000021),
                                      offset: Offset(1.0, 2.0),
                                    )
                                  ],
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(7)),
                                  border: Border.all(
                                      color: const Color(0xFFD6D6D6)),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // ===== Imagen (SKU -> product -> placeholder) =====
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              8, 8, 8, 0),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                        child: (_selectedFarmRef == null)
                                            ? Image.network(
                                                product.imagenUrl ??
                                                    'https://cdn-icons-png.flaticon.com/512/1988/1988002.png',
                                                width: 149.0,
                                                height: 120.0,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Image.network(
                                                  'https://cdn-icons-png.flaticon.com/512/1988/1988002.png',
                                                  width: 149,
                                                  height: 120,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : StreamBuilder<List<SkusRecord>>(
                                                stream: querySkusRecord(
                                                  parent: product.reference,
                                                  singleRecord: true,
                                                  queryBuilder: (q) => q.where(
                                                    'pharmacyRef',
                                                    isEqualTo: _selectedFarmRef,
                                                  ),
                                                ),
                                                builder: (context, snap) {
                                                  final placeholder =
                                                      'https://cdn-icons-png.flaticon.com/512/1988/1988002.png';
                                                  if (!snap.hasData) {
                                                    return const SizedBox(
                                                      width: 149,
                                                      height: 120,
                                                      child: Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      ),
                                                    );
                                                  }
                                                  final sku =
                                                      snap.data!.isNotEmpty
                                                          ? snap.data!.first
                                                          : null;

                                                  final imgUrl = (sku != null &&
                                                          sku.hasImageUrl() &&
                                                          sku.imageUrl
                                                              .isNotEmpty)
                                                      ? sku.imageUrl
                                                      : (product.imagenUrl
                                                                  ?.isNotEmpty ==
                                                              true
                                                          ? product.imagenUrl!
                                                          : placeholder);

                                                  return Image.network(
                                                    imgUrl,
                                                    width: 149,
                                                    height: 120,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (_, __, ___) =>
                                                            Image.network(
                                                      product.imagenUrl
                                                                  ?.isNotEmpty ==
                                                              true
                                                          ? product.imagenUrl!
                                                          : placeholder,
                                                      width: 149,
                                                      height: 120,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  );
                                                },
                                              ),
                                      ),
                                    ),

                                    // ===== Nombre =====
                                    Align(
                                      alignment: const AlignmentDirectional(
                                          -1.0, -1.0),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(12.0, 6.0, 8.0, 0.0),
                                        child: Text(
                                          product.nombre ?? '',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Hind Vadodara',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                fontSize: 15.0,
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                      ),
                                    ),

                                    // ===== Selector cantidad =====
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              10, 6, 10, 0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                                Icons.remove_circle_outline),
                                            color: const Color(0xFF969696),
                                            iconSize: 22,
                                            onPressed: () => _decQty(product),
                                          ),
                                          Text(
                                            _getQty(product).toString(),
                                            style: FlutterFlowTheme.of(context)
                                                .titleSmall
                                                .override(
                                                  font: GoogleFonts.interTight(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  letterSpacing: 0,
                                                ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.add_circle_outline),
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            iconSize: 22,
                                            onPressed: () => _incQty(product),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // ===== Precio + Badge de farmacia =====
                                    if (_selectedFarmRef != null) ...[
                                      Align(
                                        alignment: const AlignmentDirectional(
                                            -1.0, -1.0),
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(12.0, 2.0, 8.0, 0.0),
                                          child:
                                              StreamBuilder<List<SkusRecord>>(
                                            stream: querySkusRecord(
                                              parent: product.reference,
                                              singleRecord: true,
                                              queryBuilder: (q) => q.where(
                                                'pharmacyRef',
                                                isEqualTo: _selectedFarmRef,
                                              ),
                                            ),
                                            builder: (context, snap) {
                                              if (!snap.hasData) {
                                                return const SizedBox(
                                                  height: 16,
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              }
                                              if (snap.data!.isEmpty) {
                                                return const SizedBox.shrink();
                                              }
                                              final sku = snap.data!.first;

                                              final meta =
                                                  _BRAND[_selectedSlug] ?? {};
                                              final color = Color(
                                                  (meta['color'] as int?) ??
                                                      0xFF444444);
                                              final label =
                                                  (meta['label'] as String?) ??
                                                      'Farmacia';

                                              return Row(
                                                children: [
                                                  Text(
                                                    'Bs. ${sku.price.toString()}',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              'Hind Vadodara',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryText,
                                                          fontSize: 15.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: color
                                                          .withOpacity(0.10),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      border: Border.all(
                                                          color:
                                                              color.withOpacity(
                                                                  0.45)),
                                                    ),
                                                    child: Text(
                                                      label,
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodySmall
                                                          .override(
                                                            fontFamily: 'Inter',
                                                            fontSize: 11,
                                                            color: color,
                                                            letterSpacing: 0,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                    const Spacer(),
                                    // ===== Botón Agregar (persistencia a carts/{uid}/items) =====
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 6.0, 0.0, 8.0),
                                      child: FFButtonWidget(
                                        onPressed: () async {
                                          // Cantidad elegida en la card
                                          final n = _getQty(product);

                                          // Precio, SKU y mejor imagen disponible según farmacia
                                          double priceToUse =
                                              (product.precioActual ?? 0)
                                                  .toDouble();
                                          DocumentReference? skuRefToUse;
                                          String imageUrlToUse =
                                              product.imagenUrl ?? '';

                                          if (_selectedFarmRef != null) {
                                            final skuSnap =
                                                await querySkusRecordOnce(
                                              parent: product.reference,
                                              singleRecord: true,
                                              queryBuilder: (q) => q.where(
                                                'pharmacyRef',
                                                isEqualTo: _selectedFarmRef,
                                              ),
                                            );
                                            if (skuSnap.isNotEmpty) {
                                              final sku = skuSnap.first;
                                              skuRefToUse = sku.reference;
                                              if (sku.hasPrice()) {
                                                priceToUse =
                                                    (sku.price ?? 0).toDouble();
                                              }
                                              if (sku.hasImageUrl() &&
                                                  sku.imageUrl.isNotEmpty) {
                                                imageUrlToUse = sku.imageUrl;
                                              }
                                            }
                                          }

                                          // Metadatos de la farmacia (para agrupar y ver ubicaciones)
                                          final slug = _selectedSlug ?? '';
                                          final label = _brandLabel(slug);
                                          final logo = _brandLogo(slug);

                                          // Persistir en Firestore (CartFS)
                                          await CartFS.addOrIncrementItem(
                                            uid: currentUserUid,
                                            productRef: product.reference,
                                            skuRef: skuRefToUse,
                                            sucursalRef: _selectedFarmRef, // opcional
                                            name: product.nombre ?? '',
                                            imageUrl: imageUrlToUse,
                                            unitPrice: priceToUse,
                                            qtyToAdd: n,
                                            currency: 'Bs',
                                            priceBefore: null,
                                            // Metadatos de farmacia
                                            pharmacySlug: slug,
                                            pharmacyLabel: label,
                                            pharmacyLogo: logo,
                                          );
                                          // Reinicia el selector a 1
                                          setState(() =>
                                              _qtyByProductId[product.reference.id] = 1);

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Agregado: ${product.nombre} x$n',
                                              ),
                                              duration: const Duration(milliseconds: 900),
                                            ),
                                          );
                                        },
                                        text: 'Agregar',
                                        options: FFButtonOptions(
                                          width: 149.0,
                                          height: 27.0,
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(16.0, 0.0, 16.0, 0.0),
                                          color: const Color(0xFF009FE3),
                                          textStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmall
                                                  .override(
                                                    font: GoogleFonts.interTight(
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleSmall
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleSmall
                                                              .fontStyle,
                                                    ),
                                                    color: Colors.white,
                                                    fontSize: 15.0,
                                                    letterSpacing: 0.0,
                                                  ),
                                          elevation: 0.0,
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),

                  // FAB carrito (navega a Carrito y allí ves la lista)
                  Align(
                    alignment: const AlignmentDirectional(0.79, 0.99),
                    child: Container(
                      width: 65.0,
                      height: 65.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        shape: BoxShape.rectangle,
                      ),
                      child: FFButtonWidget(
                        onPressed: () async {
                          context.pushNamed(CarritoWidget.routeName);
                        },
                        text: '',
                        icon:
                            const Icon(Icons.shopping_cart_rounded, size: 45.0),
                        options: FFButtonOptions(
                          padding: const EdgeInsets.all(13.0),
                          iconPadding: const EdgeInsets.all(0.0),
                          color: const Color(0xFF1DB954),
                          textStyle:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                    color: Colors.white,
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                  ),
                          elevation: 0.0,
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                          ),
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                      ),
                    ),
                  ),

                  const Icon(Icons.arrow_back, size: 24.0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
