// =============================================================================
// TEST UNITARIO: PredictionModel
// =============================================================================
// Pruebas unitarias para el modelo de predicción de enfermedades.
//
// Fecha: 2026-02-04
// Fase: 2 - Pruebas Unitarias
// Autor: QA Team - SymptoLeaf
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:symptoleaf/data/models/prediction_model.dart';

void main() {
  group('PredictionModel - Construcción', () {
    // =========================================================================
    // TEST UT-PM-001: Crear modelo con datos válidos
    // =========================================================================
    test('UT-PM-001: debería crear modelo con todos los campos requeridos', () {
      // Arrange & Act
      final model = PredictionModel(
        className: 'Tomato___Bacterial_spot',
        plant: 'Tomate',
        disease: 'Mancha bacteriana',
        confidence: 0.95,
        isHealthy: false,
        top3: [],
      );

      // Assert
      expect(model.className, equals('Tomato___Bacterial_spot'));
      expect(model.plant, equals('Tomate'));
      expect(model.disease, equals('Mancha bacteriana'));
      expect(model.confidence, equals(0.95));
      expect(model.isHealthy, isFalse);
      expect(model.top3, isEmpty);
    });

    // =========================================================================
    // TEST UT-PM-002: Crear modelo con top3
    // =========================================================================
    test('UT-PM-002: debería crear modelo con lista top3 poblada', () {
      // Arrange
      final top3Items = [
        PredictionTop3Model(
          className: 'Tomato___Bacterial_spot',
          plant: 'Tomate',
          disease: 'Mancha bacteriana',
          confidence: 0.95,
          isHealthy: false,
        ),
        PredictionTop3Model(
          className: 'Tomato___healthy',
          plant: 'Tomate',
          disease: 'Saludable',
          confidence: 0.03,
          isHealthy: true,
        ),
        PredictionTop3Model(
          className: 'Potato___Early_blight',
          plant: 'Papa',
          disease: 'Tizón temprano',
          confidence: 0.02,
          isHealthy: false,
        ),
      ];

      // Act
      final model = PredictionModel(
        className: 'Tomato___Bacterial_spot',
        plant: 'Tomate',
        disease: 'Mancha bacteriana',
        confidence: 0.95,
        isHealthy: false,
        top3: top3Items,
      );

      // Assert
      expect(model.top3.length, equals(3));
      expect(model.top3[0].confidence, greaterThan(model.top3[1].confidence));
      expect(model.top3[1].confidence, greaterThan(model.top3[2].confidence));
    });

    // =========================================================================
    // TEST UT-PM-003: Modelo saludable
    // =========================================================================
    test('UT-PM-003: debería identificar correctamente planta saludable', () {
      // Arrange & Act
      final healthyModel = PredictionModel(
        className: 'Apple___healthy',
        plant: 'Manzana',
        disease: 'Saludable',
        confidence: 0.98,
        isHealthy: true,
        top3: [],
      );

      // Assert
      expect(healthyModel.isHealthy, isTrue);
      expect(healthyModel.disease, equals('Saludable'));
    });
  });

  group('PredictionModel - Validación de Confianza', () {
    // =========================================================================
    // TEST UT-PM-004: Confianza en límite inferior
    // =========================================================================
    test('UT-PM-004: debería aceptar confianza de 0.0', () {
      // Arrange & Act
      final model = PredictionModel(
        className: 'no_plant_detected',
        plant: 'No detectado',
        disease: 'No es una planta',
        confidence: 0.0,
        isHealthy: false,
        top3: [],
      );

      // Assert
      expect(model.confidence, equals(0.0));
      expect(model.confidence, greaterThanOrEqualTo(0.0));
    });

    // =========================================================================
    // TEST UT-PM-005: Confianza en límite superior
    // =========================================================================
    test('UT-PM-005: debería aceptar confianza de 1.0', () {
      // Arrange & Act
      final model = PredictionModel(
        className: 'Corn___healthy',
        plant: 'Maíz',
        disease: 'Saludable',
        confidence: 1.0,
        isHealthy: true,
        top3: [],
      );

      // Assert
      expect(model.confidence, equals(1.0));
      expect(model.confidence, lessThanOrEqualTo(1.0));
    });

    // =========================================================================
    // TEST UT-PM-006: Confianza en rango válido
    // =========================================================================
    test('UT-PM-006: confianza debería estar en rango [0.0, 1.0]', () {
      // Arrange
      final confidences = [0.0, 0.25, 0.5, 0.75, 0.95, 1.0];

      for (final conf in confidences) {
        // Act
        final model = PredictionModel(
          className: 'Test___class',
          plant: 'Test',
          disease: 'Test',
          confidence: conf,
          isHealthy: false,
          top3: [],
        );

        // Assert
        expect(model.confidence, greaterThanOrEqualTo(0.0),
            reason: 'Confianza $conf debería ser >= 0.0');
        expect(model.confidence, lessThanOrEqualTo(1.0),
            reason: 'Confianza $conf debería ser <= 1.0');
      }
    });
  });

  group('PredictionModel - Conversión toEntity', () {
    // =========================================================================
    // TEST UT-PM-007: Conversión a entidad de dominio
    // =========================================================================
    test('UT-PM-007: debería convertir correctamente a PredictionEntity', () {
      // Arrange
      final model = PredictionModel(
        className: 'Grape___Black_rot',
        plant: 'Uva',
        disease: 'Podredumbre negra',
        confidence: 0.87,
        isHealthy: false,
        top3: [
          PredictionTop3Model(
            className: 'Grape___Black_rot',
            plant: 'Uva',
            disease: 'Podredumbre negra',
            confidence: 0.87,
            isHealthy: false,
          ),
        ],
      );

      // Act
      final entity = model.toEntity();

      // Assert
      expect(entity.className, equals(model.className));
      expect(entity.plant, equals(model.plant));
      expect(entity.disease, equals(model.disease));
      expect(entity.confidence, equals(model.confidence));
      expect(entity.isHealthy, equals(model.isHealthy));
      expect(entity.top3.length, equals(model.top3.length));
    });
  });

  group('PredictionModel - Serialización toJson', () {
    // =========================================================================
    // TEST UT-PM-008: Serialización a JSON
    // =========================================================================
    test('UT-PM-008: debería serializar correctamente a JSON', () {
      // Arrange
      final model = PredictionModel(
        className: 'Potato___Late_blight',
        plant: 'Papa',
        disease: 'Tizón tardío',
        confidence: 0.92,
        isHealthy: false,
        top3: [],
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json['prediction']['class'], equals('Potato___Late_blight'));
      expect(json['prediction']['plant'], equals('Papa'));
      expect(json['prediction']['disease'], equals('Tizón tardío'));
      expect(json['prediction']['confidence'], equals(0.92));
      expect(json['prediction']['is_healthy'], isFalse);
    });
  });

  group('PredictionTop3Model', () {
    // =========================================================================
    // TEST UT-PM-009: Top3 model básico
    // =========================================================================
    test('UT-PM-009: debería crear PredictionTop3Model correctamente', () {
      // Arrange & Act
      final top3 = PredictionTop3Model(
        className: 'Corn___Common_rust',
        plant: 'Maíz',
        disease: 'Roya común',
        confidence: 0.78,
        isHealthy: false,
      );

      // Assert
      expect(top3.className, equals('Corn___Common_rust'));
      expect(top3.plant, equals('Maíz'));
      expect(top3.disease, equals('Roya común'));
      expect(top3.confidence, equals(0.78));
      expect(top3.isHealthy, isFalse);
    });

    // =========================================================================
    // TEST UT-PM-010: Top3 conversión a entidad
    // =========================================================================
    test('UT-PM-010: debería convertir Top3Model a Top3Entity', () {
      // Arrange
      final top3Model = PredictionTop3Model(
        className: 'Apple___Apple_scab',
        plant: 'Manzana',
        disease: 'Sarna del manzano',
        confidence: 0.65,
        isHealthy: false,
      );

      // Act
      final top3Entity = top3Model.toEntity();

      // Assert
      expect(top3Entity.className, equals(top3Model.className));
      expect(top3Entity.confidence, equals(top3Model.confidence));
    });
  });
}
