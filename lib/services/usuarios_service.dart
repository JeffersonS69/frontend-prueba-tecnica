import 'dart:convert';
import 'package:frontend/constant/url.dart';
import 'package:http/http.dart' as http;

class UsuariosService {
  Future<List<dynamic>> fetchOnlyByRol(String byRol) async {
    try {
      final url = Uri.parse('$localhost/usuarios/rol/$byRol');
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });
      return jsonDecode(response.body);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<Map<String, dynamic>> fetchOnlyByCedula(String cedula) async {
    try {
      final url = Uri.parse('$localhost/usuarios/$cedula');
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });
      return jsonDecode(response.body);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<Map<String, dynamic>> fetchOnlyById(int usuarioId) async {
    try {
      final url = Uri.parse('$localhost/usuarios/id/$usuarioId');
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });
      return jsonDecode(response.body);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> createUser(Map<String, dynamic> formData) async {
    try {
      final url = Uri.parse('$localhost/usuarios');
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
}
