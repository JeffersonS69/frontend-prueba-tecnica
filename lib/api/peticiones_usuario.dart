import 'package:flutter/material.dart';
import 'package:frontend/functions/usuarios_state.dart';
import 'package:frontend/services/usuarios_service.dart';

class PeticionesUsuario {
  static Future<String> getNombreCompleto(
    int usuarioId,
    UsuariosService serviceUsuario,
  ) async {
    final usuario = await serviceUsuario.fetchUsuario(
      usuarioId.toString(),
      'id',
    );
    return '${usuario['nombres']} ${usuario['apellidos']}';
  }

  static Future<void> getCedulasUsuarios({
    required String byRol,
    required UsuariosService serviceUsuario,
    required BuildContext context,
    required UsuariosState usuariosState,
  }) async {
    final rol = byRol == 'visitante' ? 'residente' : 'visitante';
    try {
      final data = await serviceUsuario.fetchUsuario(rol, 'rol');
      print(data);
      if (data is List<dynamic>) {
        usuariosState.cedulas =
            data.map<String>((item) => item['cedula'] as String).toList();
      } else {
        throw Exception('El formato de datos no es una lista');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al cargar la lista'),
        ),
      );
    }
  }

  static Future<Map<String, dynamic>> getUsuario({
    required int id,
    required UsuariosService serviceUsuario,
  }) async {
    final usuario =
        await serviceUsuario.fetchUsuario(id.toString(), 'id');
    return usuario;
  }
}
