import 'package:flutter/material.dart';
import 'package:frontend/functions/provider_auth_service.dart';
import 'package:frontend/services/solicitudes_service.dart';
import 'package:frontend/functions/solicitudes_state.dart';

class PeticionesSolicitud {
  static Future<void> fetchSolicitudes({
    String? rol,
    int? id,
    required BuildContext context,
    required SolicitudesState solicitudesState,
    required SolicitudesService serviceSolicitud,
    required String request,
  }) async {
    try {
      ProviderAuthService.checkTokenExpiration(context: context);
      solicitudesState.isLoading = true;
      final data = await serviceSolicitud.fetchSolicitudes(
          request: request, rol: rol, id: id);
      solicitudesState.solicitudes = data;
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al cargar las solicitudes'),
        ),
      );
    } finally {
      solicitudesState.isLoading = false;
    }
  }
}
