import 'package:flutter/material.dart';
import 'package:frontend/functions/image_solicitud.dart';
import 'package:frontend/functions/image_state.dart';

class InsertImage extends StatelessWidget {
  final ImageState imageState;

  const InsertImage({
    super.key,
    required this.imageState,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await ImageSolicitud.pickImage(imageState: imageState);
      },
      child: AnimatedBuilder(
        animation: imageState,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            alignment: Alignment.center,
            color: Colors.grey[300],
            child: Text(
              imageState.Base64String.isEmpty
                  ? "Seleccionar Imagen"
                  : "Imagen Seleccionada",
              style: const TextStyle(fontSize: 18),
            ),
          );
        },
      ),
    );
  }
}
