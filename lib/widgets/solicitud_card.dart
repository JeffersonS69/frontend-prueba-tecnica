import 'package:flutter/material.dart';
import 'package:frontend/screens/update_form.dart';
import 'package:frontend/screens/user.dart';
import 'package:frontend/services/solicitudes_service.dart';

class SolicitudCard extends StatelessWidget {
  final VoidCallback validatedToken;
  final VoidCallback reloadSolicitud;
  final Map<String, dynamic> solicitud;
  final int id;
  final String byRol;
  final service = SolicitudesService();

  SolicitudCard({
    super.key,
    required this.solicitud,
    required this.id,
    required this.byRol,
    required this.reloadSolicitud,
    required this.validatedToken,
  });

  Future<String> _getNombreCompleto(int usuarioId) async {
    final usuario = await service.fetchOnlyById(usuarioId);
    return '${usuario['nombres']} ${usuario['apellidos']}';
  }

  Future<void> _deleteSolicitud(BuildContext context) async {
    validatedToken();
    try {
      await service.deleteSolicitud(solicitud['solicitud_id']);
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

  Future<void> _confirmDelete(BuildContext context) async {
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
      await _deleteSolicitud(context);
    }
  }

  Future<void> _checkSolicitud(BuildContext context) async {
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
        await _stateSolicitud('aprobada', context);
        break;
      case 'reject':
        await _stateSolicitud('rechazada', context);
        break;
      case 'cancel':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Acción cancelada')),
        );
        break;
    }
  }

  Future<void> _stateSolicitud(String estado, BuildContext context) async {
    validatedToken();
    try {
      await service.updateCheckSolicitud(solicitud['solicitud_id'], estado);
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

  @override
  Widget build(BuildContext context) {
    // Método para obtener el color según el estado
    Color _getEstadoColor(String estado) {
      switch (estado.toLowerCase()) {
        case 'rechazada':
          return Colors.red;
        case 'aprobada':
          return Colors.green;
        case 'ingresada':
        default:
          return Colors.grey;
      }
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<String>(
              future: _getNombreCompleto(solicitud['visitante_id']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Cargando visitante...');
                } else if (snapshot.hasError) {
                  return const Text('Error al cargar visitante');
                } else {
                  return Text(
                    'Visitante: ${snapshot.data}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  );
                }
              },
            ),
            const SizedBox(height: 8),
            FutureBuilder<String>(
              future: _getNombreCompleto(solicitud['residente_id']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Cargando residente...');
                } else if (snapshot.hasError) {
                  return const Text('Error al cargar residente');
                } else {
                  return Text(
                    'Residente: ${snapshot.data}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  );
                }
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Fecha: ${solicitud['fecha_visita']}\nHora: ${solicitud['hora_visita']}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Estado: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  solicitud['estado'],
                  style: TextStyle(
                    color: _getEstadoColor(solicitud['estado']),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (solicitud['estado'] == 'ingresada')
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UpdateForm(
                            reloadSolicitud: reloadSolicitud,
                            solicitudId: solicitud['solicitud_id'],
                            fecha: solicitud['fecha_visita'],
                            hora: solicitud['hora_visita'],
                            medio: solicitud['medio_ingreso'],
                            foto: solicitud['foto_placa'],
                          ),
                        ),
                      );
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async => await _confirmDelete(context),
                ),
                if (byRol == 'residente' && solicitud['estado'] == 'ingresada')
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () async => await _checkSolicitud(context),
                  ),
                IconButton(
                  icon: const Icon(Icons.person, color: Colors.blueAccent),
                  onPressed: () async => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => User(solicitud: solicitud)),
                    )
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
