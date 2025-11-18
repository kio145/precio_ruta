import 'package:cloud_firestore/cloud_firestore.dart';

class MaintenanceService {
  MaintenanceService._();
  static final instance = MaintenanceService._();

  /// Recorre TODOS los skus (collectionGroup) y llena products/{id}.pharmacyIds
  /// No requiere índices porque NO usamos where+orderBy.
  Future<void> backfillPharmacyIdsFromSkus({int batchSize = 400}) async {
    final fs = FirebaseFirestore.instance;

    // 1) Map<productId, Set<pharmacyId>>
    final Map<String, Set<String>> acc = {};

    // Lee en páginas por si tu dataset es grande
    Query q = fs.collectionGroup('skus').limit(3000);
    DocumentSnapshot? lastDoc;

    while (true) {
      if (lastDoc != null) q = q.startAfterDocument(lastDoc);

      final snap = await q.get();
      if (snap.docs.isEmpty) break;

      for (final d in snap.docs) {
        // productId = parent (products/{productId}) de la subcolección
        final parent = d.reference.parent.parent;
        if (parent == null) continue;

        final productId = parent.id;
        final pharmacyRef = d.get('pharmacyRef'); // DocumentReference
        if (pharmacyRef == null) continue;

        final pharmacyId = (pharmacyRef as DocumentReference).id;
        acc.putIfAbsent(productId, () => <String>{}).add(pharmacyId);
      }

      lastDoc = snap.docs.last;
      if (snap.docs.length < 3000) break;
    }

    // 2) Escribe pharmacyIds en products/{id} por lotes
    WriteBatch batch = fs.batch();
    int pending = 0;

    acc.forEach((productId, pharmacySet) {
      final doc = fs.collection('products').doc(productId);
      // prefiero set+merge para no sobreescribir otros campos
      batch.set(doc, {
        'pharmacyIds': pharmacySet.toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      pending++;

      if (pending >= batchSize) {
        batch.commit();
        batch = fs.batch();
        pending = 0;
      }
    });

    if (pending > 0) {
      await batch.commit();
    }
  }

  /// Útil para verificar cobertura tras el backfill
  Future<void> logCoverageSample({int take = 10}) async {
    final fs = FirebaseFirestore.instance;
    final snap = await fs.collection('products').limit(take).get();
    for (final d in snap.docs) {
      final ids = d.data()['pharmacyIds'];
      // ignore: avoid_print
      print('[${d.id}] pharmacyIds=${ids is List ? ids.length : 0} -> $ids');
    }
  }
}
