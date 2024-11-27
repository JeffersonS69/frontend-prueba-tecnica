import 'dart:convert';
import 'package:frontend/constant/urls.dart';
import 'package:http/http.dart' as http;

class UsuariosService {
  Future<dynamic> fetchUsuario(
    String data,
    String request,
  ) async {
    try {
      final fetchURL = _getFetchUrlUsuario(request: request, data: data);
      final url = Uri.parse(fetchURL);
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });
      return jsonDecode(response.body);
    } catch (error) {
      print(error);
      throw Exception(error);
    }
  }

  Future<void> createUser(Map<String, dynamic> formData) async {
    try {
      final fetchURL = _getFetchUrlUsuario(request: 'create');
      final url = Uri.parse(fetchURL);
      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(formData),
      );
    } catch (error) {
      throw Exception(error);
    }
  }

  String _getFetchUrlUsuario({required String request, String? data}) {
    switch (request) {
      case 'rol':
        return '$urlBase/$urlUsuario/rol/$data';
      case 'cedula':
        return '$urlBase/$urlUsuario/$data';
      case 'id':
        return '$urlBase/$urlUsuario/id/$data';
      case 'create':
        return '$urlBase/$urlUsuario';
      default:
        throw Exception('Invalid peticion type');
    }
  }
}
