// /services/cart_fs.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/items_record.dart';
import '/backend/schema/util/firestore_util.dart';

class CartFS {
  CartFS._();
  static final _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> _cartsCol() =>
      _db.collection('carts');

  /// Escucha los items del carrito del usuario (carts/{uid}/items)
  static Stream<List<ItemsRecord>> watchItems(String uid) {
    final parent = _cartsCol().doc(uid);
    return ItemsRecord.collection(parent)
        // .orderBy('createdAt', descending: false) // usa si tienes este campo
        .snapshots()
        .map((qs) => qs.docs
            .map((d) => ItemsRecord.fromSnapshot(d))
            .toList(growable: false));
  }

  /// Incrementa qty de un item existente o crea uno nuevo
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

    // === NUEVOS metadatos de farmacia ===
    String? pharmacySlug,
    String? pharmacyLabel,
    String? pharmacyLogo,
  }) async {
    final cartRef = _cartsCol().doc(uid);
    final itemsCol = cartRef.collection('items');

    // Criterio de unicidad: mismo productRef + mismo pharmacySlug + mismo unitPrice
    // (ajústalo si quieres incluir skuRef o sucursalRef)
    Query<Map<String, dynamic>> q = itemsCol
        .where('productRef', isEqualTo: productRef)
        .where('unitPrice', isEqualTo: unitPrice);

    if (pharmacySlug != null && pharmacySlug.isNotEmpty) {
      q = q.where('pharmacySlug', isEqualTo: pharmacySlug);
    }

    final snap = await q.limit(1).get();

    if (snap.docs.isNotEmpty) {
      // Ya existe: incrementa qty
      final docRef = snap.docs.first.reference;
      await docRef.update({
        'qty': FieldValue.increment(qtyToAdd),
        // Mantén metadatos frescos por si cambiaron
        if (skuRef != null) 'skuRef': skuRef,
        if (sucursalRef != null) 'sucursalRef': sucursalRef,
        if (name.isNotEmpty) 'name': name,
        if (imageUrl.isNotEmpty) 'imageUrl': imageUrl,
        if (currency.isNotEmpty) 'currency': currency,
        if (priceBefore != null) 'priceBefore': priceBefore,
        if (pharmacySlug != null) 'pharmacySlug': pharmacySlug,
        if (pharmacyLabel != null) 'pharmacyLabel': pharmacyLabel,
        if (pharmacyLogo != null) 'pharmacyLogo': pharmacyLogo,
      });
    } else {
      // No existe: crea documento nuevo
      final data = createItemsRecordData(
        productRef: productRef,
        skuRef: skuRef,
        sucursalRef: sucursalRef,
        name: name,
        imageUrl: imageUrl,
        qty: qtyToAdd,
        unitPrice: unitPrice,
        currency: currency,
        priceBefore: priceBefore,
        // Nuevos campos en ItemsRecordData (ya agregados a tu modelo)
        pharmacySlug: pharmacySlug,
        pharmacyLabel: pharmacyLabel,
        pharmacyLogo: pharmacyLogo,
      );

      // Si usas createdAt, agrégalo aquí:
      // data['createdAt'] = FieldValue.serverTimestamp();

      await itemsCol.add(data);
    }
  }

  /// Cambia la cantidad de un item (±delta). Si cae en 0, elimina.
  static Future<void> increment({
    required String uid,
    required ItemsRecord item,
    required int delta,
  }) async {
    final newQty = (item.qty + delta);
    if (newQty <= 0) {
      await removeItem(item: item);
      return;
    }
    await item.reference.update({'qty': newQty});
  }

  /// Elimina un item del carrito
  static Future<void> removeItem({required ItemsRecord item}) async {
    await item.reference.delete();
  }

  /// Vacía el carrito completo
  static Future<void> clearCart(String uid) async {
    final parent = _cartsCol().doc(uid);
    final items = await parent.collection('items').get();
    final batch = _db.batch();
    for (final d in items.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
  }
}
