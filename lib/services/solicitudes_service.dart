import 'dart:convert';
import 'package:frontend/constant/message.dart';
import 'package:frontend/constant/url.dart';
import 'package:frontend/services/auth/auth_service.dart';
import 'package:http/http.dart' as http;

class SolicitudesService {
  Future<List<dynamic>> fetchSolicitudes() async {
    try {
      final token = await _validateToken();
      final url = Uri.parse('$localhost/solicitudes');
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

      final url = Uri.parse('$localhost/solicitudes/$rol/$id');

      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'authorization': 'Bearer $token',
      });

      return jsonDecode(response.body);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> createSolicitud(Map<String, dynamic> solicitud) async {
    try {
      final token = await _validateToken();
      final url = Uri.parse('$localhost/solicitudes');
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
      final url = Uri.parse('$localhost/solicitudes/$solicitudId');
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
      final url = Uri.parse('$localhost/solicitudes/estado/$solicitudId');
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
      final url = Uri.parse('$localhost/solicitudes/$solicitudId');
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

  Future<String> _validateToken() async {
    try {
      final token = await AuthService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception(messageTokenExpired);
      }
      return token;
    } catch (error) {
      throw Exception(error);
    }
  }
}
