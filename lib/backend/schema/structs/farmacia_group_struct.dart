// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class FarmaciaGroupStruct extends FFFirebaseStruct {
  FarmaciaGroupStruct({
    DocumentReference? farmaciaRef,
    String? farmaciaName,
    String? farmaciaLogo,
    List<CartItemStruct>? products,
    double? total,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _farmaciaRef = farmaciaRef,
        _farmaciaName = farmaciaName,
        _farmaciaLogo = farmaciaLogo,
        _products = products,
        _total = total,
        super(firestoreUtilData);

  // "farmaciaRef" field.
  DocumentReference? _farmaciaRef;
  DocumentReference? get farmaciaRef => _farmaciaRef;
  set farmaciaRef(DocumentReference? val) => _farmaciaRef = val;

  bool hasFarmaciaRef() => _farmaciaRef != null;

  // "farmaciaName" field.
  String? _farmaciaName;
  String get farmaciaName => _farmaciaName ?? '';
  set farmaciaName(String? val) => _farmaciaName = val;

  bool hasFarmaciaName() => _farmaciaName != null;

  // "farmaciaLogo" field.
  String? _farmaciaLogo;
  String get farmaciaLogo => _farmaciaLogo ?? '';
  set farmaciaLogo(String? val) => _farmaciaLogo = val;

  bool hasFarmaciaLogo() => _farmaciaLogo != null;

  // "products" field.
  List<CartItemStruct>? _products;
  List<CartItemStruct> get products => _products ?? const [];
  set products(List<CartItemStruct>? val) => _products = val;

  void updateProducts(Function(List<CartItemStruct>) updateFn) {
    updateFn(_products ??= []);
  }

  bool hasProducts() => _products != null;

  // "total" field.
  double? _total;
  double get total => _total ?? 0.0;
  set total(double? val) => _total = val;

  void incrementTotal(double amount) => total = total + amount;

  bool hasTotal() => _total != null;

  static FarmaciaGroupStruct fromMap(Map<String, dynamic> data) =>
      FarmaciaGroupStruct(
        farmaciaRef: data['farmaciaRef'] as DocumentReference?,
        farmaciaName: data['farmaciaName'] as String?,
        farmaciaLogo: data['farmaciaLogo'] as String?,
        products: getStructList(
          data['products'],
          CartItemStruct.fromMap,
        ),
        total: castToType<double>(data['total']),
      );

  static FarmaciaGroupStruct? maybeFromMap(dynamic data) => data is Map
      ? FarmaciaGroupStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'farmaciaRef': _farmaciaRef,
        'farmaciaName': _farmaciaName,
        'farmaciaLogo': _farmaciaLogo,
        'products': _products?.map((e) => e.toMap()).toList(),
        'total': _total,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'farmaciaRef': serializeParam(
          _farmaciaRef,
          ParamType.DocumentReference,
        ),
        'farmaciaName': serializeParam(
          _farmaciaName,
          ParamType.String,
        ),
        'farmaciaLogo': serializeParam(
          _farmaciaLogo,
          ParamType.String,
        ),
        'products': serializeParam(
          _products,
          ParamType.DataStruct,
          isList: true,
        ),
        'total': serializeParam(
          _total,
          ParamType.double,
        ),
      }.withoutNulls;

  static FarmaciaGroupStruct fromSerializableMap(Map<String, dynamic> data) =>
      FarmaciaGroupStruct(
        farmaciaRef: deserializeParam(
          data['farmaciaRef'],
          ParamType.DocumentReference,
          false,
          collectionNamePath: ['farmacias'],
        ),
        farmaciaName: deserializeParam(
          data['farmaciaName'],
          ParamType.String,
          false,
        ),
        farmaciaLogo: deserializeParam(
          data['farmaciaLogo'],
          ParamType.String,
          false,
        ),
        products: deserializeStructParam<CartItemStruct>(
          data['products'],
          ParamType.DataStruct,
          true,
          structBuilder: CartItemStruct.fromSerializableMap,
        ),
        total: deserializeParam(
          data['total'],
          ParamType.double,
          false,
        ),
      );

  @override
  String toString() => 'FarmaciaGroupStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is FarmaciaGroupStruct &&
        farmaciaRef == other.farmaciaRef &&
        farmaciaName == other.farmaciaName &&
        farmaciaLogo == other.farmaciaLogo &&
        listEquality.equals(products, other.products) &&
        total == other.total;
  }

  @override
  int get hashCode => const ListEquality()
      .hash([farmaciaRef, farmaciaName, farmaciaLogo, products, total]);
}

FarmaciaGroupStruct createFarmaciaGroupStruct({
  DocumentReference? farmaciaRef,
  String? farmaciaName,
  String? farmaciaLogo,
  double? total,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    FarmaciaGroupStruct(
      farmaciaRef: farmaciaRef,
      farmaciaName: farmaciaName,
      farmaciaLogo: farmaciaLogo,
      total: total,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

FarmaciaGroupStruct? updateFarmaciaGroupStruct(
  FarmaciaGroupStruct? farmaciaGroup, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    farmaciaGroup
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addFarmaciaGroupStructData(
  Map<String, dynamic> firestoreData,
  FarmaciaGroupStruct? farmaciaGroup,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (farmaciaGroup == null) {
    return;
  }
  if (farmaciaGroup.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && farmaciaGroup.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final farmaciaGroupData =
      getFarmaciaGroupFirestoreData(farmaciaGroup, forFieldValue);
  final nestedData =
      farmaciaGroupData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = farmaciaGroup.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getFarmaciaGroupFirestoreData(
  FarmaciaGroupStruct? farmaciaGroup, [
  bool forFieldValue = false,
]) {
  if (farmaciaGroup == null) {
    return {};
  }
  final firestoreData = mapToFirestore(farmaciaGroup.toMap());

  // Add any Firestore field values
  farmaciaGroup.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getFarmaciaGroupListFirestoreData(
  List<FarmaciaGroupStruct>? farmaciaGroups,
) =>
    farmaciaGroups
        ?.map((e) => getFarmaciaGroupFirestoreData(e, true))
        .toList() ??
    [];
