import 'package:flutter/material.dart';
import 'package:frontend/functions/solicitudes_state.dart';
import 'package:frontend/screens/home.dart';
import 'package:frontend/services/auth/auth_service.dart';
import 'package:frontend/services/solicitudes_service.dart';
import 'package:frontend/services/usuarios_service.dart';

class FormSubmitHandler {
  static Future<void> loginSubmit({
    required BuildContext context,
    required AuthService authService,
    required TextEditingController cedulaController,
    required TextEditingController passwordController,
    required UsuariosService serviceUsuario,
    required SolicitudesState solicitudesState,
  }) async {
    try {
      final success = await authService.login(
        cedulaController.text,
        passwordController.text,
      );

      if (success) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => Home(
                      context: context,
                      authService: authService,
                      serviceUsuario: serviceUsuario,
                      solicitudesState: solicitudesState,
                    )));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credenciales incorrectas')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al iniciar sesión'),
        ),
      );
    }
  }

  static Future<void> registerSubmit({
    required BuildContext context,
    required TextEditingController nombresController,
    required TextEditingController apellidosController,
    required TextEditingController cedulaController,
    required TextEditingController passwordController,
    required UsuariosService serviceUsuario,
    required String? selectedRol,
  }) async {
    try {
      final formData = {
        'nombres': nombresController.text,
        'apellidos': apellidosController.text,
        'cedula': cedulaController.text,
        'password': passwordController.text,
        'rol': selectedRol,
      };
      await serviceUsuario.createUser(formData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Se ha registrado la solicitud correctamente'),
        ),
      );
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al registrar la solicitud'),
        ),
      );
    }
  }

  static Future<void> updateSubmit({
    required BuildContext context,
    required TextEditingController fechaController,
    required TextEditingController horaController,
    required String selectedMedio,
    required String base64String,
    required SolicitudesService service,
    required int solicitudId,
    required Function reloadSolicitud,
  }) async {
    try {
      final formData = {
        if (fechaController.text.isNotEmpty)
          'fecha_visita': fechaController.text,
        if (horaController.text.isNotEmpty) 'hora_visita': horaController.text,
        'medio_ingreso': selectedMedio,
        if (base64String.isNotEmpty) 'foto_placa': base64String,
      };
      await service.updateSolicitud(solicitudId, formData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Se ha actualizado la solicitud correctamente'),
        ),
      );
      reloadSolicitud();
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al actualizar la solicitud'),
        ),
      );
    }
  }

  static Future<void> _deleteSubmit({
    required BuildContext context,
    required SolicitudesService serviceSolicitud,
    required Map<String, dynamic> solicitud,
    required VoidCallback reloadSolicitud,
  }) async {
    try {
      await serviceSolicitud.deleteSolicitud(solicitud['solicitud_id']);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitud eliminada con éxito'),
        ),
      );
      reloadSolicitud();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al eliminar la solicitud'),
        ),
      );
    }
  }

  static Future<void> confirmDelete({
    required BuildContext context,
    required VoidCallback validatedToken,
    required SolicitudesService serviceSolicitud,
    required Map<String, dynamic> solicitud,
    required VoidCallback reloadSolicitud,
  }) async {
    validatedToken();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content:
              const Text('¿Está seguro de que desea eliminar esta solicitud?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _deleteSubmit(
        context: context,
        serviceSolicitud: serviceSolicitud,
        solicitud: solicitud,
        reloadSolicitud: reloadSolicitud,
      );
    }
  }
}
