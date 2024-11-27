import 'package:flutter/material.dart';
import 'package:frontend/api/peticiones_usuario.dart';
import 'package:frontend/functions/image_solicitud.dart';
import 'package:frontend/functions/image_state.dart';
import 'package:frontend/functions/submit_handler.dart';
import 'package:frontend/functions/usuarios_state.dart';
import 'package:frontend/services/solicitudes_service.dart';
import 'package:frontend/services/usuarios_service.dart';

class SolicitudForm extends StatefulWidget {
  final VoidCallback validatedToken;
  final VoidCallback reloadSolicitud;
  final SolicitudesService serviceSolicitud;
  final ImageState imageState;
  final UsuariosService serviceUsuario;
  final UsuariosState usuariosState;
  final String byRol;
  final int id;

  const SolicitudForm({
    super.key,
    required this.reloadSolicitud,
    required this.byRol,
    required this.id,
    required this.validatedToken,
    required this.serviceUsuario,
    required this.serviceSolicitud,
    required this.imageState,
    required this.usuariosState,
  });

  @override
  SolicitudFormState createState() => SolicitudFormState();
}

class SolicitudFormState extends State<SolicitudForm> {
  final _formKey = GlobalKey<FormState>();
  final _manzanaController = TextEditingController();
  final _villaController = TextEditingController();
  final _fechaController = TextEditingController();
  final _horaController = TextEditingController();

  final List<String> medios = ['vehículo', 'caminando'];
  String? selectedMedio;
  String? selectedSolicitud;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar solicitud'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              FutureBuilder(
                future: PeticionesUsuario.getCedulasUsuarios(
                  byRol: widget.byRol,
                  serviceUsuario: widget.serviceUsuario,
                  context: context,
                  usuariosState: widget.usuariosState,
                ),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Cargando...');
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return DropdownButtonFormField<String>(
                      hint: const Text('Residente'),
                      value: selectedSolicitud,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedSolicitud = newValue;
                        });
                      },
                      items: widget.usuariosState.Cedulas
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        return null;
                      },
                    );
                  }
                },
              ),
              TextFormField(
                controller: _manzanaController,
                decoration: const InputDecoration(
                  labelText: 'Manzana',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _villaController,
                decoration: const InputDecoration(labelText: 'Villa'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _fechaController,
                decoration:
                    const InputDecoration(labelText: 'Fecha (YYYY-MM-DD)'),
                keyboardType: TextInputType.datetime,
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _fechaController.text =
                          pickedDate.toString().split(' ')[0];
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _horaController,
                decoration: const InputDecoration(labelText: 'Hora (HH:MM:SS)'),
                keyboardType: TextInputType.datetime,
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      String hour = pickedTime.hour.toString().padLeft(2, '0');
                      String minute =
                          pickedTime.minute.toString().padLeft(2, '0');
                      _horaController.text = "$hour:$minute:00";
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                hint: const Text('Medio de ingreso'),
                value: selectedMedio,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedMedio = newValue;
                  });
                },
                items: medios.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
              if (widget.byRol == 'visitante' && selectedMedio == 'vehículo')
                GestureDetector(
                  onTap: () async {
                    await ImageSolicitud.pickImage(
                        imageState: widget.imageState);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    alignment: Alignment.center,
                    color: Colors.grey[300],
                    child: Text(
                      widget.imageState.Base64String.isEmpty
                          ? "Seleccionar Imagen"
                          : "Imagen Seleccionada",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              if (widget.imageState.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    widget.imageState.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await FormSubmitHandler.solicitudSubmit(
                      context: context,
                      manzanaController: _manzanaController,
                      villaController: _villaController,
                      fechaController: _fechaController,
                      horaController: _horaController,
                      selectedMedio: selectedMedio!,
                      base64String: widget.imageState.Base64String,
                      serviceUsuario: widget.serviceUsuario,
                      serviceSolicitud: widget.serviceSolicitud,
                      selectedSolicitud: selectedSolicitud!,
                      id: widget.id,
                      byRol: widget.byRol,
                      reloadSolicitud: widget.reloadSolicitud,
                      selectedRol: selectedSolicitud!,
                    );
                  }
                },
                child: const Text('Crear'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
