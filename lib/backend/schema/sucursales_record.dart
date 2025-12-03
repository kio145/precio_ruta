import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
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

  // ===== NUEVOS CAMPOS =====

  // "horario" field (map con Domingo, Lunes, etc.).
  Map<String, dynamic>? _horario;
  Map<String, dynamic>? get horario => _horario;
  bool hasHorario() => _horario != null;

  // "imagen_url" field.
  String? _imagenUrl;
  String get imagenUrl => _imagenUrl ?? '';
  bool hasImagenUrl() => _imagenUrl != null;

  void _initializeFields() {
    _createdAt = snapshotData['createdAt'] as DateTime?;
    _farmaciaRef = snapshotData['farmaciaRef'] as DocumentReference?;
    _fechaRelacion = snapshotData['fecha_relacion'] as DateTime?;
    _nombre = snapshotData['nombre'] as String?;
    _ubicacion = snapshotData['ubicacion'] as LatLng?;

    // Campos nuevos
    final rawHorario = snapshotData['horario'];
    if (rawHorario is Map) {
      _horario = rawHorario.cast<String, dynamic>();
    } else {
      _horario = null;
    }

    _imagenUrl = snapshotData['imagen_url'] as String?;
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
  Map<String, dynamic>? horario,
  String? imagenUrl,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'createdAt': createdAt,
      'farmaciaRef': farmaciaRef,
      'fecha_relacion': fechaRelacion,
      'nombre': nombre,
      'ubicacion': ubicacion,
      'horario': horario,
      'imagen_url': imagenUrl,
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
        e1?.ubicacion == e2?.ubicacion &&
        const MapEquality().equals(e1?.horario, e2?.horario) &&
        e1?.imagenUrl == e2?.imagenUrl;
  }

  @override
  int hash(SucursalesRecord? e) => const ListEquality().hash([
        e?.createdAt,
        e?.farmaciaRef,
        e?.fechaRelacion,
        e?.nombre,
        e?.ubicacion,
        e?.horario,
        e?.imagenUrl,
      ]);

  @override
  bool isValidKey(Object? o) => o is SucursalesRecord;
}
