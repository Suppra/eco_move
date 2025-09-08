import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final ImagePicker _picker = ImagePicker();

  // Seleccionar imagen de la galería
  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error al seleccionar imagen: $e');
      return null;
    }
  }

  // Tomar foto con la cámara
  static Future<File?> takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error al tomar foto: $e');
      return null;
    }
  }

  // Subir imagen a Firebase Storage
  static Future<String?> uploadTransportImage(File imageFile, String transportId) async {
    try {
      final String fileName = 'transport_$transportId.jpg';
      final Reference ref = _storage.ref().child('transport_images').child(fileName);
      
      final UploadTask uploadTask = ref.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;
      
      final String downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error al subir imagen: $e');
      return null;
    }
  }

  // Eliminar imagen de Firebase Storage
  static Future<bool> deleteTransportImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('Error al eliminar imagen: $e');
      return false;
    }
  }

  // Mostrar opciones para seleccionar imagen
  static Future<File?> showImagePickerOptions() async {
    // Esta función será llamada desde el widget con showDialog
    return null;
  }
}
