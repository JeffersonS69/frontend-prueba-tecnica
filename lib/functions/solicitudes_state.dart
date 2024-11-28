import 'package:flutter/material.dart';

class SolicitudesState with ChangeNotifier {
  List<dynamic> _solicitudes = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<dynamic> get solicitudes => _solicitudes;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  set solicitudes(List<dynamic> value) {
    _solicitudes = value;
    notifyListeners();
  }
}
