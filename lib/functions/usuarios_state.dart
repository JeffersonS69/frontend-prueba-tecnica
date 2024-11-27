import 'package:flutter/material.dart';

class UsuariosState with ChangeNotifier {
  List<String> _cedulas = [];

  List<String> get Cedulas => _cedulas;

  set cedulas(List<String> value) {
    _cedulas = value;
    notifyListeners();
  }
}
