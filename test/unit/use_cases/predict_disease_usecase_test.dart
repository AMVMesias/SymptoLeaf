// =============================================================================
// TEST UNITARIO: PredictDiseaseUseCase
// =============================================================================
// Pruebas unitarias para el caso de uso de predicción de enfermedades.
//
// Fecha: 2026-02-04
// Fase: 2 - Pruebas Unitarias
// Autor: QA Team - SymptoLeaf
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:symptoleaf/domain/use_case/predict_disease_usecase.dart';
import 'package:symptoleaf/domain/entities/prediction_entity.dart';
import 'package:symptoleaf/data/repositories/base_repository.dart';

// Mock del Repository para tests
class MockBaseRepository implements BaseRepository {
  PredictionEntity? mockResult;
  Exception? mockError;

  @override
  Future<PredictionEntity> predictDisease(String imagePath) async {
    if (mockError != null) {
      throw mockError!;
    }
    return mockResult ?? PredictionEntity(
      className: 'Tomato_healthy',
      plant: 'Tomato',
      disease: 'healthy',
      confidence: 0.95,
      isHealthy: true,
      top3: [],
    );
  }
}

void main() {
  late MockBaseRepository mockRepository;
  late PredictDiseaseUseCase useCase;

  setUp(() {
    mockRepository = MockBaseRepository();
    useCase = PredictDiseaseUseCase(mockRepository);
  });

  group('PredictDiseaseUseCase - Validaciones de Entrada', () {
    // =========================================================================
    // TEST UT-PDU-001: Rechazar path vacío
    // =========================================================================
    test('UT-PDU-001: debería rechazar path de imagen vacío', () async {
      // Act & Assert
      expect(
        () => useCase.execute(''),
        throwsA(isA<Exception>()),
      );
    });

    // =========================================================================
    // TEST UT-PDU-002: Aceptar path válido
    // =========================================================================
    test('UT-PDU-002: debería aceptar path de imagen válido', () async {
      // Arrange
      mockRepository.mockResult = PredictionEntity(
        className: 'Tomato_healthy',
        plant: 'Tomato',
        disease: 'healthy',
        confidence: 0.95,
        isHealthy: true,
        top3: [],
      );

      // Act
      final result = await useCase.execute('/storage/DCIM/photo.jpg');

      // Assert
      expect(result, isNotNull);
      expect(result.className, equals('Tomato_healthy'));
    });
  });

  group('PredictDiseaseUseCase - Ejecución', () {
    // =========================================================================
    // TEST UT-PDU-003: Ejecutar predicción exitosa
    // =========================================================================
    test('UT-PDU-003: debería ejecutar predicción exitosa', () async {
      // Arrange
      mockRepository.mockResult = PredictionEntity(
        className: 'Tomato_Late_blight',
        plant: 'Tomato',
        disease: 'Late blight',
        confidence: 0.92,
        isHealthy: false,
        top3: [],
      );

      // Act
      final result = await useCase.execute('/path/to/image.jpg');

      // Assert
      expect(result, isA<PredictionEntity>());
      expect(result.className, equals('Tomato_Late_blight'));
      expect(result.confidence, equals(0.92));
    });

    // =========================================================================
    // TEST UT-PDU-004: Delegar al repositorio
    // =========================================================================
    test('UT-PDU-004: debería delegar al repositorio', () async {
      // Arrange
      mockRepository.mockResult = PredictionEntity(
        className: 'Potato_Early_blight',
        plant: 'Potato',
        disease: 'Early blight',
        confidence: 0.88,
        isHealthy: false,
        top3: [],
      );

      // Act
      final result = await useCase.execute('/image.jpg');

      // Assert
      expect(result.plant, equals('Potato'));
    });

    // =========================================================================
    // TEST UT-PDU-005: Propagar errores del repositorio
    // =========================================================================
    test('UT-PDU-005: debería propagar errores del repositorio', () async {
      // Arrange
      mockRepository.mockError = Exception('Error de inferencia');

      // Act & Assert
      expect(
        () => useCase.execute('/path/image.jpg'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('PredictDiseaseUseCase - Resultados', () {
    // =========================================================================
    // TEST UT-PDU-006: Identificar planta saludable
    // =========================================================================
    test('UT-PDU-006: debería identificar planta saludable', () async {
      // Arrange
      mockRepository.mockResult = PredictionEntity(
        className: 'Tomato_healthy',
        plant: 'Tomato',
        disease: 'healthy',
        confidence: 0.97,
        isHealthy: true,
        top3: [],
      );

      // Act
      final result = await useCase.execute('/healthy_plant.jpg');

      // Assert
      expect(result.isHealthy, isTrue);
    });

    // =========================================================================
    // TEST UT-PDU-007: Identificar planta enferma
    // =========================================================================
    test('UT-PDU-007: debería identificar planta enferma', () async {
      // Arrange
      mockRepository.mockResult = PredictionEntity(
        className: 'Apple_Scab',
        plant: 'Apple',
        disease: 'Scab',
        confidence: 0.85,
        isHealthy: false,
        top3: [],
      );

      // Act
      final result = await useCase.execute('/sick_plant.jpg');

      // Assert
      expect(result.isHealthy, isFalse);
    });

    // =========================================================================
    // TEST UT-PDU-008: Retornar confianza correcta
    // =========================================================================
    test('UT-PDU-008: debería retornar confianza correcta', () async {
      // Arrange
      mockRepository.mockResult = PredictionEntity(
        className: 'Grape_Black_rot',
        plant: 'Grape',
        disease: 'Black rot',
        confidence: 0.76,
        isHealthy: false,
        top3: [],
      );

      // Act
      final result = await useCase.execute('/grape.jpg');

      // Assert
      expect(result.confidence, equals(0.76));
    });

    // =========================================================================
    // TEST UT-PDU-009: Retornar nombre de planta
    // =========================================================================
    test('UT-PDU-009: debería retornar nombre de planta correcto', () async {
      // Arrange
      mockRepository.mockResult = PredictionEntity(
        className: 'Corn_Common_rust',
        plant: 'Corn',
        disease: 'Common rust',
        confidence: 0.91,
        isHealthy: false,
        top3: [],
      );

      // Act
      final result = await useCase.execute('/corn.jpg');

      // Assert
      expect(result.plant, equals('Corn'));
    });

    // =========================================================================
    // TEST UT-PDU-010: Retornar nombre de enfermedad
    // =========================================================================
    test('UT-PDU-010: debería retornar nombre de enfermedad correcto', () async {
      // Arrange
      mockRepository.mockResult = PredictionEntity(
        className: 'Pepper_bell_Bacterial_spot',
        plant: 'Pepper_bell',
        disease: 'Bacterial spot',
        confidence: 0.89,
        isHealthy: false,
        top3: [],
      );

      // Act
      final result = await useCase.execute('/pepper.jpg');

      // Assert
      expect(result.disease, equals('Bacterial spot'));
    });
  });
}
