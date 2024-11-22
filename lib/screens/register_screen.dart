import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/services/solicitudes_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final service = SolicitudesService();
  final _formKey = GlobalKey<FormState>();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _passwordController = TextEditingController();
  final List<String> rol = ['visitante', 'residente'];

  String? selectedRol;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _submitForm() async {
    try {
      final formData = {
        'nombres': _nombresController.text,
        'apellidos': _apellidosController.text,
        'cedula': _cedulaController.text,
        'password': _passwordController.text,
        'rol': selectedRol,
      };
      await service.createUser(formData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Se ha registrado la solicitud correctamente'),
        ),
      );
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al registrar la solicitud'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar usuario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                hint: const Text('Rol'),
                value: selectedRol,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedRol = newValue;
                  });
                },
                items: rol.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    {
                      return 'Este campo es obligatorio';
                    }
                  }

                  return null;
                },
              ),
              TextFormField(
                controller: _nombresController,
                decoration: const InputDecoration(labelText: 'Nombres'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    {
                      return 'Este campo es obligatorio';
                    }
                  }

                  return null;
                },
              ),
              TextFormField(
                controller: _apellidosController,
                decoration: const InputDecoration(labelText: 'Apellidos'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    {
                      return 'Este campo es obligatorio';
                    }
                  }

                  return null;
                },
              ),
              TextFormField(
                controller: _cedulaController,
                decoration: const InputDecoration(labelText: 'Cédula'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    {
                      return 'Este campo es obligatorio';
                    }
                  } else if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                    return 'Solo números y máximo 10 dígitos';
                  }

                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10)
                ],
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    {
                      return 'Este campo es obligatorio';
                    }
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _submitForm();
                  }
                },
                child: const Text('Crear'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
