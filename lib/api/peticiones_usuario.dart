import 'package:frontend/services/usuarios_service.dart';

class PeticionesUsuario {
  static Future<String> getNombreCompleto({
    required int usuarioId,
    required UsuariosService serviceUsuario,
  }) async {
    final usuario = await serviceUsuario.fetchOnlyById(usuarioId);
    return '${usuario['nombres']} ${usuario['apellidos']}';
  }
}
