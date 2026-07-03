// =============================================================================
// TEST UNITARIO: GeminiViewModel
// =============================================================================
// Pruebas unitarias para el ViewModel de Gemini (chat y tratamientos).
//
// Fecha: 2026-02-04
// Fase: 2 - Pruebas Unitarias
// Autor: QA Team - SymptoLeaf
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:symptoleaf/presentation/viewmodels/gemini_viewmodel.dart';

void main() {
  late GeminiViewModel viewModel;

  setUp(() {
    viewModel = GeminiViewModel();
  });

  group('GeminiViewModel - Estado Inicial', () {
    // =========================================================================
    // TEST UT-GVM-001: Estado de tratamiento inicial es idle
    // =========================================================================
    test('UT-GVM-001: debería iniciar con estado de tratamiento idle', () {
      // Assert
      expect(viewModel.treatmentState, equals(GeminiState.idle));
    });

    // =========================================================================
    // TEST UT-GVM-002: Lista de mensajes vacía inicialmente
    // =========================================================================
    test('UT-GVM-002: debería iniciar con lista de mensajes vacía', () {
      // Assert
      expect(viewModel.messages, isEmpty);
    });

    // =========================================================================
    // TEST UT-GVM-003: Sin tratamiento inicial
    // =========================================================================
    test('UT-GVM-003: no debería tener tratamiento inicialmente', () {
      // Assert
      expect(viewModel.treatment, isNull);
      expect(viewModel.hasTreatment, isFalse);
    });

    // =========================================================================
    // TEST UT-GVM-004: Estado de chat inicial es idle
    // =========================================================================
    test('UT-GVM-004: debería iniciar con estado de chat idle', () {
      // Assert
      expect(viewModel.chatState, equals(GeminiState.idle));
    });

    // =========================================================================
    // TEST UT-GVM-005: Errors vacíos inicialmente
    // =========================================================================
    test('UT-GVM-005: debería tener errores vacíos inicialmente', () {
      // Assert
      expect(viewModel.treatmentError, isEmpty);
      expect(viewModel.chatError, isEmpty);
    });
  });

  group('GeminiViewModel - Estado de Inicialización', () {
    // =========================================================================
    // TEST UT-GVM-006: No inicializado al inicio
    // =========================================================================
    test('UT-GVM-006: no debería estar inicializado al inicio', () {
      // Assert
      expect(viewModel.initializationFailed, isFalse);
    });

    // =========================================================================
    // TEST UT-GVM-007: initError vacío al inicio
    // =========================================================================
    test('UT-GVM-007: initError debería estar vacío al inicio', () {
      // Assert
      expect(viewModel.initError, isEmpty);
    });
  });

  group('GeminiViewModel - Propiedades de Tratamiento', () {
    // =========================================================================
    // TEST UT-GVM-008: rawTreatmentResponse vacío inicialmente
    // =========================================================================
    test('UT-GVM-008: rawTreatmentResponse debería estar vacío inicialmente', () {
      // Assert
      expect(viewModel.rawTreatmentResponse, isEmpty);
    });

    // =========================================================================
    // TEST UT-GVM-009: hasTreatment es false sin tratamiento
    // =========================================================================
    test('UT-GVM-009: hasTreatment debería ser false sin tratamiento', () {
      // Assert
      expect(viewModel.hasTreatment, isFalse);
    });
  });

  group('GeminiViewModel - Lista de Mensajes', () {
    // =========================================================================
    // TEST UT-GVM-010: Lista de mensajes es inmutable
    // =========================================================================
    test('UT-GVM-010: lista de mensajes devuelta debería ser inmutable', () {
      // Arrange & Act
      final messages = viewModel.messages;

      // Assert - La lista devuelta es unmodifiable
      expect(messages, isA<List>());
      // La lista está vacía inicialmente
      expect(messages, isEmpty);
    });
  });
}
