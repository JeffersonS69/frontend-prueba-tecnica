import 'package:flutter/material.dart';

class ViewTextfield extends StatelessWidget {
  final String labelText;
  final String controllerSolicitud;

  const ViewTextfield({
    super.key,
    required this.labelText,
    required this.controllerSolicitud,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: labelText,
      ),
      controller: TextEditingController(text: controllerSolicitud),
      style: const TextStyle(color: Colors.black87),
      enabled: false,
    );
  }
}
