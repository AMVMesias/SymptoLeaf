// =============================================================================
// TEST UNITARIO: ChatMessageModel
// =============================================================================
// Pruebas unitarias para el modelo de mensajes del chat.
//
// Fecha: 2026-02-04
// Fase: 2 - Pruebas Unitarias
// Autor: QA Team - SymptoLeaf
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:symptoleaf/data/models/chat_message_model.dart';

void main() {
  group('ChatMessage - Construcción', () {
    // =========================================================================
    // TEST UT-CM-001: Crear mensaje de usuario
    // =========================================================================
    test('UT-CM-001: debería crear mensaje de usuario correctamente', () {
      // Arrange & Act
      final message = ChatMessage(
        content: '¿Cómo trato la mancha bacteriana?',
        role: MessageRole.user,
      );

      // Assert
      expect(message.content, equals('¿Cómo trato la mancha bacteriana?'));
      expect(message.role, equals(MessageRole.user));
      expect(message.isUser, isTrue);
      expect(message.isAssistant, isFalse);
      expect(message.isLoading, isFalse);
    });

    // =========================================================================
    // TEST UT-CM-002: Crear mensaje de asistente
    // =========================================================================
    test('UT-CM-002: debería crear mensaje de asistente correctamente', () {
      // Arrange & Act
      final message = ChatMessage(
        content: 'Para tratar la mancha bacteriana...',
        role: MessageRole.assistant,
      );

      // Assert
      expect(message.role, equals(MessageRole.assistant));
      expect(message.isUser, isFalse);
      expect(message.isAssistant, isTrue);
    });

    // =========================================================================
    // TEST UT-CM-003: Timestamp automático
    // =========================================================================
    test('UT-CM-003: debería asignar timestamp automáticamente', () {
      // Arrange
      final beforeCreation = DateTime.now();

      // Act
      final message = ChatMessage(
        content: 'Test message',
        role: MessageRole.user,
      );

      final afterCreation = DateTime.now();

      // Assert
      expect(message.timestamp.isAfter(beforeCreation.subtract(const Duration(seconds: 1))), isTrue);
      expect(message.timestamp.isBefore(afterCreation.add(const Duration(seconds: 1))), isTrue);
    });

    // =========================================================================
    // TEST UT-CM-004: Timestamp personalizado
    // =========================================================================
    test('UT-CM-004: debería aceptar timestamp personalizado', () {
      // Arrange
      final customTime = DateTime(2026, 1, 15, 10, 30);

      // Act
      final message = ChatMessage(
        content: 'Test',
        role: MessageRole.user,
        timestamp: customTime,
      );

      // Assert
      expect(message.timestamp, equals(customTime));
    });
  });

  group('ChatMessage - Factory Methods', () {
    // =========================================================================
    // TEST UT-CM-005: Factory user()
    // =========================================================================
    test('UT-CM-005: ChatMessage.user() debería crear mensaje de usuario', () {
      // Arrange & Act
      final message = ChatMessage.user('Pregunta del usuario');

      // Assert
      expect(message.content, equals('Pregunta del usuario'));
      expect(message.role, equals(MessageRole.user));
      expect(message.isUser, isTrue);
      expect(message.isLoading, isFalse);
    });

    // =========================================================================
    // TEST UT-CM-006: Factory assistant()
    // =========================================================================
    test('UT-CM-006: ChatMessage.assistant() debería crear mensaje de asistente', () {
      // Arrange & Act
      final message = ChatMessage.assistant('Respuesta del asistente');

      // Assert
      expect(message.content, equals('Respuesta del asistente'));
      expect(message.role, equals(MessageRole.assistant));
      expect(message.isAssistant, isTrue);
      expect(message.isLoading, isFalse);
    });

    // =========================================================================
    // TEST UT-CM-007: Factory loading()
    // =========================================================================
    test('UT-CM-007: ChatMessage.loading() debería crear mensaje de carga', () {
      // Arrange & Act
      final message = ChatMessage.loading();

      // Assert
      expect(message.content, isEmpty);
      expect(message.role, equals(MessageRole.assistant));
      expect(message.isLoading, isTrue);
      expect(message.isAssistant, isTrue);
    });
  });

  group('ChatMessage - Getters', () {
    // =========================================================================
    // TEST UT-CM-008: Getter isUser para usuario
    // =========================================================================
    test('UT-CM-008: isUser debería ser true solo para mensajes de usuario', () {
      // Arrange
      final userMessage = ChatMessage.user('Test');
      final assistantMessage = ChatMessage.assistant('Test');

      // Assert
      expect(userMessage.isUser, isTrue);
      expect(assistantMessage.isUser, isFalse);
    });

    // =========================================================================
    // TEST UT-CM-009: Getter isAssistant para asistente
    // =========================================================================
    test('UT-CM-009: isAssistant debería ser true solo para mensajes de asistente', () {
      // Arrange
      final userMessage = ChatMessage.user('Test');
      final assistantMessage = ChatMessage.assistant('Test');

      // Assert
      expect(userMessage.isAssistant, isFalse);
      expect(assistantMessage.isAssistant, isTrue);
    });
  });

  group('MessageRole Enum', () {
    // =========================================================================
    // TEST UT-CM-010: Verificar roles disponibles
    // =========================================================================
    test('UT-CM-010: debería tener exactamente 2 roles', () {
      // Assert
      expect(MessageRole.values.length, equals(2));
      expect(MessageRole.values.contains(MessageRole.user), isTrue);
      expect(MessageRole.values.contains(MessageRole.assistant), isTrue);
    });
  });
}
