// Datasource para modelo ONNX - Migrado: 12 Enero 2026 02:15 AM
// ⭐ Fix crítico: Reemplazó TFLite que no funcionaba
// Ahora el modo local funciona completamente offline con ONNX Runtime
// ⭐ 15 Enero 2026: Agregada validación con ML Kit para detectar si es planta
// ⭐ 9 Febrero 2026: Agregado soporte para múltiples modelos
// ⭐ 10 Febrero 2026: REMBG IMPLEMENTADO - Usa U2-Net para remover fondo (como notebook Python)
// Métodos: Original, Rembg, Rembg+Centro70%, Rembg+Centro50%

import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'package:image/image.dart' as img;
import 'dart:convert';
import '../models/prediction_model.dart';
import 'base_datasource.dart';
import 'plant_validator_service.dart';

class OnnxDataSource implements BaseDataSource {
  final String modelFileName;
  
  // Sesión para modelo de clasificación
  OrtSession? _session;
  Map<String, int>? _classes;
  Map<int, String>? _idxToClass;
  Map<String, dynamic>? _classesEs; // Traducciones al español
  bool _isInitialized = false;
  String? _currentModelFile;
  String? _inputName; // Nombre de entrada dinámico para diferentes modelos
  
  // ⭐ Sesión para U2-Net (Rembg - remoción de fondo)
  OrtSession? _u2netSession;
  bool _u2netInitialized = false;
  
  // Validador de plantas con ML Kit (offline)
  final PlantValidatorService _plantValidator = PlantValidatorService();
  
  OnnxDataSource({
    this.modelFileName = 'plant_disease_model.onnx',
  });

  Future<void> _initialize() async {
    // Reinicializar si cambió el modelo
    if (_isInitialized && _currentModelFile == modelFileName) return;
    
    // Limpiar sesión anterior si existe
    if (_session != null) {
      _session?.release();
      _session = null;
      _isInitialized = false;
    }

    try {
      print('🔄 Iniciando carga de modelo ONNX: $modelFileName');
      
      // Cargar modelo ONNX desde assets
      final modelData = await rootBundle.load('assets/modelo/$modelFileName');
      final modelBytes = modelData.buffer.asUint8List();
      print('   ✅ Modelo ONNX encontrado: ${modelBytes.length} bytes');
      
      // Crear sesión ONNX
      final sessionOptions = OrtSessionOptions();
      _session = OrtSession.fromBuffer(modelBytes, sessionOptions);
      print('   ✅ Sesión ONNX creada correctamente');
      
      // ⭐ OBTENER NOMBRE DE ENTRADA DINÁMICAMENTE
      // Diferentes modelos pueden tener diferentes nombres de entrada
      final inputNames = _session!.inputNames;
      _inputName = inputNames.first;
      print('   📥 Nombre de entrada del modelo: $_inputName');
      
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
      _currentModelFile = modelFileName;
      print('✅ Modelo ONNX inicializado: ${_classes!.length} clases (con traducciones ES)');
    } catch (e) {
      print('❌ Error al cargar modelo ONNX: $e');
      throw Exception('Error al cargar modelo ONNX: $e');
    }
  }
  
