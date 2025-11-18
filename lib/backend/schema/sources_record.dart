import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SourcesRecord extends FirestoreRecord {
  SourcesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "capturedAt" field.
  DateTime? _capturedAt;
  DateTime? get capturedAt => _capturedAt;
  bool hasCapturedAt() => _capturedAt != null;

  // "disponibilidad" field.
  bool? _disponibilidad;
  bool get disponibilidad => _disponibilidad ?? false;
  bool hasDisponibilidad() => _disponibilidad != null;

  // "precio_ahora" field.
  double? _precioAhora;
  double get precioAhora => _precioAhora ?? 0.0;
  bool hasPrecioAhora() => _precioAhora != null;

  // "precio_anterior" field.
  double? _precioAnterior;
  double get precioAnterior => _precioAnterior ?? 0.0;
  bool hasPrecioAnterior() => _precioAnterior != null;

  // "sucursalId" field.
  DocumentReference? _sucursalId;
  DocumentReference? get sucursalId => _sucursalId;
  bool hasSucursalId() => _sucursalId != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _capturedAt = snapshotData['capturedAt'] as DateTime?;
    _disponibilidad = snapshotData['disponibilidad'] as bool?;
    _precioAhora = castToType<double>(snapshotData['precio_ahora']);
    _precioAnterior = castToType<double>(snapshotData['precio_anterior']);
    _sucursalId = snapshotData['sucursalId'] as DocumentReference?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('sources')
          : FirebaseFirestore.instance.collectionGroup('sources');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('sources').doc(id);

  static Stream<SourcesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => SourcesRecord.fromSnapshot(s));

  static Future<SourcesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => SourcesRecord.fromSnapshot(s));

  static SourcesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      SourcesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static SourcesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      SourcesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'SourcesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is SourcesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createSourcesRecordData({
  DateTime? capturedAt,
  bool? disponibilidad,
  double? precioAhora,
  double? precioAnterior,
  DocumentReference? sucursalId,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'capturedAt': capturedAt,
      'disponibilidad': disponibilidad,
      'precio_ahora': precioAhora,
      'precio_anterior': precioAnterior,
      'sucursalId': sucursalId,
    }.withoutNulls,
  );

  return firestoreData;
}

class SourcesRecordDocumentEquality implements Equality<SourcesRecord> {
  const SourcesRecordDocumentEquality();

  @override
  bool equals(SourcesRecord? e1, SourcesRecord? e2) {
    return e1?.capturedAt == e2?.capturedAt &&
        e1?.disponibilidad == e2?.disponibilidad &&
        e1?.precioAhora == e2?.precioAhora &&
        e1?.precioAnterior == e2?.precioAnterior &&
        e1?.sucursalId == e2?.sucursalId;
  }

  @override
  int hash(SourcesRecord? e) => const ListEquality().hash([
        e?.capturedAt,
        e?.disponibilidad,
        e?.precioAhora,
        e?.precioAnterior,
        e?.sucursalId
      ]);

  @override
  bool isValidKey(Object? o) => o is SourcesRecord;
}
