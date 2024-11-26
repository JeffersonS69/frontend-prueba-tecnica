import 'package:flutter/material.dart';
import 'package:frontend/services/solicitudes_service.dart';

class CheckSolicitud {
  static Future<void> changeState({
    required BuildContext context,
    required VoidCallback validatedToken,
    required SolicitudesService serviceSolicitud,
    required Map<String, dynamic> solicitud,
    required VoidCallback reloadSolicitud,
  }) async {
    validatedToken();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Acción requerida'),
          content: const Text('¿Desea aprobar o rechazar esta solicitud?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop('approve'),
              child: const Text(
                'Aprobar',
                style: TextStyle(color: Colors.green),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('reject'),
              child: const Text(
                'Rechazar',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('cancel'),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );

    switch (result) {
      case 'approve':
        await _stateSolicitud(
          estado: 'aprobada',
          context: context,
          serviceSolicitud: serviceSolicitud,
          solicitud: solicitud,
          reloadSolicitud: reloadSolicitud,
        );
        break;
      case 'reject':
        await _stateSolicitud(
          estado: 'rechazada',
          context: context,
          serviceSolicitud: serviceSolicitud,
          solicitud: solicitud,
          reloadSolicitud: reloadSolicitud,
        );
        break;
      case 'cancel':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Acción cancelada')),
        );
        break;
    }
  }

  static Future<void> _stateSolicitud({
    required String estado,
    required BuildContext context,
    required SolicitudesService serviceSolicitud,
    required Map<String, dynamic> solicitud,
    required VoidCallback reloadSolicitud,
  }) async {
    try {
      await serviceSolicitud.updateCheckSolicitud(
          solicitud['solicitud_id'], estado);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitud actualizada con éxito'),
        ),
      );
      reloadSolicitud();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al actualizar la solicitud'),
        ),
      );
    }
  }
}
