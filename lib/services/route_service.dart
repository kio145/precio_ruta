// lib/services/route_service.dart

import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import '../flutter_flow/flutter_flow_util.dart';

import '../backend/backend.dart';
import '../backend/schema/sucursales_record.dart';
import '../backend/schema/farmacias_record.dart';
import '../backend/schema/stock_record.dart';
import '../backend/schema/items_record.dart';

/// Pesos del score (puedes luego leerlos de una colección configs/route_scoring)
const double kAlphaPrecio = 0.5;  // importancia del precio
const double kBetaDistancia = 0.3; // importancia de la distancia
const double kGammaReputacion = 0.2; // importancia de la reputación

/// Modelo simple para representar una opción de ruta/sucursal
class RouteOption {
  final SucursalesRecord sucursal;
  final FarmaciasRecord farmacia;
  final double precioTotal;
  final double distanciaKm;
  final double reputacion;
  final double score;
  final bool stockDisponible; // para TODO el carrito
  final List<String> badges;  // ["mas_barata", "mas_cercana", "mejor_score"]

  RouteOption({
    required this.sucursal,
    required this.farmacia,
    required this.precioTotal,
    required this.distanciaKm,
    required this.reputacion,
    required this.score,
    required this.stockDisponible,
    required this.badges,
  });
}

