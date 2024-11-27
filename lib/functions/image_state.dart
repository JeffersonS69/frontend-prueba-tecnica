import 'package:flutter/material.dart';

class ImageState with ChangeNotifier {
  String _base64String = '';
  String? _imageError;

  String get Base64String => _base64String;
  String? get error => _imageError;

  set base64String(String value) {
    _base64String = value;
    notifyListeners();
  }

  set error(String? value) {
    _imageError = value;
    notifyListeners();
  }
}
