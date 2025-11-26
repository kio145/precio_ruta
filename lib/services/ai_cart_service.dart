// lib/services/ai_cart_service.dart
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '/auth/firebase_auth/auth_util.dart';
import '/backend/schema/items_record.dart';

class AICartService {
  // 👉 URL de tu Cloud Run / Cloud Function
  static const String _endpoint =
      'https://aicartadvice-y4gpkefcia-uc.a.run.app';

  /// Llama a la Cloud Function `aiCartAdvice` y devuelve el texto `message`.
  Future<String> getCartAdviceFromAI({
    double? userLat,
    double? userLng,
  }) async {
    final uid = currentUserUid;

    if (uid.isEmpty) {
      return 'Debes iniciar sesión para obtener recomendaciones.';
    }

    try {
      // 1) Leer items del carrito desde Firestore
      final cartSnap = await FirebaseFirestore.instance
          .collection('carts')
          .doc(uid)
          .collection('items')
          .get();

      if (cartSnap.docs.isEmpty) {
        return 'Tu carrito está vacío.';
      }

      // 2) Convertir ItemsRecord -> payload esperado por la Cloud Function
      final itemsPayload = cartSnap.docs.map((doc) {
        final item = ItemsRecord.fromSnapshot(doc);

        final payloadItem = <String, dynamic>{
          'name': item.name ?? '',
          'qty': item.qty ?? 1,
          'unitPrice': (item.unitPrice ?? 0).toDouble(),
          'pharmacyLabel': item.pharmacyLabel ?? '',
          // normalizamos el slug antes de enviarlo
          'pharmacySlug':
              (item.pharmacySlug ?? '').toString().trim().toLowerCase(),
          // MUY IMPORTANTE: que en ItemsRecord tengas este campo seteado al agregar al carrito
          'productPath': item.productRef?.path,
        };

        debugPrint('AI-CART ITEM PAYLOAD => $payloadItem');
        return payloadItem;
      }).toList();

      // 3) Body para la petición
      final Map<String, dynamic> body = {
        'items': itemsPayload,
      };

      // Ubicación opcional (si la tienes)
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
        // La función igual puede funcionar sin token
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
        return 'No se pudo obtener una recomendación en este momento (error ${response.statusCode}).';
      }

      Map<String, dynamic> decoded;
      try {
        decoded = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('Error al parsear respuesta de aiCartAdvice: $e');
        return 'No se pudo interpretar la respuesta de la recomendación.';
      }

      final msg = decoded['message'] as String?;
      if (msg != null && msg.trim().isNotEmpty) {
        return msg.trim();
      }

      return 'No se recibió mensaje de recomendación del servidor.';
    } catch (e, st) {
      debugPrint('aiCartAdvice exception: $e\n$st');
      return 'Ocurrió un error al consultar las recomendaciones.';
    }
  }
}
