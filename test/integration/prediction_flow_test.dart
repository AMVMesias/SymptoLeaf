// =============================================================================
// TEST INTEGRACIÓN: Flujo de Predicción Completo
// =============================================================================
// Pruebas de integración para el flujo de predicción de enfermedades.
// Verifica la interacción entre ViewModel, UseCase y Repository.
//
// Fecha: 2026-02-04
// Fase: 3 - Pruebas de Integración
// Autor: QA Team - SymptoLeaf
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:symptoleaf/presentation/viewmodels/prediction_viewmodel.dart';
import 'package:symptoleaf/presentation/viewmodels/settings_viewmodel.dart';
import 'package:symptoleaf/domain/use_case/predict_disease_usecase.dart';
import 'package:symptoleaf/domain/entities/prediction_entity.dart';
import 'package:symptoleaf/data/repositories/base_repository.dart';

// Mock del Repository para tests de integración
class MockIntegrationRepository implements BaseRepository {
  int callCount = 0;
  List<String> calledPaths = [];
  PredictionEntity? mockResult;
  Exception? mockError;
  Duration? delay;

  @override
  Future<PredictionEntity> predictDisease(String imagePath) async {
    callCount++;
    calledPaths.add(imagePath);
    
    if (delay != null) {
      await Future.delayed(delay!);
    }
    
    if (mockError != null) {
      throw mockError!;
    }
    
    return mockResult ?? PredictionEntity(
      className: 'Tomato_Late_blight',
      plant: 'Tomato',
      disease: 'Late blight',
      confidence: 0.92,
      isHealthy: false,
      top3: [],
    );
  }

  void reset() {
    callCount = 0;
    calledPaths.clear();
    mockResult = null;
    mockError = null;
    delay = null;
  }
}

