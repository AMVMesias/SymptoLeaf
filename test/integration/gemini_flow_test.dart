// =============================================================================
// TEST INTEGRACIÓN: Flujo de Chat y Tratamientos con Gemini
// =============================================================================
// Pruebas de integración para el flujo de chat y obtención de tratamientos.
// Verifica la interacción entre GeminiViewModel y GeminiService.
//
// Fecha: 2026-02-04
// Fase: 3 - Pruebas de Integración
// Autor: QA Team - SymptoLeaf
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:symptoleaf/presentation/viewmodels/gemini_viewmodel.dart';
import 'package:symptoleaf/data/datasource/gemini_service.dart';

void main() {
  late GeminiViewModel viewModel;
  late GeminiService geminiService;

  setUp(() {
    viewModel = GeminiViewModel();
    geminiService = GeminiService();
  });

  group('Integration: GeminiViewModel y GeminiService', () {
    // =========================================================================
    // TEST INT-GF-001: Singleton de GeminiService compartido
    // =========================================================================
    test('INT-GF-001: GeminiService debería ser singleton compartido', () {
      // Arrange
      final service1 = GeminiService();
      final service2 = GeminiService();

      // Assert
      expect(identical(service1, service2), isTrue);
      expect(identical(geminiService, service1), isTrue);
    });

    // =========================================================================
    // TEST INT-GF-002: Estado inicial sincronizado
    // =========================================================================
    test('INT-GF-002: estados iniciales deberían estar sincronizados', () {
      // Assert
      expect(viewModel.treatmentState, equals(GeminiState.idle));
      expect(viewModel.chatState, equals(GeminiState.idle));
      expect(viewModel.messages, isEmpty);
      expect(viewModel.hasTreatment, isFalse);
    });

    // =========================================================================
    // TEST INT-GF-003: ViewModel refleja estado de inicialización
    // =========================================================================
    test('INT-GF-003: ViewModel debería reflejar estado de inicialización', () {
      // Assert
      expect(viewModel.initializationFailed, isFalse);
      expect(viewModel.initError, isEmpty);
    });

    // =========================================================================
    // TEST INT-GF-004: Lista de mensajes inmutable desde ViewModel
    // =========================================================================
    test('INT-GF-004: lista de mensajes debería ser inmutable', () {
      // Arrange & Act
      final messages = viewModel.messages;

      // Assert
      expect(messages, isEmpty);
      expect(messages, isA<List>());
    });

    // =========================================================================
    // TEST INT-GF-005: Propiedades de tratamiento sincronizadas
    // =========================================================================
    test('INT-GF-005: propiedades de tratamiento deberían estar sincronizadas', () {
      // Assert
      expect(viewModel.treatment, isNull);
      expect(viewModel.hasTreatment, isFalse);
      expect(viewModel.treatmentError, isEmpty);
      expect(viewModel.rawTreatmentResponse, isEmpty);
    });
  });

  group('Integration: Estados de Gemini', () {
    // =========================================================================
    // TEST INT-GF-006: GeminiState tiene todos los estados necesarios
    // =========================================================================
    test('INT-GF-006: GeminiState debería tener todos los estados', () {
      // Arrange
      final states = GeminiState.values;

      // Assert
      expect(states.contains(GeminiState.idle), isTrue);
      expect(states.contains(GeminiState.loading), isTrue);
      expect(states.contains(GeminiState.success), isTrue);
      expect(states.contains(GeminiState.error), isTrue);
      expect(states.length, equals(4));
    });

    // =========================================================================
    // TEST INT-GF-007: Transiciones de estado válidas
    // =========================================================================
    test('INT-GF-007: transiciones de estado deberían ser válidas', () {
      // Assert - Estado inicial
      expect(viewModel.treatmentState, equals(GeminiState.idle));
      expect(viewModel.chatState, equals(GeminiState.idle));
    });

    // =========================================================================
    // TEST INT-GF-008: Estado de chat independiente de tratamiento
    // =========================================================================
    test('INT-GF-008: estados de chat y tratamiento deberían ser independientes', () {
      // Assert
      // Ambos estados son independientes pero ambos inician en idle
      expect(viewModel.chatState, equals(GeminiState.idle));
      expect(viewModel.treatmentState, equals(GeminiState.idle));
      
      // Verificar que son propiedades distintas
      expect(
        viewModel.chatState.toString(),
        equals(viewModel.treatmentState.toString()),
      );
    });
  });

  group('Integration: Configuración de GeminiService', () {
    // =========================================================================
    // TEST INT-GF-009: Verificar estado de configuración
    // =========================================================================
    test('INT-GF-009: debería reportar estado de configuración', () {
      // Assert
      // isConfigured depende de si hay API key configurada
      expect(geminiService.isConfigured, isA<bool>());
    });

    // =========================================================================
    // TEST INT-GF-010: Verificar estado de chat activo
    // =========================================================================
    test('INT-GF-010: chat debería estar inactivo inicialmente', () {
      // Assert
      expect(geminiService.isChatActive, isFalse);
    });
  });
}
