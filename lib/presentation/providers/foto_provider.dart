import 'package:flutter/material.dart';
import '../models/foto.dart';

class FotoProvider extends ChangeNotifier {
  final List<Foto> _fotos = [];
  List<Foto> get fotos => _fotos;

  void agregarFoto(Foto foto) {
    _fotos.add(foto);
    notifyListeners();
  }

  void eliminarFoto(int index) {
    _fotos.removeAt(index);
    notifyListeners();
  }
}