  /// ⭐ Inicializa el modelo U2-Net para remoción de fondo (Rembg)
  Future<void> _initializeU2Net() async {
    if (_u2netInitialized) return;
    
    try {
      print('🔄 Iniciando carga de modelo U2-Net (Rembg)...');
      
      final modelData = await rootBundle.load('assets/modelo/u2net.onnx');
      final modelBytes = modelData.buffer.asUint8List();
      print('   ✅ U2-Net encontrado: ${(modelBytes.length / 1024 / 1024).toStringAsFixed(1)} MB');
      
      final sessionOptions = OrtSessionOptions();
      _u2netSession = OrtSession.fromBuffer(modelBytes, sessionOptions);
      
      _u2netInitialized = true;
      print('✅ U2-Net (Rembg) inicializado correctamente');
    } catch (e) {
      print('⚠️ No se pudo cargar U2-Net, Rembg deshabilitado: $e');
      _u2netInitialized = false;
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
    await _initializeU2Net(); // Inicializar Rembg

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
      print('🔄 Probando métodos del notebook (con Rembg)...\n');
      
      // Leer imagen original
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      final imageOriginal = img.decodeImage(imageBytes);
      
      if (imageOriginal == null) {
        throw Exception('No se pudo decodificar la imagen');
      }

      // ⭐ PROBAR MÉTODOS COMO EN EL NOTEBOOK JUPYTER
      final metodosResultados = <Map<String, dynamic>>[];
      
      // 1. Original (sin preprocesamiento)
      print('   1️⃣ Probando: Original');
      await Future.delayed(Duration.zero);
      final resultOriginal = await _runInference(imageOriginal);
      metodosResultados.add({
        'nombre': 'Original',
        'confidence': resultOriginal['confidence'],
        'className': resultOriginal['className'],
        'plant': resultOriginal['plant'],
        'disease': resultOriginal['disease'],
        'isHealthy': resultOriginal['isHealthy'],
        'top3': resultOriginal['top3'],
      });
      
      // ⭐ ResNet9: Solo usar imagen original (sin Rembg)
      // ResNet9 NO fue entrenado con imágenes de fondo removido
      // → Rembg genera predicciones incorrectas con alta confianza que ganan sobre la correcta
      // → Regresión: 9/14 imágenes cambiaban de clase (64% afectadas)
      final isYoloModel = modelFileName.toLowerCase().contains('yolo');
      if (!isYoloModel) {
        print('\n   🏆 ResNet9: Usando resultado original (sin Rembg - mejor precisión)');
        return PredictionModel(
          className: resultOriginal['className'] as String,
          plant: resultOriginal['plant'] as String,
          disease: resultOriginal['disease'] as String,
          confidence: resultOriginal['confidence'] as double,
          isHealthy: resultOriginal['isHealthy'] as bool,
          top3: resultOriginal['top3'] as List<PredictionTop3Model>,
          bestMethod: 'Original',
        );
      }
      
      // ⭐ Métodos con Rembg (si está disponible) - Solo para YOLO
      if (_u2netInitialized) {
        // 2. Rembg (solo remoción de fondo)
        print('   2️⃣ Probando: Rembg (IA remoción fondo)');
        await Future.delayed(Duration.zero);
        final imgRembg = await _applyRembg(imageOriginal);
        if (imgRembg != null) {
          final resultRembg = await _runInference(imgRembg);
          metodosResultados.add({
            'nombre': 'Rembg',
            'confidence': resultRembg['confidence'],
            'className': resultRembg['className'],
            'plant': resultRembg['plant'],
            'disease': resultRembg['disease'],
            'isHealthy': resultRembg['isHealthy'],
            'top3': resultRembg['top3'],
          });
          
          // 3. Rembg + Centro 70%
          print('   3️⃣ Probando: Rembg + Centro 70%');
          await Future.delayed(Duration.zero);
          final imgRembg70 = _applyCenterCrop(imgRembg, 0.7);
          final resultRembg70 = await _runInference(imgRembg70);
          metodosResultados.add({
            'nombre': 'Rembg+Centro70%',
            'confidence': resultRembg70['confidence'],
            'className': resultRembg70['className'],
            'plant': resultRembg70['plant'],
            'disease': resultRembg70['disease'],
            'isHealthy': resultRembg70['isHealthy'],
            'top3': resultRembg70['top3'],
          });
          
          // 4. Rembg + Centro 50%
          print('   4️⃣ Probando: Rembg + Centro 50%');
          await Future.delayed(Duration.zero);
          final imgRembg50 = _applyCenterCrop(imgRembg, 0.5);
          final resultRembg50 = await _runInference(imgRembg50);
          metodosResultados.add({
            'nombre': 'Rembg+Centro50%',
            'confidence': resultRembg50['confidence'],
            'className': resultRembg50['className'],
            'plant': resultRembg50['plant'],
            'disease': resultRembg50['disease'],
            'isHealthy': resultRembg50['isHealthy'],
            'top3': resultRembg50['top3'],
          });
        }
      } else {
        // Fallback sin Rembg: usar recortes de centro
        print('   ⚠️ Rembg no disponible, usando recortes de centro');
        
        print('   2️⃣ Probando: Centro 70%');
        await Future.delayed(Duration.zero);
        final imgCentro70 = _applyCenterCrop(imageOriginal, 0.7);
        final resultCentro70 = await _runInference(imgCentro70);
        metodosResultados.add({
          'nombre': 'Centro 70%',
          'confidence': resultCentro70['confidence'],
          'className': resultCentro70['className'],
          'plant': resultCentro70['plant'],
          'disease': resultCentro70['disease'],
          'isHealthy': resultCentro70['isHealthy'],
          'top3': resultCentro70['top3'],
        });
        
        print('   3️⃣ Probando: Centro 50%');
        await Future.delayed(Duration.zero);
        final imgCentro50 = _applyCenterCrop(imageOriginal, 0.5);
        final resultCentro50 = await _runInference(imgCentro50);
        metodosResultados.add({
          'nombre': 'Centro 50%',
          'confidence': resultCentro50['confidence'],
          'className': resultCentro50['className'],
          'plant': resultCentro50['plant'],
          'disease': resultCentro50['disease'],
          'isHealthy': resultCentro50['isHealthy'],
          'top3': resultCentro50['top3'],
        });
      }
      
      // ⭐ ENCONTRAR EL MEJOR (mayor confianza) - Como: max(resultados, key=lambda x: x[3])
      metodosResultados.sort((a, b) => (b['confidence'] as double).compareTo(a['confidence'] as double));
      final mejor = metodosResultados.first;
      
      print('\n   🏆 GANADOR: ${mejor['nombre']} → ${mejor['plant']} - ${mejor['disease']} (${((mejor['confidence'] as double) * 100).toStringAsFixed(1)}%)');
      print('   📊 Comparación:');
      for (var i = 0; i < metodosResultados.length; i++) {
        final m = metodosResultados[i];
        final icon = i == 0 ? '🥇' : i == 1 ? '🥈' : i == 2 ? '🥉' : '  ';
        print('      $icon ${m['nombre']}: ${((m['confidence'] as double) * 100).toStringAsFixed(1)}%');
      }
      
      // Retornar el mejor resultado
      return PredictionModel(
        className: mejor['className'] as String,
        plant: mejor['plant'] as String,
        disease: mejor['disease'] as String,
        confidence: mejor['confidence'] as double,
        isHealthy: mejor['isHealthy'] as bool,
        top3: mejor['top3'] as List<PredictionTop3Model>,
        bestMethod: mejor['nombre'] as String,
      );
    } catch (e) {
      print('❌ Error en predicción: $e');
      throw Exception('Error en predicción: $e');
    }
  }
  
