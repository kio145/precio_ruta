// lib/services/sku_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class SkuService {
  SkuService._();
  static final instance = SkuService._();
  final _db = FirebaseFirestore.instance;

  /// Normaliza un valor que podría venir como id, path o DocRef.
  DocumentReference _toRef(String collection, dynamic v) {
    if (v is DocumentReference) return v;
    if (v is String && v.isNotEmpty) {
      final path = v.contains('/') ? v.replaceFirst(RegExp(r'^/'), '') : '$collection/$v';
      return _db.doc(path);
    }
    throw ArgumentError('Valor inválido para $collection: $v');
  }

  Future<void> createOrUpdateSku({
    required String productId,
    required String pharmacyId,
    required double price,
  }) async {
    final productRef  = _db.collection('products').doc(productId);
    final pharmacyRef = _db.collection('farmacias').doc(pharmacyId);

    await productRef.collection('skus').add({
      'pharmacyRef': pharmacyRef,               // ✅ DocRef
      'productId': productRef,                  // ✅ DocRef
      'price': price,
      'currency': 'Bs',
      'capturedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // En SkuService (mismo archivo)
Future<void> migrateSkusStringToDocRef() async {
  final snap = await _db.collectionGroup('skus').get();

  WriteBatch batch = _db.batch();
  int n = 0;

  for (final d in snap.docs) {
    final data = d.data();
    bool needsUpdate = false;
    final updates = <String, dynamic>{};

    // pharmacyRef: puede ser '/farmacias/ID', 'farmacias/ID' o solo 'ID'
    final ph = data['pharmacyRef'];
    if (ph is String && ph.isNotEmpty) {
      final path = ph.contains('/') ? ph.replaceFirst(RegExp(r'^/'), '') : 'farmacias/$ph';
      updates['pharmacyRef'] = _db.doc(path);
      needsUpdate = true;
    }

    // productId: algunos quedaron como string
    final pid = data['productId'];
    if (pid is String && pid.isNotEmpty) {
      final path = pid.contains('/') ? pid.replaceFirst(RegExp(r'^/'), '') : 'products/$pid';
      updates['productId'] = _db.doc(path);
      needsUpdate = true;
    }

    if (needsUpdate) {
      batch.update(d.reference, updates);
      if (++n % 400 == 0) {
        await batch.commit();
        batch = _db.batch();
      }
    }
  }
  if (n % 400 != 0) await batch.commit();
}
Future<void> backfillProductPharmacyIds() async {
  final prods = await FirebaseFirestore.instance.collection('products').get();

  final batch = FirebaseFirestore.instance.batch();
  int ops = 0;

  for (final p in prods.docs) {
    final skus = await p.reference.collection('skus').get();
    final ids = <String>{};
    for (final s in skus.docs) {
      final ref = s.data()['pharmacyRef'];
      if (ref is DocumentReference) ids.add(ref.id);
    }
    batch.update(p.reference, {'pharmacyIds': ids.toList()});
    ops++;
    if (ops % 400 == 0) {
      await batch.commit();
    }
  }
  await batch.commit();
}

}


