import 'package:flutter/material.dart';
import 'package:frontend/functions/image_solicitud.dart';
import 'package:frontend/functions/image_state.dart';
import 'package:frontend/functions/submit_handler.dart';
import 'package:frontend/services/solicitudes_service.dart';

class UpdateForm extends StatefulWidget {
  final VoidCallback reloadSolicitud;
  final ImageState imageState;
  final int solicitudId;
  final String fecha;
  final String hora;
  final String medio;
  final String? foto;

  const UpdateForm({
    super.key,
    required this.reloadSolicitud,
    required this.solicitudId,
    required this.fecha,
    required this.hora,
    required this.medio,
    this.foto,
    required this.imageState,
  });

  @override
  UpdateFormState createState() => UpdateFormState();
}

class UpdateFormState extends State<UpdateForm> {
  final service = SolicitudesService();
  final _formKey = GlobalKey<FormState>();
  final _fechaController = TextEditingController();
  final _horaController = TextEditingController();
  final List<String> medios = ['vehículo', 'caminando'];
  String? selectedMedio;

  @override
  void initState() {
    super.initState();
    _fechaController.text = widget.fecha;
    _horaController.text = widget.hora;
    selectedMedio = widget.medio;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actualizar solicitud'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
              if (selectedMedio == 'vehículo')
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
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await FormSubmitHandler.updateSubmit(
                        context: context,
                        solicitudId: widget.solicitudId,
                        fechaController: _fechaController,
                        horaController: _horaController,
                        selectedMedio: selectedMedio!,
                        base64String: widget.imageState.Base64String,
                        service: service,
                        reloadSolicitud: widget.reloadSolicitud);
                  }
                },
                child: const Text('Actualizar solicitud'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
