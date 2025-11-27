// lib/services/ai_cart_service.dart
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '/auth/firebase_auth/auth_util.dart';

class AICartService {
  static const String _endpoint =
      'https://aicartadvice-y4gpkefcia-uc.a.run.app';

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Llama a la Cloud Function `aiCartAdvice` y devuelve:
  /// {
  ///   'message': String,
  ///   'recommendations': List<Map<String,dynamic>>
  /// }
  Future<Map<String, dynamic>> getCartAdviceFromAI({
    double? userLat,
    double? userLng,
  }) async {
    final uid = currentUserUid;

    if (uid.isEmpty) {
      return {
        'message': 'Debes iniciar sesión para obtener recomendaciones.',
        'recommendations': <Map<String, dynamic>>[],
      };
    }

    try {
      // 1) Leer items del carrito desde Firestore
      final cartSnap = await _db
          .collection('carts')
          .doc(uid)
          .collection('items')
          .get();

      if (cartSnap.docs.isEmpty) {
        return {
          'message': 'Tu carrito está vacío.',
          'recommendations': <Map<String, dynamic>>[],
        };
      }

      // 2) Convertir docs -> payload esperado por la Cloud Function
      final itemsPayload = cartSnap.docs.map((doc) {
        final data = doc.data();

        final payloadItem = <String, dynamic>{
          'name': (data['name'] ?? '') as String,
          'qty': (data['qty'] ?? 1) as int,
          'unitPrice': ((data['unitPrice'] ?? 0) as num).toDouble(),
          'pharmacyLabel': (data['pharmacyLabel'] ?? '') as String,
          'pharmacySlug':
              (data['pharmacySlug'] ?? '').toString().trim().toLowerCase(),
          'productPath': (data['productRef'] as DocumentReference?)?.path,
        };

        debugPrint('AI-CART ITEM PAYLOAD => $payloadItem');
        return payloadItem;
      }).toList();

      // 3) Body para la petición
      final Map<String, dynamic> body = {
        'items': itemsPayload,
      };

      if (userLat != null && userLng != null) {
        body['userLat'] = userLat;
        body['userLng'] = userLng;
      }

      final bodyJson = jsonEncode(body);
      debugPrint('AI-CART REQUEST BODY => $bodyJson');

      // 4) Headers
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      // ID token de Firebase para Authorization: Bearer ...
      try {
        final user = FirebaseAuth.instance.currentUser;
        final token = await user?.getIdToken();
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        }
      } catch (e) {
        debugPrint('No se pudo obtener ID token de Firebase: $e');
      }

      // 5) Llamar a la Cloud Function
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: headers,
        body: bodyJson,
      );

      debugPrint(
        'AI-CART RESPONSE STATUS => ${response.statusCode}, BODY => ${response.body}',
      );

      if (response.statusCode != 200) {
        return {
          'message':
              'No se pudo obtener una recomendación en este momento (error ${response.statusCode}).',
          'recommendations': <Map<String, dynamic>>[],
        };
      }

      Map<String, dynamic> decoded;
      try {
        decoded = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('Error al parsear respuesta de aiCartAdvice: $e');
        return {
          'message': 'No se pudo interpretar la respuesta de la recomendación.',
          'recommendations': <Map<String, dynamic>>[],
        };
      }

      final msg = (decoded['message'] as String?)?.trim() ?? '';
      final recs =
          (decoded['recommendations'] as List? ?? []).cast<Map<String, dynamic>>();