  /// ⭐ Aplica Rembg (U2-Net) para remover fondo de la imagen
  /// Similar a: rembg.remove() en Python
  Future<img.Image?> _applyRembg(img.Image image) async {
    if (_u2netSession == null) return null;
    
    try {
      final originalWidth = image.width;
      final originalHeight = image.height;
      
      // U2-Net espera entrada de 320x320
      final resized = img.copyResize(image, width: 320, height: 320);
      
      // Preparar input: [1, 3, 320, 320] en formato NCHW, normalizado 0-1
      final input = Float32List(1 * 3 * 320 * 320);
      
      for (int y = 0; y < 320; y++) {
        for (int x = 0; x < 320; x++) {
          final pixel = resized.getPixel(x, y);
          final idx = y * 320 + x;
          // Normalizar y ordenar en NCHW
          input[0 * 320 * 320 + idx] = pixel.r / 255.0;
          input[1 * 320 * 320 + idx] = pixel.g / 255.0;
          input[2 * 320 * 320 + idx] = pixel.b / 255.0;
        }
      }
      
      final inputOrt = OrtValueTensor.createTensorWithDataList(
        input,
        [1, 3, 320, 320],
      );
      
      final runOptions = OrtRunOptions();
      final outputs = _u2netSession!.run(runOptions, {'input.1': inputOrt});
      
      // Obtener máscara de salida (usar primera salida)
      final outputValue = outputs[0]?.value;
      List<double> maskData;
      
      if (outputValue is List<List<List<List<double>>>>) {
        // Formato [1, 1, 320, 320]
        maskData = outputValue[0][0].expand((row) => row).toList();
      } else if (outputValue is List<List<List<double>>>) {
        // Formato [1, 320, 320]
        maskData = outputValue[0].expand((row) => row).toList();
      } else {
        print('⚠️ Formato de salida U2-Net no reconocido');
        inputOrt.release();
        runOptions.release();
        for (var o in outputs) { o?.release(); }
        return null;
      }
      
      inputOrt.release();
      runOptions.release();
      for (var o in outputs) { o?.release(); }
      
      // Redimensionar máscara al tamaño original
      final maskImage = img.Image(width: 320, height: 320);
      for (int y = 0; y < 320; y++) {
        for (int x = 0; x < 320; x++) {
          final maskValue = (maskData[y * 320 + x].clamp(0.0, 1.0) * 255).toInt();
          maskImage.setPixel(x, y, img.ColorRgba8(maskValue, maskValue, maskValue, 255));
        }
      }
      final maskResized = img.copyResize(maskImage, width: originalWidth, height: originalHeight);
      
      // Aplicar máscara: fondo blanco donde máscara < threshold
      final result = img.Image(width: originalWidth, height: originalHeight);
      int minX = originalWidth, maxX = 0, minY = originalHeight, maxY = 0;
      
      for (int y = 0; y < originalHeight; y++) {
        for (int x = 0; x < originalWidth; x++) {
          final maskPixel = maskResized.getPixel(x, y);
          final maskValue = maskPixel.r / 255.0;  // Usar canal R como valor de máscara
          
          if (maskValue > 0.5) {
            // Objeto detectado - mantener píxel original
            result.setPixel(x, y, image.getPixel(x, y));
            // Actualizar bounding box
            minX = math.min(minX, x);
            maxX = math.max(maxX, x);
            minY = math.min(minY, y);
            maxY = math.max(maxY, y);
          } else {
            // Fondo - poner blanco
            result.setPixel(x, y, img.ColorRgba8(255, 255, 255, 255));
          }
        }
      }
      
      // Recortar a bounding box del objeto + padding
      if (maxX > minX && maxY > minY) {
        final padding = 10;
        final cropX = math.max(0, minX - padding);
        final cropY = math.max(0, minY - padding);
        final cropW = math.min(originalWidth - cropX, maxX - minX + 2 * padding);
        final cropH = math.min(originalHeight - cropY, maxY - minY + 2 * padding);
        
        return img.copyCrop(result, x: cropX, y: cropY, width: cropW, height: cropH);
      }
      
      return result;
    } catch (e) {
      print('⚠️ Error en Rembg: $e');
      return null;
    }
  }
  
