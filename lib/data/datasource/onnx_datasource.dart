// Datasource para modelo ONNX - Migrado: 12 Enero 2026 02:15 AM
// ⭐ Fix crítico: Reemplazó TFLite que no funcionaba
// Ahora el modo local funciona completamente offline con ONNX Runtime
// ⭐ 15 Enero 2026: Agregada validación con ML Kit para detectar si es planta

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'package:image/image.dart' as img;
import 'dart:convert';
import '../models/prediction_model.dart';
import 'base_datasource.dart';
import 'plant_validator_service.dart';

class OnnxDataSource implements BaseDataSource {
  OrtSession? _session;
  Map<String, int>? _classes;
  Map<int, String>? _idxToClass;
  Map<String, dynamic>? _classesEs; // Traducciones al español
  bool _isInitialized = false;
  
  // Validador de plantas con ML Kit (offline)
  final PlantValidatorService _plantValidator = PlantValidatorService();

  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      print('🔄 Iniciando carga de modelo ONNX...');
      
      // Cargar modelo ONNX desde assets
      final modelData = await rootBundle.load('assets/modelo/plant_disease_model.onnx');
      final modelBytes = modelData.buffer.asUint8List();
      print('   ✅ Modelo ONNX encontrado: ${modelBytes.length} bytes');
      
      // Crear sesión ONNX
      final sessionOptions = OrtSessionOptions();
      _session = OrtSession.fromBuffer(modelBytes, sessionOptions);
      print('   ✅ Sesión ONNX creada correctamente');
      
      // Cargar clases (índices)
      final classesJson = await rootBundle.loadString('assets/modelo/clases.json');
      _classes = Map<String, int>.from(json.decode(classesJson));
      _idxToClass = _classes!.map((key, value) => MapEntry(value, key));
      
      // Cargar traducciones al español
      final classesEsJson = await rootBundle.loadString('assets/modelo/clases_es.json');
      _classesEs = json.decode(classesEsJson);
      
      // Inicializar validador de plantas ML Kit
      await _plantValidator.initialize();
      
      _isInitialized = true;
      print('✅ Modelo ONNX inicializado: ${_classes!.length} clases (con traducciones ES)');
    } catch (e) {
      print('❌ Error al cargar modelo ONNX: $e');
      throw Exception('Error al cargar modelo ONNX: $e');
    }
  }

  // Helper para obtener traducción
  Map<String, dynamic> _getTranslation(String className) {
    if (_classesEs != null && _classesEs!.containsKey(className)) {
      return Map<String, dynamic>.from(_classesEs![className]);
    }
    // Fallback al inglés si no hay traducción
    final parts = className.split('___');
    return {
      'plant': parts[0],
      'disease': parts.length > 1 ? parts[1] : 'Unknown',
      'is_healthy': parts.length > 1 && parts[1].toLowerCase().contains('healthy'),
    };
  }

  @override
  Future<PredictionModel> predictDisease(String imagePath) async {
    await _initialize();

    try {
      print('📸 Procesando imagen: $imagePath');
      
      // ⭐ VALIDACIÓN CON ML KIT (OFFLINE): Verificar si es una planta
      print('🔍 Validando imagen con ML Kit (offline)...');
      final isPlant = await _plantValidator.isPlantImage(imagePath);
      
      if (!isPlant) {
        print('❌ ML Kit indica que NO es una planta');
        return PredictionModel(
          className: 'no_plant_detected',
          plant: 'No detectado',
          disease: 'No es una planta',
          confidence: 0.0,
          isHealthy: false,
          top3: [],
        );
      }
      
      print('✅ ML Kit confirma que es una planta, procediendo con clasificación...');
      
      // Leer y procesar imagen para ONNX
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) {
        throw Exception('No se pudo decodificar la imagen');
      }

      // Redimensionar a 256x256
      final resized = img.copyResize(image, width: 256, height: 256);
      
      // Convertir a tensor float32 [1, 256, 256, 3]
      final inputShape = [1, 256, 256, 3];
      final input = Float32List(1 * 256 * 256 * 3);
      
      int pixelIndex = 0;
      for (int y = 0; y < 256; y++) {
        for (int x = 0; x < 256; x++) {
          final pixel = resized.getPixel(x, y);
          // Normalizar 0-255 → 0-1
          input[pixelIndex++] = pixel.r / 255.0;
          input[pixelIndex++] = pixel.g / 255.0;
          input[pixelIndex++] = pixel.b / 255.0;
        }
      }

      // Crear input tensor
      final inputOrt = OrtValueTensor.createTensorWithDataList(
        input,
        inputShape,
      );

      // Ejecutar inferencia
      final runOptions = OrtRunOptions();
      final inputs = {'input': inputOrt};
      final outputs = _session!.run(runOptions, inputs);
      
      // Obtener resultado
      final output = outputs[0]?.value as List<List<double>>;
      final probabilities = output[0];
      
      inputOrt.release();
      runOptions.release();
      for (var element in outputs) {
        element?.release();
      }

      // Encontrar top 3
      final indexed = List.generate(
        probabilities.length,
        (i) => {'index': i, 'confidence': probabilities[i]},
      );
      indexed.sort((a, b) => (b['confidence'] as double).compareTo(a['confidence'] as double));
      final top3Idx = indexed.take(3).toList();

      // Predicción principal (con traducción al español)
      final topIdx = top3Idx[0]['index'] as int;
      final topConfidence = top3Idx[0]['confidence'] as double;
      final className = _idxToClass![topIdx]!;
      final translation = _getTranslation(className);
      final plant = translation['plant'] as String;
      final disease = translation['disease'] as String;
      final isHealthy = translation['is_healthy'] as bool;

      // Top 3 (con traducciones al español)
      final top3 = top3Idx.map((item) {
        final idx = item['index'] as int;
        final cls = _idxToClass![idx]!;
        final trans = _getTranslation(cls);
        return PredictionTop3Model(
          className: cls,
          plant: trans['plant'] as String,
          disease: trans['disease'] as String,
          confidence: item['confidence'] as double,
          isHealthy: trans['is_healthy'] as bool,
        );
      }).toList();

      print('✅ Predicción: $plant - $disease (${(topConfidence * 100).toStringAsFixed(1)}%)');

      return PredictionModel(
        className: className,
        plant: plant,
        disease: disease,
        confidence: topConfidence,
        isHealthy: isHealthy,
        top3: top3,
      );
    } catch (e) {
      print('❌ Error en predicción: $e');
      throw Exception('Error en predicción: $e');
    }
  }

  void dispose() {
    _session?.release();
    _session = null;
    _isInitialized = false;
  }
}
