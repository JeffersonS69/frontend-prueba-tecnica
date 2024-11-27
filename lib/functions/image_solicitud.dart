import 'dart:convert';
import 'dart:io';
import 'package:frontend/functions/image_state.dart';
import 'package:image_picker/image_picker.dart';

class ImageSolicitud {
  static Future<void> pickImage({
    required ImageState imageState,
  }) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      imageState.base64String = base64Image;
      imageState.error = null;

    }
  }
}
