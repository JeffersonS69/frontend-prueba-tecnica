import 'package:flutter/material.dart';

class SolicitudesState with ChangeNotifier {
  List<dynamic> _solicitudes = [];
  List<dynamic> _solicitudesAll = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<dynamic> get solicitudes => _solicitudes;
  List<dynamic> get solicitudesAll => _solicitudesAll;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  set solicitudes(List<dynamic> value) {
    _solicitudes = value;
    notifyListeners();
  }

  set solicitudesAll(List<dynamic> value) {
    _solicitudesAll = value;
    notifyListeners();
  }
}
