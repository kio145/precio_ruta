// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ProductDataStruct extends FFFirebaseStruct {
  ProductDataStruct({
    String? id,
    String? nombre,
    String? imagenUrl,
    double? precioActual,
    bool? disponibilidad,
    String? urlProducto,
    String? sucursalId,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _id = id,
        _nombre = nombre,
        _imagenUrl = imagenUrl,
        _precioActual = precioActual,
        _disponibilidad = disponibilidad,
        _urlProducto = urlProducto,
        _sucursalId = sucursalId,
        super(firestoreUtilData);

  // "id" field.
  String? _id;
  String get id => _id ?? '';
  set id(String? val) => _id = val;

  bool hasId() => _id != null;

  // "nombre" field.
  String? _nombre;
  String get nombre => _nombre ?? '';
  set nombre(String? val) => _nombre = val;

  bool hasNombre() => _nombre != null;

  // "imagen_url" field.
  String? _imagenUrl;
  String get imagenUrl => _imagenUrl ?? '';
  set imagenUrl(String? val) => _imagenUrl = val;

  bool hasImagenUrl() => _imagenUrl != null;

  // "precio_actual" field.
  double? _precioActual;
  double get precioActual => _precioActual ?? 0.0;
  set precioActual(double? val) => _precioActual = val;

  void incrementPrecioActual(double amount) =>
      precioActual = precioActual + amount;

  bool hasPrecioActual() => _precioActual != null;

  // "disponibilidad" field.
  bool? _disponibilidad;
  bool get disponibilidad => _disponibilidad ?? false;
  set disponibilidad(bool? val) => _disponibilidad = val;

  bool hasDisponibilidad() => _disponibilidad != null;

  // "url_producto" field.
  String? _urlProducto;
  String get urlProducto => _urlProducto ?? '';
  set urlProducto(String? val) => _urlProducto = val;

  bool hasUrlProducto() => _urlProducto != null;

  // "sucursalId" field.
  String? _sucursalId;
  String get sucursalId => _sucursalId ?? '';
  set sucursalId(String? val) => _sucursalId = val;

  bool hasSucursalId() => _sucursalId != null;

  static ProductDataStruct fromMap(Map<String, dynamic> data) =>
      ProductDataStruct(
        id: data['id'] as String?,
        nombre: data['nombre'] as String?,
        imagenUrl: data['imagen_url'] as String?,
        precioActual: castToType<double>(data['precio_actual']),
        disponibilidad: data['disponibilidad'] as bool?,
        urlProducto: data['url_producto'] as String?,
        sucursalId: data['sucursalId'] as String?,
      );

  static ProductDataStruct? maybeFromMap(dynamic data) => data is Map
      ? ProductDataStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'nombre': _nombre,
        'imagen_url': _imagenUrl,
        'precio_actual': _precioActual,
        'disponibilidad': _disponibilidad,
        'url_producto': _urlProducto,
        'sucursalId': _sucursalId,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(
          _id,
          ParamType.String,
        ),
        'nombre': serializeParam(
          _nombre,
          ParamType.String,
        ),
        'imagen_url': serializeParam(
          _imagenUrl,
          ParamType.String,
        ),
        'precio_actual': serializeParam(
          _precioActual,
          ParamType.double,
        ),
        'disponibilidad': serializeParam(
          _disponibilidad,
          ParamType.bool,
        ),
        'url_producto': serializeParam(
          _urlProducto,
          ParamType.String,
        ),
        'sucursalId': serializeParam(
          _sucursalId,
          ParamType.String,
        ),
      }.withoutNulls;

  static ProductDataStruct fromSerializableMap(Map<String, dynamic> data) =>
      ProductDataStruct(
        id: deserializeParam(
          data['id'],
          ParamType.String,
          false,
        ),
        nombre: deserializeParam(
          data['nombre'],
          ParamType.String,
          false,
        ),
        imagenUrl: deserializeParam(
          data['imagen_url'],
          ParamType.String,
          false,
        ),
        precioActual: deserializeParam(
          data['precio_actual'],
          ParamType.double,
          false,
        ),
        disponibilidad: deserializeParam(
          data['disponibilidad'],
          ParamType.bool,
          false,
        ),
        urlProducto: deserializeParam(
          data['url_producto'],
          ParamType.String,
          false,
        ),
        sucursalId: deserializeParam(
          data['sucursalId'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'ProductDataStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ProductDataStruct &&
        id == other.id &&
        nombre == other.nombre &&
        imagenUrl == other.imagenUrl &&
        precioActual == other.precioActual &&
        disponibilidad == other.disponibilidad &&
        urlProducto == other.urlProducto &&
        sucursalId == other.sucursalId;
  }

  @override
  int get hashCode => const ListEquality().hash([
        id,
        nombre,
        imagenUrl,
        precioActual,
        disponibilidad,
        urlProducto,
        sucursalId
      ]);
}

ProductDataStruct createProductDataStruct({
  String? id,
  String? nombre,
  String? imagenUrl,
  double? precioActual,
  bool? disponibilidad,
  String? urlProducto,
  String? sucursalId,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    ProductDataStruct(
      id: id,
      nombre: nombre,
      imagenUrl: imagenUrl,
      precioActual: precioActual,
      disponibilidad: disponibilidad,
      urlProducto: urlProducto,
      sucursalId: sucursalId,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

ProductDataStruct? updateProductDataStruct(
  ProductDataStruct? productData, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    productData
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addProductDataStructData(
  Map<String, dynamic> firestoreData,
  ProductDataStruct? productData,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (productData == null) {
    return;
  }
  if (productData.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && productData.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final productDataData =
      getProductDataFirestoreData(productData, forFieldValue);
  final nestedData =
      productDataData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = productData.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getProductDataFirestoreData(
  ProductDataStruct? productData, [
  bool forFieldValue = false,
]) {
  if (productData == null) {
    return {};
  }
  final firestoreData = mapToFirestore(productData.toMap());

  // Add any Firestore field values
  productData.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getProductDataListFirestoreData(
  List<ProductDataStruct>? productDatas,
) =>
    productDatas?.map((e) => getProductDataFirestoreData(e, true)).toList() ??
    [];
