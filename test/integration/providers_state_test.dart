// =============================================================================
// TEST INTEGRACIÓN: Providers y Estado Global
// =============================================================================
// Pruebas de integración para verificar la interacción entre providers
// y el manejo del estado global de la aplicación.
// Adaptado para la versión actual con ModelType (standard/yolo11).
//
// Fecha: 2026-02-04
// Fase: 3 - Pruebas de Integración
// Autor: QA Team - SymptoLeaf
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:symptoleaf/presentation/providers/foto_provider.dart';
import 'package:symptoleaf/presentation/viewmodels/settings_viewmodel.dart';
import 'package:symptoleaf/presentation/viewmodels/prediction_viewmodel.dart';
import 'package:symptoleaf/presentation/viewmodels/gemini_viewmodel.dart';
import 'package:symptoleaf/presentation/models/foto.dart';
import 'package:symptoleaf/domain/use_case/predict_disease_usecase.dart';
import 'package:symptoleaf/domain/entities/prediction_entity.dart';
import 'package:symptoleaf/data/repositories/base_repository.dart';

// Mock del Repository
class MockRepository implements BaseRepository {
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
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Integration: FotoProvider con Predicción', () {
    // =========================================================================
    // TEST INT-PS-001: Foto agregada disponible para predicción
    // =========================================================================
    test('INT-PS-001: foto agregada debería estar disponible para predicción', () async {
      // Arrange
      final fotoProvider = FotoProvider();
      final mockRepo = MockRepository();
      final useCase = PredictDiseaseUseCase(mockRepo);
      final predictionVM = PredictionViewModel(useCase);

      // Act
      fotoProvider.agregarFoto(Foto(
        path: '/test/plant.jpg',
        nombre: 'plant.jpg',
        description: 'Planta de tomate',
      ));

      // Usar el path de la foto para predicción
      final fotoPath = fotoProvider.fotos.first.path;
      await predictionVM.predictDisease(fotoPath);

      // Assert
      expect(fotoProvider.fotos.length, equals(1));
      expect(predictionVM.state, equals(PredictionState.success));
      expect(predictionVM.prediction, isNotNull);
    });

    // =========================================================================
    // TEST INT-PS-002: Múltiples fotos para análisis secuencial
    // =========================================================================
    test('INT-PS-002: múltiples fotos deberían analizarse secuencialmente', () async {
      // Arrange
      final fotoProvider = FotoProvider();
      final mockRepo = MockRepository();
      final useCase = PredictDiseaseUseCase(mockRepo);
      final predictionVM = PredictionViewModel(useCase);

      // Agregar múltiples fotos
      for (int i = 0; i < 3; i++) {
        fotoProvider.agregarFoto(Foto(
          path: '/test/plant_$i.jpg',
          nombre: 'plant_$i.jpg',
          description: 'Planta $i',
        ));
      }

      // Act - Analizar cada foto
      for (final foto in fotoProvider.fotos) {
        await predictionVM.predictDisease(foto.path);
        expect(predictionVM.state, equals(PredictionState.success));
      }

      // Assert
      expect(fotoProvider.fotos.length, equals(3));
    });

