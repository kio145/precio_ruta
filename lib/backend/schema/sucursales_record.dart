import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SucursalesRecord extends FirestoreRecord {
  SucursalesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "createdAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "farmaciaRef" field.
  DocumentReference? _farmaciaRef;
  DocumentReference? get farmaciaRef => _farmaciaRef;
  bool hasFarmaciaRef() => _farmaciaRef != null;

  // "fecha_relacion" field.
  DateTime? _fechaRelacion;
  DateTime? get fechaRelacion => _fechaRelacion;
  bool hasFechaRelacion() => _fechaRelacion != null;

  // "nombre" field.
  String? _nombre;
  String get nombre => _nombre ?? '';
  bool hasNombre() => _nombre != null;

  // "ubicacion" field.
  LatLng? _ubicacion;
  LatLng? get ubicacion => _ubicacion;
  bool hasUbicacion() => _ubicacion != null;

  void _initializeFields() {
    _createdAt = snapshotData['createdAt'] as DateTime?;
    _farmaciaRef = snapshotData['farmaciaRef'] as DocumentReference?;
    _fechaRelacion = snapshotData['fecha_relacion'] as DateTime?;
    _nombre = snapshotData['nombre'] as String?;
    _ubicacion = snapshotData['ubicacion'] as LatLng?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('sucursales');

  static Stream<SucursalesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => SucursalesRecord.fromSnapshot(s));

  static Future<SucursalesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => SucursalesRecord.fromSnapshot(s));

  static SucursalesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      SucursalesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static SucursalesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      SucursalesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'SucursalesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is SucursalesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createSucursalesRecordData({
  DateTime? createdAt,
  DocumentReference? farmaciaRef,
  DateTime? fechaRelacion,
  String? nombre,
  LatLng? ubicacion,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'createdAt': createdAt,
      'farmaciaRef': farmaciaRef,
      'fecha_relacion': fechaRelacion,
      'nombre': nombre,
      'ubicacion': ubicacion,
    }.withoutNulls,
  );

  return firestoreData;
}

class SucursalesRecordDocumentEquality implements Equality<SucursalesRecord> {
  const SucursalesRecordDocumentEquality();

  @override
  bool equals(SucursalesRecord? e1, SucursalesRecord? e2) {
    return e1?.createdAt == e2?.createdAt &&
        e1?.farmaciaRef == e2?.farmaciaRef &&
        e1?.fechaRelacion == e2?.fechaRelacion &&
        e1?.nombre == e2?.nombre &&
        e1?.ubicacion == e2?.ubicacion;
  }

  @override
  int hash(SucursalesRecord? e) => const ListEquality().hash([
        e?.createdAt,
        e?.farmaciaRef,
        e?.fechaRelacion,
        e?.nombre,
        e?.ubicacion
      ]);

  @override
  bool isValidKey(Object? o) => o is SucursalesRecord;
}
