import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/services/solicitudes_service.dart';
import 'package:image_picker/image_picker.dart';

class SolicitudForm extends StatefulWidget {
  final VoidCallback validatedToken;
  final VoidCallback reloadSolicitud;
  final String byRol;
  final int id;

  const SolicitudForm({
    super.key,
    required this.reloadSolicitud,
    required this.byRol,
    required this.id,
    required this.validatedToken,
  });

  @override
  SolicitudFormState createState() => SolicitudFormState();
}

class SolicitudFormState extends State<SolicitudForm> {
  List<String> solicitudes = [];
  final service = SolicitudesService();
  final _formKey = GlobalKey<FormState>();
  final _manzanaController = TextEditingController();
  final _villaController = TextEditingController();
  final _fechaController = TextEditingController();
  final _horaController = TextEditingController();

  String base64String = '';
  String? imageError;

  final List<String> medios = ['vehículo', 'caminando'];
  String? selectedMedio;
  String? selectedSolicitud;

  @override
  void initState() {
    super.initState();
    onlyByRol(widget.byRol);
  }

  Future<void> onlyByRol(String byRol) async {
    final rol = byRol == 'visitante' ? 'residente' : 'visitante';
    try {
      final data = await service.fetchOnlyByRol(rol);
      setState(() {
        solicitudes = data.map<String>((item) => item['cedula']).toList();
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al cargar la lista'),
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      setState(() {
        base64String = base64Image;
        imageError = null;
      });
    }
  }

  Future<void> _submitFrom() async {
    widget.validatedToken();
    try {
      final usuario = await service.fetchOnlyByCedula(selectedSolicitud!);
      final solicitudData = {
        'visitante_id':
            widget.byRol == 'visitante' ? widget.id : usuario['usuario_id'],
        'residente_id':
            widget.byRol == 'residente' ? widget.id : usuario['usuario_id'],
        'manzana': _manzanaController.text,
        'villa': _villaController.text,
        'fecha_visita': _fechaController.text,
        'hora_visita': _horaController.text,
        'medio_ingreso': selectedMedio,
        if (base64String.isNotEmpty) 'foto_placa': base64String,
      };
      await service.createSolicitud(solicitudData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Se ha creado la solicitud correctamente'),
        ),
      );
      widget.reloadSolicitud();
      Navigator.pop(context);
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al crear la solicitud'),
        ),
      );
    }
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
              DropdownButtonFormField<String>(
                hint: const Text('Residente'),
                value: selectedSolicitud,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedSolicitud = newValue;
                  });
                },
                items:
                    solicitudes.map<DropdownMenuItem<String>>((String value) {
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
                  onTap: _pickImage,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    alignment: Alignment.center,
                    color: Colors.grey[300],
                    child: Text(
                      base64String.isEmpty
                          ? "Seleccionar Imagen"
                          : "Imagen Seleccionada",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              if (imageError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    imageError!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _submitFrom();
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
