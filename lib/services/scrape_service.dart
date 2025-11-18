// lib/services/scrape_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_functions/firebase_functions.dart';

class ScrapeService {
  final _db = FirebaseFirestore.instance;
  final _func = FirebaseFunctions.instance;

  /// Crea uno o varios jobs para Farmacorp.
  Future<List<String>> createFarmacorpJobs({
    required List<Map<String, dynamic>> items,
  }) async {
    // items: [{productId, url, sucursalId?}, ...]
    final callable = _func.httpsCallable('requestFarmacorpScrape');
    final resp = await callable.call({'items': items});
    final List<dynamic> ids = resp.data['jobIds'] ?? [];
    return ids.map((e) => e.toString()).toList();
  }

  /// Escucha un job hasta terminar (done/error) y devuelve el snapshot final.
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchJob(String jobId) {
    return _db.collection('scrape_jobs').doc(jobId).snapshots();
  }
}
