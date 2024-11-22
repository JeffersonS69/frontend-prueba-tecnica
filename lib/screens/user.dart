import 'dart:convert'; // Para poder usar base64Decode
import 'package:flutter/material.dart';
import 'package:frontend/services/solicitudes_service.dart';

class User extends StatefulWidget {
  final Map<String, dynamic> solicitud;

  const User({
    super.key,
    required this.solicitud,
  });

  @override
  UserState createState() => UserState();
}

class UserState extends State<User> {
  final service = SolicitudesService();

  Future<Map<String, dynamic>> _getUsuario(int id) async {
    final visitante = await service.fetchOnlyById(id);
    return visitante;
  }

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
                      future: _getUsuario(widget.solicitud['visitante_id']),
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
                      future: _getUsuario(widget.solicitud['residente_id']),
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
            TextField(
              decoration: const InputDecoration(
                labelText: 'Fecha',
              ),
              controller:
                  TextEditingController(text: widget.solicitud['fecha_visita']),
              style: const TextStyle(color: Colors.black87),
              enabled: false,
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Hora',
              ),
              controller:
                  TextEditingController(text: widget.solicitud['fecha_visita']),
              style: const TextStyle(color: Colors.black87),
              enabled: false,
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Manzana',
              ),
              controller:
                  TextEditingController(text: widget.solicitud['manzana']),
              style: const TextStyle(color: Colors.black87),
              enabled: false,
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Villa',
              ),
              controller:
                  TextEditingController(text: widget.solicitud['villa']),
              style: const TextStyle(color: Colors.black87),
              enabled: false,
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Estado',
              ),
              controller:
                  TextEditingController(text: widget.solicitud['estado']),
              style: const TextStyle(color: Colors.black87),
              enabled: false,
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Medio de ingreso',
              ),
              controller: TextEditingController(
                  text: widget.solicitud['medio_ingreso']),
              style: const TextStyle(color: Colors.black87),
              enabled: false,
            ),
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
