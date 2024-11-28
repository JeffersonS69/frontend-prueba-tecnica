import 'package:flutter/material.dart';
import 'package:frontend/api/peticiones_solicitud.dart';
import 'package:frontend/functions/image_state.dart';
import 'package:frontend/functions/provider_auth_service.dart';
import 'package:frontend/functions/solicitudes_state.dart';
import 'package:frontend/services/solicitudes_service.dart';
import 'package:frontend/services/usuarios_service.dart';
import 'package:frontend/widgets/solicitud_card.dart';

class ListViewSolicitudes extends StatelessWidget {
  final SolicitudesState solicitudesState;
  final ImageState imageState;
  final UsuariosService serviceUsuario;
  final int id;
  final String rol;
  final String request;
  final SolicitudesService serviceSolicitud;

  const ListViewSolicitudes({
    super.key,
    required this.solicitudesState,
    required this.imageState,
    required this.serviceUsuario,
    required this.id,
    required this.rol,
    required this.request,
    required this.serviceSolicitud,
  });

  @override
  Widget build(BuildContext context) {
    if (solicitudesState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (solicitudesState.solicitudes.isEmpty) {
      return const Center(child: Text('No hay solicitudes.'));
    }
    
    return ListView.builder(
      itemCount: solicitudesState.solicitudes.length,
      itemBuilder: (context, index) {
        return SolicitudCard(
          imageState: imageState,
          serviceSolicitud: serviceSolicitud,
          serviceUsuario: serviceUsuario,
          validatedToken: () =>
              ProviderAuthService.checkTokenExpiration(context: context),
          solicitud: solicitudesState.solicitudes[index],
          byRol: rol,
          reloadSolicitud: () => PeticionesSolicitud.fetchSolicitudes(
            request: request,
            context: context,
            rol: rol,
            id: id,
            serviceSolicitud: serviceSolicitud,
            solicitudesState: solicitudesState,
          ),
        );
      },
    );
  }
}