  /// Aplica recorte de centro con el porcentaje especificado
  img.Image _applyCenterCrop(img.Image image, double percentage) {
    final h = image.height;
    final w = image.width;
    final marginH = ((1 - percentage) / 2 * h).toInt();
    final marginW = ((1 - percentage) / 2 * w).toInt();
    
    return img.copyCrop(
      image,
      x: marginW,
      y: marginH,
      width: (w * percentage).toInt(),
      height: (h * percentage).toInt(),
    );
  }
  
  /// Preprocesa la imagen como lo hace ultralytics para YOLO clasificación:
  /// 1. Resize manteniendo aspecto (lado más corto = targetSize) con interpolación bilineal
  /// 2. CenterCrop a targetSize x targetSize
  img.Image _preprocessYolo(img.Image image, int targetSize) {
    final w = image.width;
    final h = image.height;
    
    // Paso 1: Resize manteniendo aspecto ratio (lado más corto = targetSize)
    final scale = targetSize / (w < h ? w : h);
    final newW = (w * scale).round();
    final newH = (h * scale).round();
    
    // Usar interpolación bilineal (igual que ultralytics/torchvision Resize)
    final resized = img.copyResize(
      image, 
      width: newW, 
      height: newH,
      interpolation: img.Interpolation.linear,
    );
    
    // Paso 2: CenterCrop a targetSize x targetSize
    final cropX = (newW - targetSize) ~/ 2;
    final cropY = (newH - targetSize) ~/ 2;
    return img.copyCrop(resized, x: cropX, y: cropY, width: targetSize, height: targetSize);
  }

  /// Ejecuta la inferencia del modelo con una imagen procesada
  Future<Map<String, dynamic>> _runInference(img.Image image) async {
    // Detectar si es modelo YOLO (usa NCHW) o estándar (usa NHWC)
    final isYoloModel = modelFileName.toLowerCase().contains('yolo');
    
    // YOLO: resize+CenterCrop (como ultralytics), Estándar: stretch resize (como TF)
    final resized = isYoloModel
        ? _preprocessYolo(image, 256)
        : img.copyResize(image, width: 256, height: 256);
    
    // YOLO usa NCHW [1, 3, 256, 256], Estándar usa NHWC [1, 256, 256, 3]
    final inputShape = isYoloModel ? [1, 3, 256, 256] : [1, 256, 256, 3];
    final input = Float32List(1 * 256 * 256 * 3);
    
    if (isYoloModel) {
      // Formato NCHW: [batch, channels, height, width]
      // Los canales van primero, luego los píxeles
      for (int y = 0; y < 256; y++) {
        for (int x = 0; x < 256; x++) {
          final pixel = resized.getPixel(x, y);
          final idx = y * 256 + x;
          // Canal R en posición [0, 0:256, 0:256]
          input[0 * 256 * 256 + idx] = pixel.r / 255.0;
          // Canal G en posición [0, 256*256:256*256*2]
          input[1 * 256 * 256 + idx] = pixel.g / 255.0;
          // Canal B en posición [0, 256*256*2:256*256*3]
          input[2 * 256 * 256 + idx] = pixel.b / 255.0;
        }
      }
    } else {
      // Formato NHWC: [batch, height, width, channels]
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
    }

    // Crear input tensor
    final inputOrt = OrtValueTensor.createTensorWithDataList(
      input,
      inputShape,
    );

    // Ejecutar inferencia con nombre de entrada dinámico
    final runOptions = OrtRunOptions();
    final inputs = {_inputName!: inputOrt};
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

    // Retornar resultado como Map
    return {
      'className': className,
      'plant': plant,
      'disease': disease,
      'confidence': topConfidence,
      'isHealthy': isHealthy,
      'top3': top3,
    };
  }

  void dispose() {
    _session?.release();
    _session = null;
    _isInitialized = false;
    
    // Limpiar U2-Net también
    _u2netSession?.release();
    _u2netSession = null;
    _u2netInitialized = false;
  }
}
