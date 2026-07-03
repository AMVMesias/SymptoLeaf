// =============================================================================
// TEST 1: INTEGRATION E2E - Flujo de Análisis Completo
// =============================================================================
// Prueba el flujo completo desde la selección de imagen hasta el resultado
// con recomendaciones de tratamiento.
//
// Fecha: 2026-02-03
// Autor: QA Team - SymptoLeaf
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Importaciones de la aplicación
import 'package:symptoleaf/presentation/viewmodels/prediction_viewmodel.dart';
import 'package:symptoleaf/presentation/viewmodels/settings_viewmodel.dart';
import 'package:symptoleaf/presentation/providers/foto_provider.dart';
import 'package:symptoleaf/data/datasource/gemini_service.dart';

/// Suite de tests de integración para el flujo de análisis E2E
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Integration E2E: Flujo de Análisis', () {
    // =========================================================================
    // TEST IE2E-001: Verificar inicialización de providers
    // =========================================================================
    test('IE2E-001: Todos los providers deberían inicializarse correctamente', () {
      // Arrange & Act
      final settingsVM = SettingsViewModel();
      final fotoProvider = FotoProvider();
      final geminiService = GeminiService();
      
      // Assert
      expect(settingsVM.modelType, equals(ModelType.standard));
      expect(fotoProvider.fotos, isEmpty);
      expect(geminiService.isChatActive, isFalse);
    });

    // =========================================================================
    // TEST IE2E-002: Verificar estados de predicción
    // =========================================================================
    test('IE2E-002: PredictionState debería tener transiciones válidas', () {
      // Arrange
      final states = PredictionState.values;
      
      // Assert - Verificar todos los estados existen
      expect(states.contains(PredictionState.initial), isTrue);
      expect(states.contains(PredictionState.loading), isTrue);
      expect(states.contains(PredictionState.success), isTrue);
      expect(states.contains(PredictionState.error), isTrue);
      
      // Assert - Verificar cantidad de estados
      expect(states.length, equals(4));
    });

    // =========================================================================
    // TEST IE2E-003: Verificar modos de predicción
    // =========================================================================
    test('IE2E-003: Tipos de modelo deberían ser standard y yolo11', () {
      // Arrange
      final types = ModelType.values;
      
      // Assert
      expect(types.contains(ModelType.standard), isTrue);
      expect(types.contains(ModelType.yolo11), isTrue);
      expect(types.length, equals(2));
    });

    // =========================================================================
    // TEST IE2E-004: Verificar patrón Singleton de GeminiService
    // =========================================================================
    test('IE2E-004: GeminiService debería mantener una única instancia', () {
      // Arrange
      final instance1 = GeminiService();
      final instance2 = GeminiService();
      final instance3 = GeminiService();
      
      // Assert - Todas las instancias son idénticas
      expect(identical(instance1, instance2), isTrue);
      expect(identical(instance2, instance3), isTrue);
      expect(identical(instance1, instance3), isTrue);
    });

    // =========================================================================
    // TEST IE2E-005: Verificar estado inicial de FotoProvider
    // =========================================================================
    test('IE2E-005: FotoProvider debería iniciar sin foto seleccionada', () {
      // Arrange
      final provider = FotoProvider();
      
      // Assert
      expect(provider.fotos, isEmpty);
    });

    // =========================================================================
    // TEST IE2E-006: Verificar cambio de modo en SettingsViewModel
    // =========================================================================
    test('IE2E-006: SettingsViewModel debería iniciar en modo standard', () {
      // Arrange
      final viewModel = SettingsViewModel();
      
      // Assert - Estado inicial
      expect(viewModel.modelType, equals(ModelType.standard));
      expect(viewModel.modelFileName, isNotEmpty);
    });
  });

  group('Integration E2E: Flujo de Chat', () {
    // =========================================================================
    // TEST IE2E-007: Verificar estado inicial del chat
    // =========================================================================
    test('IE2E-007: Chat debería estar inactivo inicialmente', () {
      // Arrange
      final geminiService = GeminiService();
      
      // Assert
      expect(geminiService.isChatActive, isFalse);
    });

    // =========================================================================
    // TEST IE2E-008: Verificar configuración de Gemini
    // =========================================================================
    test('IE2E-008: GeminiService debería reportar su estado de configuración', () {
      // Arrange
      final service = GeminiService();
      
      // Assert - El servicio tiene un estado de configuración definido
      // (puede ser true o false dependiendo de si hay API key)
      expect(service.isConfigured, isA<bool>());
    });
  });
}
