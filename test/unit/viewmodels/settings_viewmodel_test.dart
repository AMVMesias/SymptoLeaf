// =============================================================================
// TEST UNITARIO: SettingsViewModel
// =============================================================================
// Pruebas unitarias para el ViewModel de configuración.
// Adaptado para la versión actual con ModelType (standard/yolo11).
//
// Fecha: 2026-02-04
// Fase: 2 - Pruebas Unitarias
// Autor: QA Team - SymptoLeaf
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:symptoleaf/presentation/viewmodels/settings_viewmodel.dart';

void main() {
  // Configurar SharedPreferences para tests
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SettingsViewModel - Estado Inicial', () {
    // =========================================================================
    // TEST UT-SVM-001: Estado inicial en modo standard
    // =========================================================================
    test('UT-SVM-001: debería iniciar en modo standard', () {
      // Arrange & Act
      final viewModel = SettingsViewModel();

      // Assert
      expect(viewModel.modelType, equals(ModelType.standard));
    });

    // =========================================================================
    // TEST UT-SVM-002: Nombre de modelo por defecto
    // =========================================================================
    test('UT-SVM-002: debería tener nombre de modelo por defecto', () {
      // Arrange & Act
      final viewModel = SettingsViewModel();

      // Assert
      expect(viewModel.modelFileName, isNotEmpty);
    });
  });

  group('SettingsViewModel - Cambio de Modelo', () {
    // =========================================================================
    // TEST UT-SVM-003: Cambiar a modelo yolo11
    // =========================================================================
    test('UT-SVM-003: debería cambiar a modelo yolo11', () async {
      // Arrange
      final viewModel = SettingsViewModel();
      expect(viewModel.modelType, equals(ModelType.standard));

      // Act
      await viewModel.setModelType(ModelType.yolo11);

      // Assert
      expect(viewModel.modelType, equals(ModelType.yolo11));
    });

    // =========================================================================
    // TEST UT-SVM-004: Cambiar a modelo standard
    // =========================================================================
    test('UT-SVM-004: debería cambiar a modelo standard', () async {
      // Arrange
      final viewModel = SettingsViewModel();
      await viewModel.setModelType(ModelType.yolo11);
      expect(viewModel.modelType, equals(ModelType.yolo11));

      // Act
      await viewModel.setModelType(ModelType.standard);

      // Assert
      expect(viewModel.modelType, equals(ModelType.standard));
    });

    // =========================================================================
    // TEST UT-SVM-005: Cambio de modelo múltiple
    // =========================================================================
    test('UT-SVM-005: debería permitir cambios de modelo múltiples', () async {
      // Arrange
      final viewModel = SettingsViewModel();

      // Act & Assert - Cambiar 10 veces
      for (int i = 0; i < 10; i++) {
        if (i % 2 == 0) {
          await viewModel.setModelType(ModelType.yolo11);
          expect(viewModel.modelType, equals(ModelType.yolo11));
        } else {
          await viewModel.setModelType(ModelType.standard);
          expect(viewModel.modelType, equals(ModelType.standard));
        }
      }
    });
  });

  group('SettingsViewModel - Nombre de Archivo del Modelo', () {
    // =========================================================================
    // TEST UT-SVM-006: Nombre de archivo para modelo standard
    // =========================================================================
    test('UT-SVM-006: debería retornar nombre correcto para modelo standard', () {
      // Arrange
      final viewModel = SettingsViewModel();

      // Assert
      expect(viewModel.modelFileName, equals('plant_disease_model.onnx'));
    });

    // =========================================================================
    // TEST UT-SVM-007: Nombre de archivo para modelo yolo11
    // =========================================================================
    test('UT-SVM-007: debería retornar nombre correcto para modelo yolo11', () async {
      // Arrange
      final viewModel = SettingsViewModel();

      // Act
      await viewModel.setModelType(ModelType.yolo11);

      // Assert
      expect(viewModel.modelFileName, equals('plant_disease_yolo11.onnx'));
    });
  });

  group('ModelType Enum', () {
    // =========================================================================
    // TEST UT-SVM-008: Verificar tipos disponibles
    // =========================================================================
    test('UT-SVM-008: debería tener exactamente 2 tipos', () {
      // Assert
      expect(ModelType.values.length, equals(2));
    });

    // =========================================================================
    // TEST UT-SVM-009: Tipo standard existe
    // =========================================================================
    test('UT-SVM-009: tipo standard debería existir', () {
      // Assert
      expect(ModelType.values.contains(ModelType.standard), isTrue);
    });

    // =========================================================================
    // TEST UT-SVM-010: Tipo yolo11 existe
    // =========================================================================
    test('UT-SVM-010: tipo yolo11 debería existir', () {
      // Assert
      expect(ModelType.values.contains(ModelType.yolo11), isTrue);
    });
  });
}
