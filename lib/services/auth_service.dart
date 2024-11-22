import 'dart:convert';
import 'package:frontend/services/secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class AuthService with ChangeNotifier {
  String? _token;
  String? _rol;
  int? _id;

  String? get token => _token;
  String? get rol => _rol;
  int? get id => _id;

  Future<bool> login(String cedula, String password) async {
    final url = Uri.parse('http://10.0.2.2:3000/auth/login');

    final response = await http.post(
      url,
      body: jsonEncode({
        'cedula': cedula,
        'password': password,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['access_token'];

      final payload = _decodeJWT(_token!);
      _rol = payload['rol'];
      _id = payload['sub'];

      await SecureStorage.saveToken(_token!);

      notifyListeners();
      return true;
    }

    return false;
  }

  Map<String, dynamic> _decodeJWT(String token) {
    final parts = token.split('.');
    final payload =
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    return jsonDecode(payload);
  }

  bool isTokenExpired() {
    if (_token == null) return true;
    try {
      final payload = _decodeJWT(_token!);
      final exp = payload['exp'];
      final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expirationDate);
    } catch (error) {
      return true;
    }
  }

  static Future<String?> getToken() async {
    return await SecureStorage.getToken();
  }

  static Future<Map<String, dynamic>> getPerfile(String token) async {
    final url = Uri.parse('http://10.0.2.2:3000/auth/perfile');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar el perfil');
    }
  }
}
