// Datasource para modelo ONNX - Migrado: 12 Enero 2026 02:15 AM
// ⭐ Mejorado: 15 Enero 2026 - Optimización de rendimiento y gestión de recursos

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // Para compute
import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'package:image/image.dart' as img;
import 'dart:convert';
import '../models/prediction_model.dart';
import 'base_datasource.dart';

/// Argumentos para el procesamiento de imagen en un Isolate
class _ImageProcessingArgs {
  final Uint8List bytes;
  final int width;
  final int height;

  _ImageProcessingArgs(this.bytes, this.width, this.height);
}

class OnnxDataSource implements BaseDataSource {
  OrtSession? _session;
  Map<String, int>? _classes;
  Map<int, String>? _idxToClass;
  Map<String, dynamic>? _classesEs; // Traducciones al español
  bool _isInitialized = false;

  // Dimensiones del modelo
  static const int _modelInputWidth = 256;
  static const int _modelInputHeight = 256;

  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      final watch = Stopwatch()..start();
      debugPrint('🔄 Iniciando carga de modelo ONNX...');

      // Cargar modelo ONNX desde assets
      final modelData = await rootBundle.load(
        'assets/modelo/plant_disease_model.onnx',
      );
      final modelBytes = modelData.buffer.asUint8List();

      // Crear sesión ONNX con opciones optimizadas
      final sessionOptions = OrtSessionOptions();
      // Se puede configurar el nivel de hilos si es necesario:
      // sessionOptions.setIntraOpNumThreads(2);

      _session = OrtSession.fromBuffer(modelBytes, sessionOptions);

      // Cargar clases (índices)
      final classesJson = await rootBundle.loadString(
        'assets/modelo/clases.json',
      );
      _classes = Map<String, int>.from(json.decode(classesJson));
      _idxToClass = _classes!.map((key, value) => MapEntry(value, key));

      // Cargar traducciones al español
      final classesEsJson = await rootBundle.loadString(
        'assets/modelo/clases_es.json',
      );
      _classesEs = json.decode(classesEsJson);

      _isInitialized = true;
      watch.stop();
      debugPrint(
        '✅ Modelo ONNX inicializado en ${watch.elapsedMilliseconds}ms: ${_classes!.length} clases',
      );
    } catch (e) {
      debugPrint('❌ Error al cargar modelo ONNX: $e');
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
      'disease': parts.length > 1 ? parts[1].replaceAll('_', ' ') : 'Unknown',
      'is_healthy':
          parts.length > 1 && parts[1].toLowerCase().contains('healthy'),
    };
  }

  @override
  Future<PredictionModel> predictDisease(String imagePath) async {
    final totalWatch = Stopwatch()..start();
    await _initialize();

    OrtValueTensor? inputOrt;
    OrtRunOptions? runOptions;
    List<OrtValue?>? outputs;

    try {
      debugPrint('📸 Procesando imagen para ONNX: $imagePath');

      // 1. Leer imagen
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();

      // 2. Preprocesamiento en un Isolate (CPU intensive)
      final preprocessWatch = Stopwatch()..start();
      final inputData = await compute(
        _preprocessImage,
        _ImageProcessingArgs(imageBytes, _modelInputWidth, _modelInputHeight),
      );
      preprocessWatch.stop();
      debugPrint(
        '   ⚡ Preprocesamiento (Isolate): ${preprocessWatch.elapsedMilliseconds}ms',
      );

      // 3. Preparar entrada para ONNX
      final inputShape = [1, _modelInputWidth, _modelInputHeight, 3];
      inputOrt = OrtValueTensor.createTensorWithDataList(inputData, inputShape);

      // 4. Ejecutar inferencia
      final inferenceWatch = Stopwatch()..start();
      runOptions = OrtRunOptions();
      final inputs = {'input': inputOrt};
      outputs = _session!.run(runOptions, inputs);
      inferenceWatch.stop();
      debugPrint(
        '   🧠 Inferencia ONNX: ${inferenceWatch.elapsedMilliseconds}ms',
      );

      // 5. Post-procesamiento de resultados
      final postWatch = Stopwatch()..start();
      final output = outputs[0]?.value as List<List<double>>;
      final probabilities = output[0];

      // Encontrar top 3
      final indexed = List.generate(
        probabilities.length,
        (i) => _PredictionScore(i, probabilities[i]),
      );
      indexed.sort((a, b) => b.confidence.compareTo(a.confidence));
      final top3Scores = indexed.take(3).toList();

      // Mapear a modelos con traducciones
      final top3 = top3Scores.map((score) {
        final className = _idxToClass![score.index]!;
        final trans = _getTranslation(className);
        return PredictionTop3Model(
          className: className,
          plant: trans['plant'] as String,
          disease: trans['disease'] as String,
          confidence: score.confidence,
          isHealthy: trans['is_healthy'] as bool,
        );
      }).toList();

      final mainPrediction = top3[0];
      postWatch.stop();
      totalWatch.stop();

      debugPrint(
        '✅ Predicción completada en ${totalWatch.elapsedMilliseconds}ms',
      );
      debugPrint(
        '   🏆 Resultado: ${mainPrediction.plant} - ${mainPrediction.disease} (${(mainPrediction.confidence * 100).toStringAsFixed(1)}%)',
      );

      return PredictionModel(
        className: mainPrediction.className,
        plant: mainPrediction.plant,
        disease: mainPrediction.disease,
        confidence: mainPrediction.confidence,
        isHealthy: mainPrediction.isHealthy,
        top3: top3,
      );
    } catch (e, stack) {
      debugPrint('❌ Error en predicción ONNX: $e');
      debugPrint(stack.toString());
      throw Exception('Error al realizar la predicción local: $e');
    } finally {
      // Liberar recursos nativos SIEMPRE
      inputOrt?.release();
      runOptions?.release();
      if (outputs != null) {
        for (var element in outputs) {
          element?.release();
        }
      }
    }
  }

  /// Función estática para preprocesar la imagen en un Isolate
  static Float32List _preprocessImage(_ImageProcessingArgs args) {
    final image = img.decodeImage(args.bytes);
    if (image == null) throw Exception('No se pudo decodificar la imagen');

    // Redimensionar
    final resized = img.copyResize(
      image,
      width: args.width,
      height: args.height,
      interpolation:
          img.Interpolation.linear, // Balance entre velocidad y calidad
    );

    // Convertir a Float32List [W, H, C]
    final floatList = Float32List(args.width * args.height * 3);

    int bufferIndex = 0;
    for (int y = 0; y < args.height; y++) {
      for (int x = 0; x < args.width; x++) {
        final pixel = resized.getPixel(x, y);
        // Normalización estándar 0-1
        // Nota: Si el modelo fue entrenado con Imagenet o similar,
        // podría requerir resta de media y división por desviación estándar.
        floatList[bufferIndex++] = pixel.r / 255.0;
        floatList[bufferIndex++] = pixel.g / 255.0;
        floatList[bufferIndex++] = pixel.b / 255.0;
      }
    }
    return floatList;
  }

  void dispose() {
    _session?.release();
    _session = null;
    _isInitialized = false;
  }
}

/// Helper para ordenar predicciones
class _PredictionScore {
  final int index;
  final double confidence;
  _PredictionScore(this.index, this.confidence);
}
