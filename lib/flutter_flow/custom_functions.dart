import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';
import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/backend/schema/structs/index.dart';
import '/auth/firebase_auth/auth_util.dart';

List<FarmaciaGroupStruct> groupByFarmacia(List<CartItemStruct> cartItems) {
  Map<String, Map<String, dynamic>> farmaciasMap = {};

  for (var item in cartItems) {
    String farmaciaId = item.farmaciaRef!.id;

    if (!farmaciasMap.containsKey(farmaciaId)) {
      farmaciasMap[farmaciaId] = {
        'farmaciaRef': item.farmaciaRef,
        'farmaciaName': item.farmaciaName,
        'farmaciaLogo': item.farmaciaLogo,
        'products': <CartItemStruct>[],
        'total': 0.0
      };
    }

    farmaciasMap[farmaciaId]!['products'].add(item);
    farmaciasMap[farmaciaId]!['total'] += (item.price * item.quantity);
  }

  // Convertir el mapa a una lista de FarmaciaGroupStruct
  return farmaciasMap.values.map((farmaciaData) {
    return FarmaciaGroupStruct(
      farmaciaRef: farmaciaData['farmaciaRef'] as DocumentReference,
      farmaciaName: farmaciaData['farmaciaName'] as String,
      farmaciaLogo: farmaciaData['farmaciaLogo'] as String,
      products: farmaciaData['products'] as List<CartItemStruct>,
      total: farmaciaData['total'] as double,
    );
  }).toList();
}