/// Función pública principal: obtener lista de sucursales recomendadas
Future<List<RouteOption>> getBestRouteOptionsForCart({
  required List<ItemsRecord> cartItems,
  required LatLng userLocation,
}) async {
  if (cartItems.isEmpty) {
    return [];
  }

  // 1) Traer todas las sucursales (luego puedes filtrar por ciudad/zona)
  final sucursales = await querySucursalesRecordOnce();

  // 2) Traer todas las farmacias para poder cruzar reputación, logo, etc.
  final farmacias = await queryFarmaciasRecordOnce();
  final farmaciasByRef = {
    for (final f in farmacias) f.reference.path: f,
  };

  final List<_RawOption> rawOptions = [];

  // 3) Evaluar cada sucursal
  for (final suc in sucursales) {
    // Debe tener ubicación válida
    if (suc.ubicacion == null) continue;

    final farmaciaRefPath = suc.farmaciaRef?.path;
    if (farmaciaRefPath == null) continue;

    final farmacia = farmaciasByRef[farmaciaRefPath];
    if (farmacia == null) continue;

    final double distanciaKm =
        _distanceInKm(userLocation, suc.ubicacion!);

    double precioTotal = 0;
    bool sucursalTieneTodoStock = true;

    // 3.a) Verificar stock para cada item del carrito
    for (final item in cartItems) {
      // Asumo que en ItemsRecord hay un campo productRef o similar
      final productRef = item.productRef;
      if (productRef == null) {
        sucursalTieneTodoStock = false;
        break;
      }

      // Buscar un doc de stock para ese producto + sucursal
      final stockList = await queryStockRecordOnce(
        parent: productRef,
        queryBuilder: (q) => q
            .where('branchRef', isEqualTo: suc.reference)
            // Usa UNO de estos dos campos según cómo lo tengas:
            // .where('raw_disponibilidad', isEqualTo: true)
            .where('stock_disponible', isEqualTo: true),
        limit: 1,
        singleRecord: true,
      );

      if (stockList.isEmpty) {
        // No hay stock de ese producto en esta sucursal
        sucursalTieneTodoStock = false;
        break;
      }

      // 3.b) Calcular precio del item (ajusta al campo correcto)
      final int cantidad = item.cantidad ?? 1;
      final double precioUnitario =
          (item.precioUnitario ?? item.precio ?? 0).toDouble();

      precioTotal += precioUnitario * cantidad;
    }

    if (!sucursalTieneTodoStock) {
      continue; // descartamos esta sucursal
    }

    // 3.c) Reputación: por ahora, si no tienes un campo, fija un valor por defecto
    final double reputacion = (farmacia.reputacion ?? 4.0).toDouble();

    rawOptions.add(
      _RawOption(
        sucursal: suc,
        farmacia: farmacia,
        precioTotal: precioTotal,
        distanciaKm: distanciaKm,
        reputacion: reputacion,
      ),
    );
  }

  if (rawOptions.isEmpty) {
    return [];
  }

  // 4) Normalizar y calcular score
  final precios = rawOptions.map((o) => o.precioTotal).toList();
  final distancias = rawOptions.map((o) => o.distanciaKm).toList();
  final reputaciones = rawOptions.map((o) => o.reputacion).toList();

  final minPrecio = precios.reduce(math.min);
  final maxPrecio = precios.reduce(math.max);
  final minDist = distancias.reduce(math.min);
  final maxDist = distancias.reduce(math.max);
  final minRep = reputaciones.reduce(math.min);
  final maxRep = reputaciones.reduce(math.max);

  double _norm(double value, double minV, double maxV) {
    if (maxV - minV == 0) return 1.0; // todos iguales → valor neutro
    return (value - minV) / (maxV - minV);
  }

  final List<RouteOption> options = [];

  for (final raw in rawOptions) {
    final precioNorm = _norm(raw.precioTotal, minPrecio, maxPrecio);
    final distanciaNorm = _norm(raw.distanciaKm, minDist, maxDist);
    final reputacionNorm = _norm(raw.reputacion, minRep, maxRep);

    // Invertimos precio y distancia: más barato / más cerca = mejor
    final precioScore = 1.0 - precioNorm;
    final distanciaScore = 1.0 - distanciaNorm;
    final reputacionScore = reputacionNorm;

    final double score =
        kAlphaPrecio * precioScore +
        kBetaDistancia * distanciaScore +
        kGammaReputacion * reputacionScore;

    options.add(
      RouteOption(
        sucursal: raw.sucursal,
        farmacia: raw.farmacia,
        precioTotal: raw.precioTotal,
        distanciaKm: raw.distanciaKm,
        reputacion: raw.reputacion,
        score: score,
        stockDisponible: true,
        badges: [], // las llenamos abajo
      ),
    );
  }

  // 5) Calcular badges
  if (options.isNotEmpty) {
    // Más barata
    options.sort((a, b) => a.precioTotal.compareTo(b.precioTotal));
    final masBarata = options.first;
    masBarata.badges.add('mas_barata');

    // Más cercana
    options.sort((a, b) => a.distanciaKm.compareTo(b.distanciaKm));
    final masCercana = options.first;
    masCercana.badges.add('mas_cercana');

    // Mejor score
    options.sort((a, b) => b.score.compareTo(a.score));
    final mejorScore = options.first;
    mejorScore.badges.add('mejor_score');

    // Finalmente, devolvemos ordenadas por score descendente
    options.sort((a, b) => b.score.compareTo(a.score));
  }

  return options;
}

/// Estructura interna para cálculos
class _RawOption {
  final SucursalesRecord sucursal;
  final FarmaciasRecord farmacia;
  final double precioTotal;
  final double distanciaKm;
  final double reputacion;

  _RawOption({
    required this.sucursal,
    required this.farmacia,
    required this.precioTotal,
    required this.distanciaKm,
    required this.reputacion,
  });
}

/// Distancia en km entre dos LatLng usando Haversine
double _distanceInKm(LatLng a, LatLng b) {
  const double R = 6371; // radio Tierra en km
  final double dLat = _deg2rad(b.latitude - a.latitude);
  final double dLon = _deg2rad(b.longitude - a.longitude);
  final double lat1 = _deg2rad(a.latitude);
  final double lat2 = _deg2rad(b.latitude);

  final double h = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.sin(dLon / 2) * math.sin(dLon / 2) * math.cos(lat1) * math.cos(lat2);

  final double c = 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
  return R * c;
}

double _deg2rad(double deg) => deg * (math.pi / 180.0);

