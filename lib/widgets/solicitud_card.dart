import 'package:flutter/material.dart';
import 'package:frontend/api/peticiones_usuario.dart';
import 'package:frontend/functions/check_solicitud.dart';
import 'package:frontend/functions/image_state.dart';
import 'package:frontend/functions/submit_handler.dart';
import 'package:frontend/screens/update_form.dart';
import 'package:frontend/screens/user.dart';
import 'package:frontend/services/solicitudes_service.dart';
import 'package:frontend/services/usuarios_service.dart';

class SolicitudCard extends StatelessWidget {
  final VoidCallback validatedToken;
  final VoidCallback reloadSolicitud;
  final UsuariosService serviceUsuario;
  final Map<String, dynamic> solicitud;
  final ImageState imageState;
  final int id;
  final String byRol;
  final SolicitudesService serviceSolicitud;

  const SolicitudCard({
    super.key,
    required this.solicitud,
    required this.id,
    required this.byRol,
    required this.reloadSolicitud,
    required this.validatedToken,
    required this.serviceUsuario,
    required this.serviceSolicitud,
    required this.imageState,
  });

  @override
  Widget build(BuildContext context) {
    // Método para obtener el color según el estado
    Color getEstadoColor(String estado) {
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
              future: PeticionesUsuario.getNombreCompleto(
                solicitud['visitante_id'],
                serviceUsuario,
              ),
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
              future: PeticionesUsuario.getNombreCompleto(
                solicitud['visitante_id'],
                serviceUsuario,
              ),
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
                    color: getEstadoColor(solicitud['estado']),
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
                            imageState: imageState,
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
                  onPressed: () async => await FormSubmitHandler.confirmDelete(
                    context: context,
                    validatedToken: validatedToken,
                    serviceSolicitud: serviceSolicitud,
                    solicitud: solicitud,
                    reloadSolicitud: reloadSolicitud,
                  ),
                ),
                if (byRol == 'residente' && solicitud['estado'] == 'ingresada')
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () async => await CheckSolicitud.changeState(
                      context: context,
                      validatedToken: validatedToken,
                      serviceSolicitud: serviceSolicitud,
                      solicitud: solicitud,
                      reloadSolicitud: reloadSolicitud,
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.person, color: Colors.blueAccent),
                  onPressed: () async => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => User(
                                solicitud: solicitud,
                                serviceUsuario: serviceUsuario,
                              )),
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
