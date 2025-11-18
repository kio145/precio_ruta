import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SkusRecord extends FirestoreRecord {
  SkusRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "pharmacyRef" field.
  DocumentReference? _pharmacyRef;
  DocumentReference? get pharmacyRef => _pharmacyRef;
  bool hasPharmacyRef() => _pharmacyRef != null;

  // "price" field.
  double? _price;
  double get price => _price ?? 0.0;
  bool hasPrice() => _price != null;

  // "price_before" field.
  double? _priceBefore;
  double get priceBefore => _priceBefore ?? 0.0;
  bool hasPriceBefore() => _priceBefore != null;

  // "has_discount" field.
  bool? _hasDiscount;
  bool get hasDiscount => _hasDiscount ?? false;
  bool hasHasDiscount() => _hasDiscount != null;

  // "ahorro_texto" field.
  String? _ahorroTexto;
  String get ahorroTexto => _ahorroTexto ?? '';
  bool hasAhorroTexto() => _ahorroTexto != null;

  // "ahorro_pct" field.
  double? _ahorroPct;
  double get ahorroPct => _ahorroPct ?? 0.0;
  bool hasAhorroPct() => _ahorroPct != null;

  // "imagen_url" field.
  String? _imageUrl;
  String get imageUrl => _imageUrl ?? '';
  bool hasImageUrl() => _imageUrl != null;

  // "currency" field.
  String? _currency;
  String get currency => _currency ?? '';
  bool hasCurrency() => _currency != null;

  // "capturedAt" field.
  DateTime? _capturedAt;
  DateTime? get capturedAt => _capturedAt;
  bool hasCapturedAt() => _capturedAt != null;

  // "updatedAt" field.
  DateTime? _updatedAt;
  DateTime? get updatedAt => _updatedAt;
  bool hasUpdatedAt() => _updatedAt != null;

  // "productId" field.
  DocumentReference? _productId;
  DocumentReference? get productId => _productId;
  bool hasProductId() => _productId != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _pharmacyRef = snapshotData['pharmacyRef'] as DocumentReference?;
    _price = castToType<double>(snapshotData['price']);
    _priceBefore = castToType<double>(snapshotData['price_before']);
    _hasDiscount = snapshotData['has_discount'] as bool?;
    _ahorroTexto = snapshotData['ahorro_texto'] as String?;
    _ahorroPct = castToType<double>(snapshotData['ahorro_pct']);
    _imageUrl = snapshotData['imagen_url'] as String?;
    _currency = snapshotData['currency'] as String?;
    _capturedAt = snapshotData['capturedAt'] as DateTime?;
    _updatedAt = snapshotData['updatedAt'] as DateTime?;
    _productId = snapshotData['productId'] as DocumentReference?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('skus')
          : FirebaseFirestore.instance.collectionGroup('skus');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('skus').doc(id);

  static Stream<SkusRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => SkusRecord.fromSnapshot(s));

  static Future<SkusRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => SkusRecord.fromSnapshot(s));

  static SkusRecord fromSnapshot(DocumentSnapshot snapshot) => SkusRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static SkusRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      SkusRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'SkusRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is SkusRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createSkusRecordData({
  DocumentReference? pharmacyRef,
  double? price,
  double? priceBefore,
  bool? hasDiscount,
  String? ahorroTexto,
  double? ahorroPct,
  String? imageUrl,
  String? currency,
  DateTime? capturedAt,
  DateTime? updatedAt,
  DocumentReference? productId,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'pharmacyRef': pharmacyRef,
      'price': price,
      'price_before': priceBefore,
      'has_discount': hasDiscount,
      'ahorro_texto': ahorroTexto,
      'ahorro_pct': ahorroPct,
      'imagen_url': imageUrl,
      'currency': currency,
      'capturedAt': capturedAt,
      'updatedAt': updatedAt,
      'productId': productId,
    }.withoutNulls,
  );

  return firestoreData;
}

class SkusRecordDocumentEquality implements Equality<SkusRecord> {
  const SkusRecordDocumentEquality();

  @override
  bool equals(SkusRecord? e1, SkusRecord? e2) {
    return e1?.pharmacyRef == e2?.pharmacyRef &&
        e1?.price == e2?.price &&
        e1?.priceBefore == e2?.priceBefore &&
        e1?.hasDiscount == e2?.hasDiscount &&
        e1?.ahorroTexto == e2?.ahorroTexto &&
        e1?.ahorroPct == e2?.ahorroPct &&
        e1?.imageUrl == e2?.imageUrl &&
        e1?.currency == e2?.currency &&
        e1?.capturedAt == e2?.capturedAt &&
        e1?.updatedAt == e2?.updatedAt &&
        e1?.productId == e2?.productId;
  }

  @override
  int hash(SkusRecord? e) => const ListEquality().hash([
        e?.pharmacyRef,
        e?.price,
        e?.priceBefore,
        e?.hasDiscount,
        e?.ahorroTexto,
        e?.ahorroPct,
        e?.imageUrl,
        e?.currency,
        e?.capturedAt,
        e?.updatedAt,
        e?.productId
      ]);

  @override
  bool isValidKey(Object? o) => o is SkusRecord;
}
