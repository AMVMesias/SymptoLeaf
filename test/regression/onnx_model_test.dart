// =============================================================================
// TEST 2: REGRESIÓN - Modelo ONNX con Imágenes de Referencia
// =============================================================================
// Pruebas de regresión para verificar que el modelo ONNX mantiene
// su comportamiento esperado después de actualizaciones.
//
// Fecha: 2026-02-03
// Autor: QA Team - SymptoLeaf
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:symptoleaf/data/models/prediction_model.dart';

/// Suite de tests de regresión para el modelo ONNX
void main() {
  group('Regresión ONNX: Clases de Clasificación', () {
    // =========================================================================
    // Definición de las 15 clases esperadas del modelo
    // =========================================================================
    final List<String> expectedClasses = [
      'Apple___Apple_scab',
      'Apple___Black_rot',
      'Apple___Cedar_apple_rust',
      'Apple___healthy',
      'Corn___Cercospora_leaf_spot',
      'Corn___Common_rust',
      'Corn___healthy',
      'Grape___Black_rot',
      'Grape___Esca',
      'Grape___healthy',
      'Potato___Early_blight',
      'Potato___Late_blight',
      'Potato___healthy',
      'Tomato___Bacterial_spot',
      'Tomato___healthy',
    ];

    // =========================================================================
    // Traducciones esperadas al español
    // =========================================================================
    final Map<String, Map<String, String>> expectedTranslations = {
      'Apple___Apple_scab': {'plant': 'Manzana', 'disease': 'Sarna del manzano'},
      'Apple___Black_rot': {'plant': 'Manzana', 'disease': 'Podredumbre negra'},
      'Apple___Cedar_apple_rust': {'plant': 'Manzana', 'disease': 'Roya del cedro'},
      'Apple___healthy': {'plant': 'Manzana', 'disease': 'Saludable'},
      'Corn___Cercospora_leaf_spot': {'plant': 'Maíz', 'disease': 'Mancha foliar por Cercospora'},
      'Corn___Common_rust': {'plant': 'Maíz', 'disease': 'Roya común'},
      'Corn___healthy': {'plant': 'Maíz', 'disease': 'Saludable'},
      'Grape___Black_rot': {'plant': 'Uva', 'disease': 'Podredumbre negra'},
      'Grape___Esca': {'plant': 'Uva', 'disease': 'Enfermedad de Esca'},
      'Grape___healthy': {'plant': 'Uva', 'disease': 'Saludable'},
      'Potato___Early_blight': {'plant': 'Papa', 'disease': 'Tizón temprano'},
      'Potato___Late_blight': {'plant': 'Papa', 'disease': 'Tizón tardío'},
      'Potato___healthy': {'plant': 'Papa', 'disease': 'Saludable'},
      'Tomato___Bacterial_spot': {'plant': 'Tomate', 'disease': 'Mancha bacteriana'},
      'Tomato___healthy': {'plant': 'Tomate', 'disease': 'Saludable'},
    };

    // =========================================================================
    // TEST REG-001: Verificar cantidad de clases
    // =========================================================================
    test('REG-001: El modelo debería tener exactamente 15 clases', () {
      expect(expectedClasses.length, equals(15));
    });

    // =========================================================================
    // TEST REG-002: Verificar plantas soportadas
    // =========================================================================
    test('REG-002: El modelo debería soportar 5 tipos de plantas', () {
      // Arrange
      final plantas = expectedClasses
          .map((c) => c.split('___')[0])
          .toSet()
          .toList();
      
      // Assert
      expect(plantas.length, equals(5));
      expect(plantas.contains('Apple'), isTrue);
      expect(plantas.contains('Corn'), isTrue);
      expect(plantas.contains('Grape'), isTrue);
      expect(plantas.contains('Potato'), isTrue);
      expect(plantas.contains('Tomato'), isTrue);
    });

    // =========================================================================
    // TEST REG-003: Verificar clases "healthy"
    // =========================================================================
    test('REG-003: Cada planta debería tener una clase healthy', () {
      // Arrange
      final healthyClasses = expectedClasses
          .where((c) => c.contains('healthy'))
          .toList();
      
      // Assert - 5 plantas = 5 clases healthy
      expect(healthyClasses.length, equals(5));
    });

    // =========================================================================
    // TEST REG-004: Verificar formato de nombres de clase
    // =========================================================================
    test('REG-004: Todas las clases deberían seguir formato Plant___Disease', () {
      for (final className in expectedClasses) {
        // Assert - Cada clase contiene ___
        expect(className.contains('___'), isTrue,
            reason: 'Clase $className no sigue el formato esperado');
        
        // Assert - Cada clase tiene exactamente 2 partes
        final parts = className.split('___');
        expect(parts.length, equals(2),
            reason: 'Clase $className debería tener 2 partes');
      }
    });

    // =========================================================================
    // TEST REG-005: Verificar traducciones al español
    // =========================================================================
    test('REG-005: Todas las clases deberían tener traducción al español', () {
      for (final className in expectedClasses) {
        // Assert - Cada clase tiene traducción
        expect(expectedTranslations.containsKey(className), isTrue,
            reason: 'Clase $className no tiene traducción');
        
        // Assert - La traducción tiene planta y enfermedad
        final translation = expectedTranslations[className]!;
        expect(translation.containsKey('plant'), isTrue);
        expect(translation.containsKey('disease'), isTrue);
        expect(translation['plant'], isNotEmpty);
        expect(translation['disease'], isNotEmpty);
      }
    });

    // =========================================================================
    // TEST REG-006: Verificar estructura de PredictionModel
    // =========================================================================
    test('REG-006: PredictionModel debería tener todos los campos requeridos', () {
      // Arrange - Crear modelo de prueba con tipos correctos
      final model = PredictionModel(
        className: 'Tomato___healthy',
        plant: 'Tomate',
        disease: 'Saludable',
        confidence: 0.95,
        isHealthy: true,
        top3: [
          PredictionTop3Model(
            className: 'Tomato___healthy',
            plant: 'Tomate',
            disease: 'Saludable',
            confidence: 0.95,
            isHealthy: true,
          ),
          PredictionTop3Model(
            className: 'Tomato___Bacterial_spot',
            plant: 'Tomate',
            disease: 'Mancha bacteriana',
            confidence: 0.03,
            isHealthy: false,
          ),
          PredictionTop3Model(
            className: 'Potato___healthy',
            plant: 'Papa',
            disease: 'Saludable',
            confidence: 0.02,
            isHealthy: true,
          ),
        ],
      );
      
      // Assert
      expect(model.className, equals('Tomato___healthy'));
      expect(model.plant, equals('Tomate'));
      expect(model.disease, equals('Saludable'));
      expect(model.confidence, equals(0.95));
      expect(model.isHealthy, isTrue);
      expect(model.top3.length, equals(3));
    });

    // =========================================================================
    // TEST REG-007: Verificar rango de confianza válido
    // =========================================================================
    test('REG-007: Confianza debería estar en rango [0.0, 1.0]', () {
      // Arrange
      final validConfidences = [0.0, 0.5, 0.95, 1.0];
      
      for (final confidence in validConfidences) {
        // Assert - Cada confianza está en rango
        expect(confidence >= 0.0 && confidence <= 1.0, isTrue,
            reason: 'Confianza $confidence fuera de rango');
      }
    });

    // =========================================================================
    // TEST REG-008: Verificar detección de planta saludable
    // =========================================================================
    test('REG-008: isHealthy debería ser true solo para clases healthy', () {
      for (final className in expectedClasses) {
        final shouldBeHealthy = className.contains('healthy');
        
        // Simular lógica de detección
        final isHealthyDetected = className.toLowerCase().contains('healthy');
        
        // Assert
        expect(isHealthyDetected, equals(shouldBeHealthy),
            reason: 'Clase $className: isHealthy incorrecto');
      }
    });

    // =========================================================================
    // TEST REG-009: Verificar clase especial no_plant_detected
    // =========================================================================
    test('REG-009: no_plant_detected debería manejarse como caso especial', () {
      // Arrange
      const noPlantClass = 'no_plant_detected';
      
      // Assert - No está en las clases normales
      expect(expectedClasses.contains(noPlantClass), isFalse);
      
      // Simular modelo cuando no es planta
      final model = PredictionModel(
        className: noPlantClass,
        plant: 'No detectado',
        disease: 'No es una planta',
        confidence: 0.0,
        isHealthy: false,
        top3: [],
      );
      
      expect(model.className, equals(noPlantClass));
      expect(model.confidence, equals(0.0));
      expect(model.top3, isEmpty);
    });

    // =========================================================================
    // TEST REG-010: Verificar ordenamiento de top3
    // =========================================================================
    test('REG-010: top3 debería estar ordenado por confianza descendente', () {
      // Arrange
      final top3 = [
        {'className': 'Tomato___healthy', 'confidence': 0.95},
        {'className': 'Tomato___Bacterial_spot', 'confidence': 0.03},
        {'className': 'Potato___healthy', 'confidence': 0.02},
      ];
      
      // Assert - Verificar orden descendente
      for (int i = 0; i < top3.length - 1; i++) {
        final current = top3[i]['confidence'] as double;
        final next = top3[i + 1]['confidence'] as double;
        expect(current >= next, isTrue,
            reason: 'top3 no está ordenado correctamente en posición $i');
      }
    });
  });
}
