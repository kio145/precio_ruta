import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class StockRecord extends FirestoreRecord {
  StockRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "branchId" field.
  String? _branchId;
  String get branchId => _branchId ?? '';
  bool hasBranchId() => _branchId != null;

  // "branchRef" field.
  DocumentReference? _branchRef;
  DocumentReference? get branchRef => _branchRef;
  bool hasBranchRef() => _branchRef != null;

  // "disponibilidad" field.
  String? _disponibilidad;
  String get disponibilidad => _disponibilidad ?? '';
  bool hasDisponibilidad() => _disponibilidad != null;

  // "raw_disponibilidad" field.
  String? _rawDisponibilidad;
  String get rawDisponibilidad => _rawDisponibilidad ?? '';
  bool hasRawDisponibilidad() => _rawDisponibilidad != null;

  // "capturedAt" field.
  DateTime? _capturedAt;
  DateTime? get capturedAt => _capturedAt;
  bool hasCapturedAt() => _capturedAt != null;

  // "updatedAt" field.
  DateTime? _updatedAt;
  DateTime? get updatedAt => _updatedAt;
  bool hasUpdatedAt() => _updatedAt != null;

  // "pharmacyId" field.
  DocumentReference? _pharmacyId;
  DocumentReference? get pharmacyId => _pharmacyId;
  bool hasPharmacyId() => _pharmacyId != null;

  // "productId" field.
  DocumentReference? _productId;
  DocumentReference? get productId => _productId;
  bool hasProductId() => _productId != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _branchId = snapshotData['branchId'] as String?;
    _branchRef = snapshotData['branchRef'] as DocumentReference?;
    _disponibilidad = snapshotData['disponibilidad'] as String?;
    _rawDisponibilidad = snapshotData['raw_disponibilidad'] as String?;
    _capturedAt = snapshotData['capturedAt'] as DateTime?;
    _updatedAt = snapshotData['updatedAt'] as DateTime?;
    _pharmacyId = snapshotData['pharmacyId'] as DocumentReference?;
    _productId = snapshotData['productId'] as DocumentReference?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('stock')
          : FirebaseFirestore.instance.collectionGroup('stock');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('stock').doc(id);

  static Stream<StockRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => StockRecord.fromSnapshot(s));

  static Future<StockRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => StockRecord.fromSnapshot(s));

  static StockRecord fromSnapshot(DocumentSnapshot snapshot) => StockRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static StockRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      StockRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'StockRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is StockRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createStockRecordData({
  String? branchId,
  DocumentReference? branchRef,
  String? disponibilidad,
  String? rawDisponibilidad,
  DateTime? capturedAt,
  DateTime? updatedAt,
  DocumentReference? pharmacyId,
  DocumentReference? productId,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'branchId': branchId,
      'branchRef': branchRef,
      'disponibilidad': disponibilidad,
      'raw_disponibilidad': rawDisponibilidad,
      'capturedAt': capturedAt,
      'updatedAt': updatedAt,
      'pharmacyId': pharmacyId,
      'productId': productId,
    }.withoutNulls,
  );

  return firestoreData;
}

class StockRecordDocumentEquality implements Equality<StockRecord> {
  const StockRecordDocumentEquality();

  @override
  bool equals(StockRecord? e1, StockRecord? e2) {
    return e1?.branchId == e2?.branchId &&
        e1?.branchRef == e2?.branchRef &&
        e1?.disponibilidad == e2?.disponibilidad &&
        e1?.rawDisponibilidad == e2?.rawDisponibilidad &&
        e1?.capturedAt == e2?.capturedAt &&
        e1?.updatedAt == e2?.updatedAt &&
        e1?.pharmacyId == e2?.pharmacyId &&
        e1?.productId == e2?.productId;
  }

  @override
  int hash(StockRecord? e) => const ListEquality().hash([
        e?.branchId,
        e?.branchRef,
        e?.disponibilidad,
        e?.rawDisponibilidad,
        e?.capturedAt,
        e?.updatedAt,
        e?.pharmacyId,
        e?.productId
      ]);

  @override
  bool isValidKey(Object? o) => o is StockRecord;
}
