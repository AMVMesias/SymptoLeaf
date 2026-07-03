// =============================================================================
// TEST UNITARIO: PredictionViewModel
// =============================================================================
// Pruebas unitarias para el ViewModel de predicciones.
//
// Fecha: 2026-02-04
// Fase: 2 - Pruebas Unitarias
// Autor: QA Team - SymptoLeaf
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:symptoleaf/presentation/viewmodels/prediction_viewmodel.dart';
import 'package:symptoleaf/domain/use_case/predict_disease_usecase.dart';
import 'package:symptoleaf/domain/entities/prediction_entity.dart';
import 'package:symptoleaf/data/repositories/base_repository.dart';

// Mock del UseCase para tests
class MockPredictDiseaseUseCase extends PredictDiseaseUseCase {
  PredictionEntity? mockResult;
  Exception? mockError;
  
  MockPredictDiseaseUseCase() : super(MockBaseRepository());

  @override
  Future<PredictionEntity> execute(String imagePath) async {
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

// Mock del Repository
class MockBaseRepository implements BaseRepository {
  @override
  Future<PredictionEntity> predictDisease(String imagePath) async {
    return PredictionEntity(
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
  late MockPredictDiseaseUseCase mockUseCase;
  late PredictionViewModel viewModel;

  setUp(() {
    mockUseCase = MockPredictDiseaseUseCase();
    viewModel = PredictionViewModel(mockUseCase);
  });

  group('PredictionViewModel - Estado Inicial', () {
    // =========================================================================
    // TEST UT-PVM-001: Estado inicial es initial
    // =========================================================================
    test('UT-PVM-001: debería iniciar en estado initial', () {
      // Assert
      expect(viewModel.state, equals(PredictionState.initial));
    });

    // =========================================================================
    // TEST UT-PVM-002: No tiene predicción inicial
    // =========================================================================
    test('UT-PVM-002: no debería tener predicción inicialmente', () {
      // Assert
      expect(viewModel.prediction, isNull);
    });

    // =========================================================================
    // TEST UT-PVM-003: Mensaje de error vacío inicialmente
    // =========================================================================
    test('UT-PVM-003: mensaje de error debería estar vacío inicialmente', () {
      // Assert
      expect(viewModel.errorMessage, isEmpty);
    });
  });

  group('PredictionViewModel - Predicción Exitosa', () {
    // =========================================================================
    // TEST UT-PVM-004: Predicción exitosa cambia estado a success
    // =========================================================================
    test('UT-PVM-004: debería cambiar a success tras predicción exitosa', () async {
      // Arrange
      mockUseCase.mockResult = PredictionEntity(
        className: 'Tomato_Late_blight',
        plant: 'Tomato',
        disease: 'Late blight',
        confidence: 0.92,
        isHealthy: false,
        top3: [],
      );

      // Act
      await viewModel.predictDisease('/path/to/image.jpg');

      // Assert
      expect(viewModel.state, equals(PredictionState.success));
      expect(viewModel.prediction, isNotNull);
      expect(viewModel.prediction!.className, equals('Tomato_Late_blight'));
    });

    // =========================================================================
    // TEST UT-PVM-005: Guarda la predicción correctamente
    // =========================================================================
    test('UT-PVM-005: debería guardar la predicción correctamente', () async {
      // Arrange
      mockUseCase.mockResult = PredictionEntity(
        className: 'Potato_Early_blight',
        plant: 'Potato',
        disease: 'Early blight',
        confidence: 0.88,
        isHealthy: false,
        top3: [],
      );

      // Act
      await viewModel.predictDisease('/image.jpg');

      // Assert
      expect(viewModel.prediction!.plant, equals('Potato'));
      expect(viewModel.prediction!.confidence, equals(0.88));
    });
  });

  group('PredictionViewModel - Manejo de Errores', () {
    // =========================================================================
    // TEST UT-PVM-006: Error cambia estado a error
    // =========================================================================
    test('UT-PVM-006: debería cambiar a error si falla la predicción', () async {
      // Arrange
      mockUseCase.mockError = Exception('Error de inferencia');

      // Act
      await viewModel.predictDisease('/path/to/image.jpg');

      // Assert
      expect(viewModel.state, equals(PredictionState.error));
      expect(viewModel.errorMessage, contains('Error de inferencia'));
    });

    // =========================================================================
    // TEST UT-PVM-007: Mensaje de error se guarda
    // =========================================================================
    test('UT-PVM-007: debería guardar el mensaje de error', () async {
      // Arrange
      mockUseCase.mockError = Exception('Modelo no cargado');

      // Act
      await viewModel.predictDisease('/test.jpg');

      // Assert
      expect(viewModel.errorMessage, isNotEmpty);
    });
  });

  group('PredictionViewModel - Reset', () {
    // =========================================================================
    // TEST UT-PVM-008: Reset limpia el estado
    // =========================================================================
    test('UT-PVM-008: reset debería volver a estado initial', () async {
      // Arrange
      await viewModel.predictDisease('/image.jpg');
      expect(viewModel.state, equals(PredictionState.success));

      // Act
      viewModel.reset();

      // Assert
      expect(viewModel.state, equals(PredictionState.initial));
      expect(viewModel.prediction, isNull);
    });

    // =========================================================================
    // TEST UT-PVM-009: Reset limpia error
    // =========================================================================
    test('UT-PVM-009: reset debería limpiar mensaje de error', () async {
      // Arrange
      mockUseCase.mockError = Exception('Error');
      await viewModel.predictDisease('/test.jpg');
      expect(viewModel.errorMessage, isNotEmpty);

      // Act
      viewModel.reset();

      // Assert
      expect(viewModel.errorMessage, isEmpty);
    });

    // =========================================================================
    // TEST UT-PVM-010: Reset limpia predicción anterior
    // =========================================================================
    test('UT-PVM-010: reset debería limpiar predicción anterior', () async {
      // Arrange
      mockUseCase.mockError = null;
      await viewModel.predictDisease('/image.jpg');
      expect(viewModel.prediction, isNotNull);

      // Act
      viewModel.reset();

      // Assert
      expect(viewModel.prediction, isNull);
    });
  });
}
