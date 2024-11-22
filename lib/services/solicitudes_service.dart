import 'dart:convert';

import 'package:frontend/services/auth_service.dart';
import 'package:http/http.dart' as http;

class SolicitudesService {
  Future<String> _validateToken() async {
    try {
      final token = await AuthService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception(
            'Token no encontrado o expirado. Por favor, inicie sesión nuevamente.');
      }
      return token;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List<dynamic>> fetchSolicitudes() async {
    try {
      final token = await _validateToken();
      final url = Uri.parse('http://10.0.2.2:3000/solicitudes');
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'authorization': 'Bearer $token',
      });
      return jsonDecode(response.body);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List<dynamic>> fetchSolicitudesByRol(String rol, int id) async {
    try {
      final token = await _validateToken();

      final url = Uri.parse('http://10.0.2.2:3000/solicitudes/$rol/$id');

      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'authorization': 'Bearer $token',
      });

      return jsonDecode(response.body);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List<dynamic>> fetchOnlyByRol(String byRol) async {
    try {
      final url = Uri.parse('http://10.0.2.2:3000/usuarios/rol/$byRol');
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
      final url = Uri.parse('http://10.0.2.2:3000/usuarios/$cedula');
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
      final url = Uri.parse('http://10.0.2.2:3000/usuarios/id/$usuarioId');
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
      final url = Uri.parse('http://10.0.2.2:3000/usuarios');
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

  Future<void> createSolicitud(Map<String, dynamic> solicitud) async {
    try {
      final token = await _validateToken();
      final url = Uri.parse('http://10.0.2.2:3000/solicitudes');
      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token',
        },
        body: jsonEncode(solicitud),
      );
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> updateSolicitud(
      int solicitudId, Map<String, String?> updateData) async {
    try {
      final token = await _validateToken();
      final url = Uri.parse('http://10.0.2.2:3000/solicitudes/$solicitudId');
      final a = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token',
        },
        body: jsonEncode(updateData),
      );
      print(a.body);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> updateCheckSolicitud(int solicitudId, String estado) async {
    try {
      final token = await _validateToken();
      final url =
          Uri.parse('http://10.0.2.2:3000/solicitudes/estado/$solicitudId');
      await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'estado': estado,
        }),
      );
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> deleteSolicitud(int solicitudId) async {
    try {
      final token = await _validateToken();
      final url = Uri.parse('http://10.0.2.2:3000/solicitudes/$solicitudId');
      await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token',
        },
      );
    } catch (error) {
      throw Exception(error);
    }
  }
}
