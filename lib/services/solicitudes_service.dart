import 'dart:convert';
import 'package:frontend/constant/message.dart';
import 'package:frontend/constant/urls.dart';
import 'package:frontend/services/auth/auth_service.dart';
import 'package:http/http.dart' as http;

class SolicitudesService {
  Future<List<dynamic>> fetchSolicitudes({
    required String request,
    String? rol,
    int? id,
  }) async {
    try {
      final token = await _validateToken();
      final fetchURL =
          _getFetchUrlSolicitudes(request: request, rol: rol, id: id);
      final url = Uri.parse(fetchURL);
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'authorization': 'Bearer $token',
      });
      return jsonDecode(response.body);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> fetchRequest({
    required String requestURL,
    required String request,
    Map<String, dynamic>? data,
    String? estado,
    int? id,
  }) async {
    try {
      final token = await _validateToken();
      final fetchURL = _getFetchUrlSolicitudes(request: requestURL, id: id);
      final url = Uri.parse(fetchURL);
      await _makeRequest(
        request: request,
        url: url,
        token: token,
        data: data,
        estado: estado,
      );
    } catch (error) {
      print(error);
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

  String _getFetchUrlSolicitudes({
    required String request,
    String? rol,
    int? id,
  }) {
    switch (request) {
      case 'solicitudes':
        return '$urlBase/$urlSolicitudes';
      case 'solicitudByRol':
        return '$urlBase/$urlSolicitudes/$rol/$id';
      case 'create':
        return '$urlBase/$urlSolicitudes';
      case 'update/delete':
        return '$urlBase/$urlSolicitudes/$id';
      case 'estado':
        return '$urlBase/$urlSolictudesEstado/$id';
      default:
        throw Exception('Petición no válida');
    }
  }

  dynamic _makeRequest({
    required String request,
    required Uri url,
    required String token,
    Map<String, dynamic>? data,
    String? estado,
  }) async {
    switch (request) {
      case 'create':
        await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer $token',
          },
          body: jsonEncode(data),
        );
        break;
      case 'update':
        await http.patch(
          url,
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer $token',
          },
          body: jsonEncode(data),
        );
        break;
      case 'estado':
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
        break;
      case 'delete':
        await http.delete(
          url,
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer $token',
          },
        );
        break;
      default:
        throw Exception('Petición no válida');
    }
  }
}
