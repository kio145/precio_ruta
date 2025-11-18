import 'dart:async';

import 'package:collection/collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ItemsRecord extends FirestoreRecord {
  ItemsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "productRef" field.
  DocumentReference? _productRef;
  DocumentReference? get productRef => _productRef;
  bool hasProductRef() => _productRef != null;

  // "skuRef" field.
  DocumentReference? _skuRef;
  DocumentReference? get skuRef => _skuRef;
  bool hasSkuRef() => _skuRef != null;

  // "sucursalRef" field.
  DocumentReference? _sucursalRef;
  DocumentReference? get sucursalRef => _sucursalRef;
  bool hasSucursalRef() => _sucursalRef != null;

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "imageUrl" field.
  String? _imageUrl;
  String get imageUrl => _imageUrl ?? '';
  bool hasImageUrl() => _imageUrl != null;

  // "qty" field.
  int? _qty;
  int get qty => _qty ?? 0;
  bool hasQty() => _qty != null;

  // "unitPrice" field.
  double? _unitPrice;
  double get unitPrice => _unitPrice ?? 0.0;
  bool hasUnitPrice() => _unitPrice != null;

  // "currency" field.
  String? _currency;
  String get currency => _currency ?? '';
  bool hasCurrency() => _currency != null;

  // "priceBefore" field.
  double? _priceBefore;
  double get priceBefore => _priceBefore ?? 0.0;
  bool hasPriceBefore() => _priceBefore != null;

  // ====== NUEVOS CAMPOS: metadatos de farmacia ======
  String? _pharmacySlug;
  String get pharmacySlug => _pharmacySlug ?? '';
  bool hasPharmacySlug() => _pharmacySlug != null;

  String? _pharmacyLabel;
  String get pharmacyLabel => _pharmacyLabel ?? '';
  bool hasPharmacyLabel() => _pharmacyLabel != null;

  String? _pharmacyLogo;
  String get pharmacyLogo => _pharmacyLogo ?? '';
  bool hasPharmacyLogo() => _pharmacyLogo != null;

  // Parent carts/{uid}
  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _productRef = snapshotData['productRef'] as DocumentReference?;
    _skuRef = snapshotData['skuRef'] as DocumentReference?;
    _sucursalRef = snapshotData['sucursalRef'] as DocumentReference?;
    _name = snapshotData['name'] as String?;
    _imageUrl = snapshotData['imageUrl'] as String?;
    _qty = castToType<int>(snapshotData['qty']);
    _unitPrice = castToType<double>(snapshotData['unitPrice']);
    _currency = snapshotData['currency'] as String?;
    _priceBefore = castToType<double>(snapshotData['priceBefore']);

    // NUEVOS
    _pharmacySlug = snapshotData['pharmacySlug'] as String?;
    _pharmacyLabel = snapshotData['pharmacyLabel'] as String?;
    _pharmacyLogo = snapshotData['pharmacyLogo'] as String?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('items')
          : FirebaseFirestore.instance.collectionGroup('items');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('items').doc(id);

  static Stream<ItemsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ItemsRecord.fromSnapshot(s));

  static Future<ItemsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ItemsRecord.fromSnapshot(s));

  static ItemsRecord fromSnapshot(DocumentSnapshot snapshot) => ItemsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ItemsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ItemsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ItemsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ItemsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createItemsRecordData({
  DocumentReference? productRef,
  DocumentReference? skuRef,
  DocumentReference? sucursalRef,
  String? name,
  String? imageUrl,
  int? qty,
  double? unitPrice,
  String? currency,
  double? priceBefore,
  // NUEVOS:
  String? pharmacySlug,
  String? pharmacyLabel,
  String? pharmacyLogo,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'productRef': productRef,
      'skuRef': skuRef,
      'sucursalRef': sucursalRef,
      'name': name,
      'imageUrl': imageUrl,
      'qty': qty,
      'unitPrice': unitPrice,
      'currency': currency,
      'priceBefore': priceBefore,
      // NUEVOS:
      'pharmacySlug': pharmacySlug,
      'pharmacyLabel': pharmacyLabel,
      'pharmacyLogo': pharmacyLogo,
    }.withoutNulls,
  );

  return firestoreData;
}

class ItemsRecordDocumentEquality implements Equality<ItemsRecord> {
  const ItemsRecordDocumentEquality();

  @override
  bool equals(ItemsRecord? e1, ItemsRecord? e2) {
    return e1?.productRef == e2?.productRef &&
        e1?.skuRef == e2?.skuRef &&
        e1?.sucursalRef == e2?.sucursalRef &&
        e1?.name == e2?.name &&
        e1?.imageUrl == e2?.imageUrl &&
        e1?.qty == e2?.qty &&
        e1?.unitPrice == e2?.unitPrice &&
        e1?.currency == e2?.currency &&
        e1?.priceBefore == e2?.priceBefore &&
        // NUEVOS:
        e1?.pharmacySlug == e2?.pharmacySlug &&
        e1?.pharmacyLabel == e2?.pharmacyLabel &&
        e1?.pharmacyLogo == e2?.pharmacyLogo;
  }

  @override
  int hash(ItemsRecord? e) => const ListEquality().hash([
        e?.productRef,
        e?.skuRef,
        e?.sucursalRef,
        e?.name,
        e?.imageUrl,
        e?.qty,
        e?.unitPrice,
        e?.currency,
        e?.priceBefore,
        // NUEVOS:
        e?.pharmacySlug,
        e?.pharmacyLabel,
        e?.pharmacyLogo,
      ]);

  @override
  bool isValidKey(Object? o) => o is ItemsRecord;
}
