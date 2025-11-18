// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CartItemStruct extends FFFirebaseStruct {
  CartItemStruct({
    DocumentReference? productRef,
    String? productImage,
    String? productName,
    double? price,
    int? quantity,
    DocumentReference? farmaciaRef,
    String? farmaciaName,
    String? farmaciaLogo,
    String? productId,
    String? pharmacyId,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _productRef = productRef,
        _productImage = productImage,
        _productName = productName,
        _price = price,
        _quantity = quantity,
        _farmaciaRef = farmaciaRef,
        _farmaciaName = farmaciaName,
        _farmaciaLogo = farmaciaLogo,
        _productId = productId,
        _pharmacyId = pharmacyId,
        super(firestoreUtilData);

  // "productRef" field.
  DocumentReference? _productRef;
  DocumentReference? get productRef => _productRef;
  set productRef(DocumentReference? val) => _productRef = val;

  bool hasProductRef() => _productRef != null;

  // "productImage" field.
  String? _productImage;
  String get productImage => _productImage ?? '';
  set productImage(String? val) => _productImage = val;

  bool hasProductImage() => _productImage != null;

  // "productName" field.
  String? _productName;
  String get productName => _productName ?? '';
  set productName(String? val) => _productName = val;

  bool hasProductName() => _productName != null;

  // "price" field.
  double? _price;
  double get price => _price ?? 0.0;
  set price(double? val) => _price = val;

  void incrementPrice(double amount) => price = price + amount;

  bool hasPrice() => _price != null;

  // "quantity" field.
  int? _quantity;
  int get quantity => _quantity ?? 0;
  set quantity(int? val) => _quantity = val;

  void incrementQuantity(int amount) => quantity = quantity + amount;

  bool hasQuantity() => _quantity != null;

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

  // "productId" field.
  String? _productId;
  String get productId => _productId ?? '';
  set productId(String? val) => _productId = val;

  bool hasProductId() => _productId != null;

  // "pharmacyId" field.
  String? _pharmacyId;
  String get pharmacyId => _pharmacyId ?? '';
  set pharmacyId(String? val) => _pharmacyId = val;

  bool hasPharmacyId() => _pharmacyId != null;

  static CartItemStruct fromMap(Map<String, dynamic> data) => CartItemStruct(
        productRef: data['productRef'] as DocumentReference?,
        productImage: data['productImage'] as String?,
        productName: data['productName'] as String?,
        price: castToType<double>(data['price']),
        quantity: castToType<int>(data['quantity']),
        farmaciaRef: data['farmaciaRef'] as DocumentReference?,
        farmaciaName: data['farmaciaName'] as String?,
        farmaciaLogo: data['farmaciaLogo'] as String?,
        productId: data['productId'] as String?,
        pharmacyId: data['pharmacyId'] as String?,
      );

  static CartItemStruct? maybeFromMap(dynamic data) =>
      data is Map ? CartItemStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'productRef': _productRef,
        'productImage': _productImage,
        'productName': _productName,
        'price': _price,
        'quantity': _quantity,
        'farmaciaRef': _farmaciaRef,
        'farmaciaName': _farmaciaName,
        'farmaciaLogo': _farmaciaLogo,
        'productId': _productId,
        'pharmacyId': _pharmacyId,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'productRef': serializeParam(
          _productRef,
          ParamType.DocumentReference,
        ),
        'productImage': serializeParam(
          _productImage,
          ParamType.String,
        ),
        'productName': serializeParam(
          _productName,
          ParamType.String,
        ),
        'price': serializeParam(
          _price,
          ParamType.double,
        ),
        'quantity': serializeParam(
          _quantity,
          ParamType.int,
        ),
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
        'productId': serializeParam(
          _productId,
          ParamType.String,
        ),
        'pharmacyId': serializeParam(
          _pharmacyId,
          ParamType.String,
        ),
      }.withoutNulls;

  static CartItemStruct fromSerializableMap(Map<String, dynamic> data) =>
      CartItemStruct(
        productRef: deserializeParam(
          data['productRef'],
          ParamType.DocumentReference,
          false,
          collectionNamePath: ['products'],
        ),
        productImage: deserializeParam(
          data['productImage'],
          ParamType.String,
          false,
        ),
        productName: deserializeParam(
          data['productName'],
          ParamType.String,
          false,
        ),
        price: deserializeParam(
          data['price'],
          ParamType.double,
          false,
        ),
        quantity: deserializeParam(
          data['quantity'],
          ParamType.int,
          false,
        ),
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
        productId: deserializeParam(
          data['productId'],
          ParamType.String,
          false,
        ),
        pharmacyId: deserializeParam(
          data['pharmacyId'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'CartItemStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is CartItemStruct &&
        productRef == other.productRef &&
        productImage == other.productImage &&
        productName == other.productName &&
        price == other.price &&
        quantity == other.quantity &&
        farmaciaRef == other.farmaciaRef &&
        farmaciaName == other.farmaciaName &&
        farmaciaLogo == other.farmaciaLogo &&
        productId == other.productId &&
        pharmacyId == other.pharmacyId;
  }

  @override
  int get hashCode => const ListEquality().hash([
        productRef,
        productImage,
        productName,
        price,
        quantity,
        farmaciaRef,
        farmaciaName,
        farmaciaLogo,
        productId,
        pharmacyId
      ]);
}

CartItemStruct createCartItemStruct({
  DocumentReference? productRef,
  String? productImage,
  String? productName,
  double? price,
  int? quantity,
  DocumentReference? farmaciaRef,
  String? farmaciaName,
  String? farmaciaLogo,
  String? productId,
  String? pharmacyId,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    CartItemStruct(
      productRef: productRef,
      productImage: productImage,
      productName: productName,
      price: price,
      quantity: quantity,
      farmaciaRef: farmaciaRef,
      farmaciaName: farmaciaName,
      farmaciaLogo: farmaciaLogo,
      productId: productId,
      pharmacyId: pharmacyId,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

CartItemStruct? updateCartItemStruct(
  CartItemStruct? cartItem, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    cartItem
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addCartItemStructData(
  Map<String, dynamic> firestoreData,
  CartItemStruct? cartItem,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (cartItem == null) {
    return;
  }
  if (cartItem.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && cartItem.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final cartItemData = getCartItemFirestoreData(cartItem, forFieldValue);
  final nestedData = cartItemData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = cartItem.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getCartItemFirestoreData(
  CartItemStruct? cartItem, [
  bool forFieldValue = false,
]) {
  if (cartItem == null) {
    return {};
  }
  final firestoreData = mapToFirestore(cartItem.toMap());

  // Add any Firestore field values
  cartItem.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getCartItemListFirestoreData(
  List<CartItemStruct>? cartItems,
) =>
    cartItems?.map((e) => getCartItemFirestoreData(e, true)).toList() ?? [];
