import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/foto.dart';

/// ViewModel para la gestión de fotografías (MVVM)
/// Combina estado (antes FotoProvider) + acciones (antes FotoController)
class FotoViewModel extends ChangeNotifier {
  final List<Foto> _fotos = [];
  final ImagePicker _picker = ImagePicker();

  List<Foto> get fotos => _fotos;

  /// Captura una foto usando la cámara del dispositivo
  Future<void> tomarFoto(BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        final foto = Foto(
          path: image.path,
          nombre: image.name,
          description: 'Capturada desde cámara',
        );
        agregarFoto(foto);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto capturada exitosamente'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al capturar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Selecciona una foto de la galería del dispositivo
  Future<void> seleccionarGaleria(BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        final foto = Foto(
          path: image.path,
          nombre: image.name,
          description: 'Importada desde galería',
        );
        agregarFoto(foto);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto importada exitosamente'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al importar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Agrega una foto a la lista
  void agregarFoto(Foto foto) {
    _fotos.add(foto);
    notifyListeners();
  }

  /// Elimina una foto por índice
  void eliminarFoto(int index) {
    _fotos.removeAt(index);
    notifyListeners();
  }
}
