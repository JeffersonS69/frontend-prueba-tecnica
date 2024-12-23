import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/api/peticiones_usuario.dart';
import 'package:frontend/services/usuarios_service.dart';
import 'package:frontend/widgets/view_textfield.dart';

class User extends StatefulWidget {
  final UsuariosService serviceUsuario;
  final Map<String, dynamic> solicitud;

  const User({
    super.key,
    required this.solicitud,
    required this.serviceUsuario,
  });

  @override
  UserState createState() => UserState();
}

class UserState extends State<User> {
  @override
  Widget build(BuildContext context) {
    String fotoPlaca = widget.solicitud['foto_placa'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Información'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              margin: const EdgeInsets.all(8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<Map<String, dynamic>>(
                      future: PeticionesUsuario.getUsuario(
                        id: widget.solicitud['visitante_id'],
                        serviceUsuario: widget.serviceUsuario,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return const Text(
                              'Error al cargar el usuario Visitante');
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cédula: ${snapshot.data!['cedula']}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                'Visitante: ${snapshot.data!['nombres']} ${snapshot.data!['apellidos']}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.all(8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<Map<String, dynamic>>(
                      future: PeticionesUsuario.getUsuario(
                        id: widget.solicitud['residente_id'],
                        serviceUsuario: widget.serviceUsuario,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return const Text(
                              'Error al cargar el usuario Visitante');
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cédula: ${snapshot.data!['cedula']}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                'Residente: ${snapshot.data!['nombres']} ${snapshot.data!['apellidos']}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            ViewTextfield(
                labelText: 'Fecha',
                controllerSolicitud: widget.solicitud['fecha_visita']),
            ViewTextfield(
                labelText: 'Hora',
                controllerSolicitud: widget.solicitud['hora_visita']),
            ViewTextfield(
                labelText: 'Manzana',
                controllerSolicitud: widget.solicitud['manzana']),
            ViewTextfield(
                labelText: 'Villa',
                controllerSolicitud: widget.solicitud['villa']),
            ViewTextfield(
                labelText: 'Estado',
                controllerSolicitud: widget.solicitud['estado']),
            ViewTextfield(
                labelText: 'Medio de ingreso',
                controllerSolicitud: widget.solicitud['medio_ingreso']),
            const SizedBox(height: 20),
            Text(
              'Foto de la placa',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            fotoPlaca.isNotEmpty
                ? Image.memory(
                    base64Decode(fotoPlaca),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : const Text("No se ha proporcionado una imagen."),
          ],
        ),
      ),
    );
  }
}
