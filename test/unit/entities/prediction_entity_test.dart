// =============================================================================
// TEST UNITARIO: PredictionEntity
// =============================================================================
// Pruebas unitarias para la entidad de predicción.
//
// Fecha: 2026-02-04
// Fase: 2 - Pruebas Unitarias
// Autor: QA Team - SymptoLeaf
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:symptoleaf/domain/entities/prediction_entity.dart';

void main() {
  group('PredictionEntity - Creación', () {
    // =========================================================================
    // TEST UT-PE-001: Crear entidad con todos los campos
    // =========================================================================
    test('UT-PE-001: debería crear entidad con todos los campos', () {
      // Arrange & Act
      final entity = PredictionEntity(
        className: 'Tomato_Late_blight',
        plant: 'Tomato',
        disease: 'Late blight',
        confidence: 0.95,
        isHealthy: false,
        top3: [],
      );

      // Assert
      expect(entity.className, equals('Tomato_Late_blight'));
      expect(entity.plant, equals('Tomato'));
      expect(entity.disease, equals('Late blight'));
      expect(entity.confidence, equals(0.95));
      expect(entity.isHealthy, isFalse);
    });

    // =========================================================================
    // TEST UT-PE-002: Crear entidad de planta saludable
    // =========================================================================
    test('UT-PE-002: debería crear entidad de planta saludable', () {
      // Arrange & Act
      final entity = PredictionEntity(
        className: 'Tomato_healthy',
        plant: 'Tomato',
        disease: 'healthy',
        confidence: 0.98,
        isHealthy: true,
        top3: [],
      );

      // Assert
      expect(entity.isHealthy, isTrue);
    });

    // =========================================================================
    // TEST UT-PE-003: Crear entidad con top3
    // =========================================================================
    test('UT-PE-003: debería crear entidad con top3 predicciones', () {
      // Arrange
      final top3 = [
        PredictionTop3(
          className: 'Tomato_Late_blight',
          plant: 'Tomato',
          disease: 'Late blight',
          confidence: 0.85,
          isHealthy: false,
        ),
        PredictionTop3(
          className: 'Tomato_Early_blight',
          plant: 'Tomato',
          disease: 'Early blight',
          confidence: 0.10,
          isHealthy: false,
        ),
        PredictionTop3(
          className: 'Tomato_healthy',
          plant: 'Tomato',
          disease: 'healthy',
          confidence: 0.05,
          isHealthy: true,
        ),
      ];

      // Act
      final entity = PredictionEntity(
        className: 'Tomato_Late_blight',
        plant: 'Tomato',
        disease: 'Late blight',
        confidence: 0.85,
        isHealthy: false,
        top3: top3,
      );

      // Assert
      expect(entity.top3.length, equals(3));
      expect(entity.top3[0].confidence, greaterThan(entity.top3[1].confidence));
    });
  });

  group('PredictionEntity - Validaciones', () {
    // =========================================================================
    // TEST UT-PE-004: Confianza entre 0 y 1
    // =========================================================================
    test('UT-PE-004: debería aceptar confianza entre 0 y 1', () {
      // Arrange & Act
      final entityLow = PredictionEntity(
        className: 'Test',
        plant: 'Test',
        disease: 'Test',
        confidence: 0.0,
        isHealthy: false,
        top3: [],
      );
      final entityHigh = PredictionEntity(
        className: 'Test',
        plant: 'Test',
        disease: 'Test',
        confidence: 1.0,
        isHealthy: false,
        top3: [],
      );

      // Assert
      expect(entityLow.confidence, greaterThanOrEqualTo(0));
      expect(entityHigh.confidence, lessThanOrEqualTo(1));
    });

    // =========================================================================
    // TEST UT-PE-005: Planta requerida
    // =========================================================================
    test('UT-PE-005: debería tener planta', () {
      // Arrange & Act
      final entity = PredictionEntity(
        className: 'Potato_Early_blight',
        plant: 'Potato',
        disease: 'Early blight',
        confidence: 0.88,
        isHealthy: false,
        top3: [],
      );

      // Assert
      expect(entity.plant, isNotEmpty);
    });
  });

  group('PredictionTop3 - Creación', () {
    // =========================================================================
    // TEST UT-PE-006: Crear PredictionTop3
    // =========================================================================
    test('UT-PE-006: debería crear PredictionTop3 correctamente', () {
      // Arrange & Act
      final prediction = PredictionTop3(
        className: 'Apple_Scab',
        plant: 'Apple',
        disease: 'Scab',
        confidence: 0.75,
        isHealthy: false,
      );

      // Assert
      expect(prediction.className, equals('Apple_Scab'));
      expect(prediction.plant, equals('Apple'));
      expect(prediction.disease, equals('Scab'));
      expect(prediction.confidence, equals(0.75));
      expect(prediction.isHealthy, isFalse);
    });

    // =========================================================================
    // TEST UT-PE-007: PredictionTop3 saludable
    // =========================================================================
    test('UT-PE-007: debería crear PredictionTop3 saludable', () {
      // Arrange & Act
      final prediction = PredictionTop3(
        className: 'Grape_healthy',
        plant: 'Grape',
        disease: 'healthy',
        confidence: 0.92,
        isHealthy: true,
      );

      // Assert
      expect(prediction.isHealthy, isTrue);
    });
  });

  group('PredictionEntity - Casos de Uso', () {
    // =========================================================================
    // TEST UT-PE-008: Diferentes plantas
    // =========================================================================
    test('UT-PE-008: debería soportar diferentes plantas', () {
      // Arrange
      final plantas = ['Tomato', 'Potato', 'Apple', 'Grape', 'Corn'];

      // Act & Assert
      for (final planta in plantas) {
        final entity = PredictionEntity(
          className: '${planta}_healthy',
          plant: planta,
          disease: 'healthy',
          confidence: 0.90,
          isHealthy: true,
          top3: [],
        );
        expect(entity.plant, equals(planta));
      }
    });

    // =========================================================================
    // TEST UT-PE-009: Confianza alta vs baja
    // =========================================================================
    test('UT-PE-009: debería diferenciar confianza alta y baja', () {
      // Arrange
      final highConfidence = PredictionEntity(
        className: 'Test',
        plant: 'Test',
        disease: 'Test',
        confidence: 0.95,
        isHealthy: false,
        top3: [],
      );
      final lowConfidence = PredictionEntity(
        className: 'Test',
        plant: 'Test',
        disease: 'Test',
        confidence: 0.35,
        isHealthy: false,
        top3: [],
      );

      // Assert
      expect(highConfidence.confidence, greaterThan(0.5));
      expect(lowConfidence.confidence, lessThan(0.5));
    });

    // =========================================================================
    // TEST UT-PE-010: Lista top3 vacía válida
    // =========================================================================
    test('UT-PE-010: debería aceptar lista top3 vacía', () {
      // Arrange & Act
      final entity = PredictionEntity(
        className: 'Test',
        plant: 'Test',
        disease: 'Test',
        confidence: 0.80,
        isHealthy: false,
        top3: [],
      );

      // Assert
      expect(entity.top3, isEmpty);
      expect(entity.top3, isA<List<PredictionTop3>>());
    });
  });
}
