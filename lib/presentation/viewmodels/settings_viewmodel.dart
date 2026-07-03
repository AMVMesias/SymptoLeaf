import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Modelos disponibles para clasificación
enum ModelType { 
  standard,     // plant_disease_model.onnx (actual)
  yolo11,       // plant_disease_yolo11.onnx (nuevo)
}

class SettingsViewModel extends ChangeNotifier {
  ModelType _modelType = ModelType.yolo11;  // ⭐ YOLO11 por defecto (igual que notebook)
  bool _initialized = false;

  ModelType get modelType => _modelType;
  bool get isInitialized => _initialized;
  
  // Nombre del archivo del modelo
  String get modelFileName {
    switch (_modelType) {
      case ModelType.standard:
        return 'plant_disease_model.onnx';
      case ModelType.yolo11:
        return 'plant_disease_yolo11.onnx';
    }
  }
  
  // Nombre legible del modelo
  String get modelDisplayName {
    switch (_modelType) {
      case ModelType.standard:
        return 'Modelo Estándar';
      case ModelType.yolo11:
        return 'YOLO11 (Mejorado)';
    }
  }

  SettingsViewModel() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Cargar modelo (por defecto YOLO11 si no hay preferencia guardada)
    final modelStr = prefs.getString('model_type') ?? 'yolo11';
    final newModelType = modelStr == 'yolo11' ? ModelType.yolo11 : ModelType.standard;
    
    // Solo notificar si realmente cambió el valor
    final changed = _modelType != newModelType;
    _modelType = newModelType;
    _initialized = true;
    
    if (changed) {
      notifyListeners();
    }
  }

  Future<void> setModelType(ModelType type) async {
    _modelType = type;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('model_type', type == ModelType.yolo11 ? 'yolo11' : 'standard');
    notifyListeners();
  }
}