      return {
        'message': msg.isEmpty
            ? 'No se recibió mensaje de recomendación del servidor.'
            : msg,
        'recommendations': recs,
      };
    } catch (e, st) {
      debugPrint('aiCartAdvice exception: $e\n$st');
      return {
        'message': 'Ocurrió un error al consultar las recomendaciones.',
        'recommendations': <Map<String, dynamic>>[],
      };
    }
  }

  /// Aplica las recomendaciones al carrito:
  /// - Cambia farmacia (label, slug, ref)
  /// - Cambia precio unitario
  /// - Actualiza el logo de la farmacia (pharmacyLogo)
  /// - 👇 NUEVO: actualiza también sucursalRef para que RutaWidget use la farmacia correcta
  Future<void> applyRecommendationsToCart(
    List<Map<String, dynamic>> recommendations,
  ) async {
    final uid = currentUserUid;
    if (uid.isEmpty) return;
    if (recommendations.isEmpty) return;

    final cartItemsRef =
        _db.collection('carts').doc(uid).collection('items');

    final batch = _db.batch();

    for (final rec in recommendations) {
      final productPath = rec['productPath'] as String?;
      if (productPath == null || productPath.isEmpty) {
        debugPrint('AI-CART: recomendación sin productPath, se omite: $rec');
        continue;
      }

      // Buscar el item del carrito por productRef
      final productRef = _db.doc(productPath);
      final qSnap = await cartItemsRef
          .where('productRef', isEqualTo: productRef)
          .limit(1)
          .get();

      if (qSnap.docs.isEmpty) {
        debugPrint(
            'AI-CART: no se encontró item en carrito para productPath=$productPath');
        continue;
      }

      final docRef = qSnap.docs.first.reference;

      final bestPharmacyPath = rec['bestPharmacyPath'] as String? ?? '';
      DocumentReference? bestPharmacyRef;
      String? bestPharmacyLogo;
      DocumentReference? newSucursalRef; // 👈 NUEVO

      // Si la IA recomienda una farmacia específica, buscamos su doc y una sucursal
      if (bestPharmacyPath.isNotEmpty) {
        bestPharmacyRef = _db.doc(bestPharmacyPath);

        // 1) Logo de la farmacia
        try {
          final snapFarmacia = await bestPharmacyRef.get();
          final dataFarmacia = snapFarmacia.data() as Map<String, dynamic>?;
          if (dataFarmacia != null) {
            bestPharmacyLogo = (dataFarmacia['logo'] ??
                    dataFarmacia['logoUrl'] ??
                    dataFarmacia['logo_url'] ??
                    '') as String?;
          }
        } catch (e) {
          debugPrint('AI-CART: error leyendo farmacia $bestPharmacyPath => $e');
        }

        // 2) 👈 NUEVO: buscar una sucursal de esa farmacia
        try {
          final sucSnap = await _db
              .collection('sucursales')
              .where('farmaciaRef', isEqualTo: bestPharmacyRef)
              .limit(1)
              .get();

          if (sucSnap.docs.isNotEmpty) {
            newSucursalRef = sucSnap.docs.first.reference;
          } else {
            debugPrint(
                'AI-CART: no se encontró sucursal para farmacia $bestPharmacyPath');
          }
        } catch (e) {
          debugPrint(
              'AI-CART: error buscando sucursal para farmacia $bestPharmacyPath => $e');
        }
      }

      final newUnitPrice =
          (rec['bestUnitPrice'] as num?)?.toDouble();
      final bestPharmacyName = rec['bestPharmacyName'] as String?;
      final bestPharmacySlug = rec['bestPharmacySlug'] as String?;

      final updateData = <String, dynamic>{
        if (newUnitPrice != null) 'unitPrice': newUnitPrice,
        if (bestPharmacyName != null) 'pharmacyLabel': bestPharmacyName,
        if (bestPharmacySlug != null) 'pharmacySlug': bestPharmacySlug,
        if (bestPharmacyRef != null) 'pharmacyRef': bestPharmacyRef,
        if (bestPharmacyLogo != null && bestPharmacyLogo!.isNotEmpty)
          'pharmacyLogo': bestPharmacyLogo,
        if (newSucursalRef != null) 'sucursalRef': newSucursalRef, // 👈 clave para el mapa
      };

      if (updateData.isEmpty) {
        debugPrint('AI-CART: nada que actualizar para productPath=$productPath');
        continue;
      }

      debugPrint('AI-CART: aplicando update => $updateData');
      batch.update(docRef, updateData);
    }

    await batch.commit();
    debugPrint(
        'AI-CART: recomendaciones aplicadas al carrito (incluyendo sucursalRef).');
  }
}