    // =========================================================================
    // TEST INT-PS-003: Eliminar foto no afecta predicción existente
    // =========================================================================
    test('INT-PS-003: eliminar foto no debería afectar predicción existente', () async {
      // Arrange
      final fotoProvider = FotoProvider();
      final mockRepo = MockRepository();
      final useCase = PredictDiseaseUseCase(mockRepo);
      final predictionVM = PredictionViewModel(useCase);

      fotoProvider.agregarFoto(Foto(
        path: '/test/plant.jpg',
        nombre: 'plant.jpg',
        description: 'Test',
      ));

      await predictionVM.predictDisease(fotoProvider.fotos.first.path);

      // Act
      fotoProvider.eliminarFoto(0);

      // Assert
      expect(fotoProvider.fotos, isEmpty);
      expect(predictionVM.prediction, isNotNull); // Predicción persiste
    });
  });

  group('Integration: SettingsViewModel con PredictionViewModel', () {
    // =========================================================================
    // TEST INT-PS-004: Modo standard permite predicción
    // =========================================================================
    test('INT-PS-004: modo standard debería permitir predicción', () async {
      // Arrange
      final settings = SettingsViewModel();
      final mockRepo = MockRepository();
      final useCase = PredictDiseaseUseCase(mockRepo);
      final predictionVM = PredictionViewModel(useCase);

      // Act
      await settings.setModelType(ModelType.standard);
      await predictionVM.predictDisease('/test/image.jpg');

      // Assert
      expect(settings.modelType, equals(ModelType.standard));
      expect(predictionVM.state, equals(PredictionState.success));
    });

    // =========================================================================
    // TEST INT-PS-005: Modelo yolo11 configurable
    // =========================================================================
    test('INT-PS-005: modelo yolo11 debería ser configurable', () async {
      // Arrange
      final settings = SettingsViewModel();

      // Act
      await settings.setModelType(ModelType.yolo11);

      // Assert
      expect(settings.modelType, equals(ModelType.yolo11));
      expect(settings.modelFileName, equals('plant_disease_yolo11.onnx'));
    });

    // =========================================================================
    // TEST INT-PS-006: Cambio de modelo notifica listeners
    // =========================================================================
    test('INT-PS-006: cambio de modelo debería notificar listeners', () async {
      // Arrange
      final settings = SettingsViewModel();
      int notificationCount = 0;
      settings.addListener(() => notificationCount++);

      // Act
      await settings.setModelType(ModelType.yolo11);
      await settings.setModelType(ModelType.standard);

      // Assert
      expect(notificationCount, greaterThanOrEqualTo(2));
    });
  });

  group('Integration: Múltiples ViewModels Simultáneos', () {
    // =========================================================================
    // TEST INT-PS-007: ViewModels independientes
    // =========================================================================
    test('INT-PS-007: ViewModels deberían operar independientemente', () async {
      // Arrange
      final settings = SettingsViewModel();
      final geminiVM = GeminiViewModel();
      final mockRepo = MockRepository();
      final useCase = PredictDiseaseUseCase(mockRepo);
      final predictionVM = PredictionViewModel(useCase);

      // Act
      await settings.setModelType(ModelType.yolo11);
      await predictionVM.predictDisease('/test.jpg');

      // Assert - Cada ViewModel mantiene su estado
      expect(settings.modelType, equals(ModelType.yolo11));
      expect(predictionVM.state, equals(PredictionState.success));
      expect(geminiVM.treatmentState, equals(GeminiState.idle));
    });

    // =========================================================================
    // TEST INT-PS-008: Reset de un ViewModel no afecta otros
    // =========================================================================
    test('INT-PS-008: reset de un ViewModel no debería afectar otros', () async {
      // Arrange
      final settings = SettingsViewModel();
      final mockRepo = MockRepository();
      final useCase = PredictDiseaseUseCase(mockRepo);
      final predictionVM = PredictionViewModel(useCase);

      await settings.setModelType(ModelType.yolo11);
      await predictionVM.predictDisease('/test.jpg');

      // Act
      predictionVM.reset();

      // Assert
      expect(predictionVM.state, equals(PredictionState.initial));
      expect(settings.modelType, equals(ModelType.yolo11)); // No afectado
    });

    // =========================================================================
    // TEST INT-PS-009: Estado global coherente
    // =========================================================================
    test('INT-PS-009: estado global debería ser coherente', () async {
      // Arrange
      final fotoProvider = FotoProvider();
      final settings = SettingsViewModel();
      final geminiVM = GeminiViewModel();

      // Act
      fotoProvider.agregarFoto(Foto(
        path: '/test.jpg',
        nombre: 'test.jpg',
        description: 'Test',
      ));
      await settings.setModelType(ModelType.standard);

      // Assert - Estado global coherente
      expect(fotoProvider.fotos.length, equals(1));
      expect(settings.modelType, equals(ModelType.standard));
      expect(geminiVM.treatmentState, equals(GeminiState.idle));
    });

    // =========================================================================
    // TEST INT-PS-010: Limpieza de estado no causa efectos secundarios
    // =========================================================================
    test('INT-PS-010: limpieza de estado no debería causar efectos secundarios', () async {
      // Arrange
      final fotoProvider = FotoProvider();
      final settings = SettingsViewModel();

      fotoProvider.agregarFoto(Foto(
        path: '/test.jpg',
        nombre: 'test.jpg',
        description: 'Test',
      ));
      await settings.setModelType(ModelType.yolo11);

      // Act - Limpiar fotos
      fotoProvider.eliminarFoto(0);

      // Assert - Settings no afectado
      expect(fotoProvider.fotos, isEmpty);
      expect(settings.modelType, equals(ModelType.yolo11));
    });
  });
}