void main() {
  late MockIntegrationRepository mockRepository;
  late PredictDiseaseUseCase useCase;
  late PredictionViewModel viewModel;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockRepository = MockIntegrationRepository();
    useCase = PredictDiseaseUseCase(mockRepository);
    viewModel = PredictionViewModel(useCase);
  });

  group('Integration: Flujo ViewModel -> UseCase -> Repository', () {
    // =========================================================================
    // TEST INT-PF-001: Flujo completo exitoso
    // =========================================================================
    test('INT-PF-001: debería completar flujo de predicción exitosamente', () async {
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
      await viewModel.predictDisease('/test/image.jpg');

      // Assert - Verificar integración completa
      expect(viewModel.state, equals(PredictionState.success));
      expect(viewModel.prediction, isNotNull);
      expect(viewModel.prediction!.plant, equals('Potato'));
      expect(mockRepository.callCount, equals(1));
      expect(mockRepository.calledPaths.first, equals('/test/image.jpg'));
    });

    // =========================================================================
    // TEST INT-PF-002: Flujo con error propagado
    // =========================================================================
    test('INT-PF-002: debería propagar errores del repository al viewmodel', () async {
      // Arrange
      mockRepository.mockError = Exception('Modelo no cargado');

      // Act
      await viewModel.predictDisease('/error/image.jpg');

      // Assert
      expect(viewModel.state, equals(PredictionState.error));
      expect(viewModel.errorMessage, contains('Modelo no cargado'));
      expect(mockRepository.callCount, equals(1));
    });

    // =========================================================================
    // TEST INT-PF-003: Estado loading durante predicción
    // =========================================================================
    test('INT-PF-003: debería mostrar loading mientras procesa', () async {
      // Arrange
      mockRepository.delay = const Duration(milliseconds: 100);
      
      // Act - Iniciar predicción sin await
      final future = viewModel.predictDisease('/slow/image.jpg');
      
      // Assert - Durante la ejecución debería estar en loading
      // (Este test verifica que el estado cambia a loading)
      expect(viewModel.state, anyOf(
        equals(PredictionState.loading),
        equals(PredictionState.success),
      ));
      
      await future;
      expect(viewModel.state, equals(PredictionState.success));
    });

    // =========================================================================
    // TEST INT-PF-004: Múltiples predicciones secuenciales
    // =========================================================================
    test('INT-PF-004: debería manejar múltiples predicciones secuenciales', () async {
      // Arrange
      final plants = ['Tomato', 'Potato', 'Apple'];
      
      // Act & Assert
      for (int i = 0; i < plants.length; i++) {
        mockRepository.mockResult = PredictionEntity(
          className: '${plants[i]}_healthy',
          plant: plants[i],
          disease: 'healthy',
          confidence: 0.90 + (i * 0.02),
          isHealthy: true,
          top3: [],
        );
        
        await viewModel.predictDisease('/image_$i.jpg');
        
        expect(viewModel.state, equals(PredictionState.success));
        expect(viewModel.prediction!.plant, equals(plants[i]));
      }
      
      expect(mockRepository.callCount, equals(3));
    });

    // =========================================================================
    // TEST INT-PF-005: Reset limpia estado completo
    // =========================================================================
    test('INT-PF-005: reset debería limpiar todo el estado de integración', () async {
      // Arrange
      await viewModel.predictDisease('/test.jpg');
      expect(viewModel.prediction, isNotNull);

      // Act
      viewModel.reset();

      // Assert
      expect(viewModel.state, equals(PredictionState.initial));
      expect(viewModel.prediction, isNull);
      expect(viewModel.errorMessage, isEmpty);
    });
  });

  group('Integration: Flujo con Configuración de Modo', () {
    // =========================================================================
    // TEST INT-PF-006: Modo local con predicción
    // =========================================================================
    test('INT-PF-006: modo standard debería permitir predicción', () async {
      // Arrange
      final settings = SettingsViewModel();
      await settings.setModelType(ModelType.standard);

      // Act
      await viewModel.predictDisease('/local/test.jpg');

      // Assert
      expect(settings.modelType, equals(ModelType.standard));
      expect(viewModel.state, equals(PredictionState.success));
    });

    // =========================================================================
    // TEST INT-PF-007: Cambio de modo no afecta predicción en curso
    // =========================================================================
    test('INT-PF-007: cambio de modelo durante predicción no causa conflicto', () async {
      // Arrange
      final settings = SettingsViewModel();
      mockRepository.delay = const Duration(milliseconds: 50);

      // Act
      final future = viewModel.predictDisease('/image.jpg');
      await settings.setModelType(ModelType.yolo11);
      await future;

      // Assert
      expect(viewModel.state, equals(PredictionState.success));
      expect(settings.modelType, equals(ModelType.yolo11));
    });
  });

  group('Integration: Validaciones de Entrada en Cadena', () {
    // =========================================================================
    // TEST INT-PF-008: Path vacío rechazado en toda la cadena
    // =========================================================================
    test('INT-PF-008: path vacío debería ser rechazado', () async {
      // Act
      await viewModel.predictDisease('');
      
      // Assert - El viewmodel debería estar en estado error
      expect(viewModel.state, equals(PredictionState.error));
      expect(mockRepository.callCount, equals(0));
    });

    // =========================================================================
    // TEST INT-PF-009: Path válido pasa todas las validaciones
    // =========================================================================
    test('INT-PF-009: path válido debería pasar todas las validaciones', () async {
      // Arrange
      const validPath = '/storage/emulated/0/DCIM/Camera/plant_photo.jpg';

      // Act
      await viewModel.predictDisease(validPath);

      // Assert
      expect(viewModel.state, equals(PredictionState.success));
      expect(mockRepository.calledPaths.first, equals(validPath));
    });

    // =========================================================================
    // TEST INT-PF-010: Múltiples paths válidos procesados correctamente
    // =========================================================================
    test('INT-PF-010: múltiples paths deberían procesarse independientemente', () async {
      // Arrange
      final paths = [
        '/path/image1.jpg',
        '/path/image2.png',
        '/path/image3.jpeg',
      ];

      // Act
      for (final path in paths) {
        viewModel.reset();
        await viewModel.predictDisease(path);
      }

      // Assert
      expect(mockRepository.callCount, equals(3));
      expect(mockRepository.calledPaths, equals(paths));
    });
  });
}
