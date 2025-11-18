import 'package:flutter/material.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {}

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  LatLng? _ubicacion = LatLng(-17.393729, -66.266204);
  LatLng? get ubicacion => _ubicacion;
  set ubicacion(LatLng? value) {
    _ubicacion = value;
  }

  String _Busqueda = '';
  String get Busqueda => _Busqueda;
  set Busqueda(String value) {
    _Busqueda = value;
  }

  bool _MostrarSugerencias = false;
  bool get MostrarSugerencias => _MostrarSugerencias;
  set MostrarSugerencias(bool value) {
    _MostrarSugerencias = value;
  }

  List<CartItemStruct> _cartItems = [];
  List<CartItemStruct> get cartItems => _cartItems;
  set cartItems(List<CartItemStruct> value) {
    _cartItems = value;
  }

  void addToCartItems(CartItemStruct value) {
    cartItems.add(value);
  }

  void removeFromCartItems(CartItemStruct value) {
    cartItems.remove(value);
  }

  void removeAtIndexFromCartItems(int index) {
    cartItems.removeAt(index);
  }

  void updateCartItemsAtIndex(
    int index,
    CartItemStruct Function(CartItemStruct) updateFn,
  ) {
    cartItems[index] = updateFn(_cartItems[index]);
  }

  void insertAtIndexInCartItems(int index, CartItemStruct value) {
    cartItems.insert(index, value);
  }

  List<LatLng> _ubicacionesFarm = [
    LatLng(-17.38419, -66.15893),
    LatLng(-17.36424, -66.16596),
    LatLng(-17.36816, -66.16356),
    LatLng(-17.39, -66.15)
  ];
  List<LatLng> get ubicacionesFarm => _ubicacionesFarm;
  set ubicacionesFarm(List<LatLng> value) {
    _ubicacionesFarm = value;
  }

  void addToUbicacionesFarm(LatLng value) {
    ubicacionesFarm.add(value);
  }

  void removeFromUbicacionesFarm(LatLng value) {
    ubicacionesFarm.remove(value);
  }

  void removeAtIndexFromUbicacionesFarm(int index) {
    ubicacionesFarm.removeAt(index);
  }

  void updateUbicacionesFarmAtIndex(
    int index,
    LatLng Function(LatLng) updateFn,
  ) {
    ubicacionesFarm[index] = updateFn(_ubicacionesFarm[index]);
  }

  void insertAtIndexInUbicacionesFarm(int index, LatLng value) {
    ubicacionesFarm.insert(index, value);
  }

  String _textoBuscado = '';
  String get textoBuscado => _textoBuscado;
  set textoBuscado(String value) {
    _textoBuscado = value;
  }

  String _routeDuration = '';
  String get routeDuration => _routeDuration;
  set routeDuration(String value) {
    _routeDuration = value;
  }

  String _routeDistance = '';
  String get routeDistance => _routeDistance;
  set routeDistance(String value) {
    _routeDistance = value;
  }
}
