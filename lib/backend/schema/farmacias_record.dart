import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class FarmaciasRecord extends FirestoreRecord {
  FarmaciasRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "fecha_creacion" field.
  DateTime? _fechaCreacion;
  DateTime? get fechaCreacion => _fechaCreacion;
  bool hasFechaCreacion() => _fechaCreacion != null;

  // "nombre_comercial" field.
  String? _nombreComercial;
  String get nombreComercial => _nombreComercial ?? '';
  bool hasNombreComercial() => _nombreComercial != null;

  // "logourl" field.
  String? _logourl;
  String get logourl => _logourl ?? '';
  bool hasLogourl() => _logourl != null;

  // "slug" field.
  String? _slug;
  String get slug => _slug ?? '';
  bool hasSlug() => _slug != null;

  // "fecha_actualizacion" field.
  DateTime? _fechaActualizacion;
  DateTime? get fechaActualizacion => _fechaActualizacion;
  bool hasFechaActualizacion() => _fechaActualizacion != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  void _initializeFields() {
    _fechaCreacion = snapshotData['fecha_creacion'] as DateTime?;
    _nombreComercial = snapshotData['nombre_comercial'] as String?;
    _logourl = snapshotData['logourl'] as String?;
    _slug = snapshotData['slug'] as String?;
    _fechaActualizacion = snapshotData['fecha_actualizacion'] as DateTime?;
    _uid = snapshotData['uid'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('farmacias');

  static Stream<FarmaciasRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => FarmaciasRecord.fromSnapshot(s));

  static Future<FarmaciasRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => FarmaciasRecord.fromSnapshot(s));

  static FarmaciasRecord fromSnapshot(DocumentSnapshot snapshot) =>
      FarmaciasRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static FarmaciasRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      FarmaciasRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'FarmaciasRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is FarmaciasRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createFarmaciasRecordData({
  DateTime? fechaCreacion,
  String? nombreComercial,
  String? logourl,
  String? slug,
  DateTime? fechaActualizacion,
  String? uid,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'fecha_creacion': fechaCreacion,
      'nombre_comercial': nombreComercial,
      'logourl': logourl,
      'slug': slug,
      'fecha_actualizacion': fechaActualizacion,
      'uid': uid,
    }.withoutNulls,
  );

  return firestoreData;
}

class FarmaciasRecordDocumentEquality implements Equality<FarmaciasRecord> {
  const FarmaciasRecordDocumentEquality();

  @override
  bool equals(FarmaciasRecord? e1, FarmaciasRecord? e2) {
    return e1?.fechaCreacion == e2?.fechaCreacion &&
        e1?.nombreComercial == e2?.nombreComercial &&
        e1?.logourl == e2?.logourl &&
        e1?.slug == e2?.slug &&
        e1?.fechaActualizacion == e2?.fechaActualizacion &&
        e1?.uid == e2?.uid;
  }

  @override
  int hash(FarmaciasRecord? e) => const ListEquality().hash([
        e?.fechaCreacion,
        e?.nombreComercial,
        e?.logourl,
        e?.slug,
        e?.fechaActualizacion,
        e?.uid
      ]);

  @override
  bool isValidKey(Object? o) => o is FarmaciasRecord;
}
