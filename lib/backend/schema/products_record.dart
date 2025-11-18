import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ProductsRecord extends FirestoreRecord {
  ProductsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "imagen_url" field.
  String? _imagenUrl;
  String get imagenUrl => _imagenUrl ?? '';
  bool hasImagenUrl() => _imagenUrl != null;

  // "nombre" field.
  String? _nombre;
  String get nombre => _nombre ?? '';
  bool hasNombre() => _nombre != null;

  // "updatedAt" field.
  DateTime? _updatedAt;
  DateTime? get updatedAt => _updatedAt;
  bool hasUpdatedAt() => _updatedAt != null;

  // "tokens" field.
  List<String>? _tokens;
  List<String> get tokens => _tokens ?? const [];
  bool hasTokens() => _tokens != null;

  // "brand" field.
  String? _brand;
  String get brand => _brand ?? '';
  bool hasBrand() => _brand != null;

  // "createdAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "precio_actual" field.
  double? _precioActual;
  double get precioActual => _precioActual ?? 0.0;
  bool hasPrecioActual() => _precioActual != null;

  // "pharmacyIds" field.
  List<String>? _pharmacyIds;
  List<String> get pharmacyIds => _pharmacyIds ?? const [];
  bool hasPharmacyIds() => _pharmacyIds != null;

  void _initializeFields() {
    _imagenUrl = snapshotData['imagen_url'] as String?;
    _nombre = snapshotData['nombre'] as String?;
    _updatedAt = snapshotData['updatedAt'] as DateTime?;
    _tokens = getDataList(snapshotData['tokens']);
    _brand = snapshotData['brand'] as String?;
    _createdAt = snapshotData['createdAt'] as DateTime?;
    _precioActual = castToType<double>(snapshotData['precio_actual']);
    _pharmacyIds = getDataList(snapshotData['pharmacyIds']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('products');

  static Stream<ProductsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ProductsRecord.fromSnapshot(s));

  static Future<ProductsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ProductsRecord.fromSnapshot(s));

  static ProductsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ProductsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ProductsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ProductsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ProductsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ProductsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createProductsRecordData({
  String? imagenUrl,
  String? nombre,
  DateTime? updatedAt,
  String? brand,
  DateTime? createdAt,
  double? precioActual,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'imagen_url': imagenUrl,
      'nombre': nombre,
      'updatedAt': updatedAt,
      'brand': brand,
      'createdAt': createdAt,
      'precio_actual': precioActual,
    }.withoutNulls,
  );

  return firestoreData;
}

class ProductsRecordDocumentEquality implements Equality<ProductsRecord> {
  const ProductsRecordDocumentEquality();

  @override
  bool equals(ProductsRecord? e1, ProductsRecord? e2) {
    const listEquality = ListEquality();
    return e1?.imagenUrl == e2?.imagenUrl &&
        e1?.nombre == e2?.nombre &&
        e1?.updatedAt == e2?.updatedAt &&
        listEquality.equals(e1?.tokens, e2?.tokens) &&
        e1?.brand == e2?.brand &&
        e1?.createdAt == e2?.createdAt &&
        e1?.precioActual == e2?.precioActual &&
        listEquality.equals(e1?.pharmacyIds, e2?.pharmacyIds);
  }

  @override
  int hash(ProductsRecord? e) => const ListEquality().hash([
        e?.imagenUrl,
        e?.nombre,
        e?.updatedAt,
        e?.tokens,
        e?.brand,
        e?.createdAt,
        e?.precioActual,
        e?.pharmacyIds
      ]);

  @override
  bool isValidKey(Object? o) => o is ProductsRecord;
}
