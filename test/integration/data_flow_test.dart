// =============================================================================
// TEST INTEGRACIÓN: Flujo de Datos End-to-End
// =============================================================================
// Pruebas de integración para verificar el flujo completo de datos
// desde la entrada hasta la presentación de resultados.
//
// Fecha: 2026-02-04
// Fase: 3 - Pruebas de Integración
// Autor: QA Team - SymptoLeaf
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:symptoleaf/domain/entities/prediction_entity.dart';
import 'package:symptoleaf/data/models/prediction_model.dart';
import 'package:symptoleaf/data/models/treatment_model.dart';
import 'package:symptoleaf/data/models/chat_message_model.dart';

void main() {
  group('Integration: Flujo de Datos Prediction', () {
    // =========================================================================
    // TEST INT-DF-001: Modelo a Entidad - Conversión correcta
    // =========================================================================
    test('INT-DF-001: PredictionModel debería convertirse a PredictionEntity', () {
      // Arrange
      final model = PredictionModel(
        className: 'Tomato_Late_blight',
        plant: 'Tomato',
        disease: 'Late blight',
        confidence: 0.92,
        isHealthy: false,
        top3: [],
      );

      // Act
      final entity = model.toEntity();

      // Assert
      expect(entity, isA<PredictionEntity>());
      expect(entity.className, equals(model.className));
      expect(entity.plant, equals(model.plant));
      expect(entity.disease, equals(model.disease));
      expect(entity.confidence, equals(model.confidence));
      expect(entity.isHealthy, equals(model.isHealthy));
    });

    // =========================================================================
    // TEST INT-DF-002: Entidad preserva todos los campos
    // =========================================================================
    test('INT-DF-002: PredictionEntity debería preservar todos los campos', () {
      // Arrange
      final top3 = [
        PredictionTop3(
          className: 'Tomato_Late_blight',
          plant: 'Tomato',
          disease: 'Late blight',
          confidence: 0.85,
          isHealthy: false,
        ),
        PredictionTop3(
          className: 'Tomato_Early_blight',
          plant: 'Tomato',
          disease: 'Early blight',
          confidence: 0.10,
          isHealthy: false,
        ),
      ];

      final entity = PredictionEntity(
        className: 'Tomato_Late_blight',
        plant: 'Tomato',
        disease: 'Late blight',
        confidence: 0.85,
        isHealthy: false,
        top3: top3,
      );

      // Assert
      expect(entity.top3.length, equals(2));
      expect(entity.top3[0].confidence, greaterThan(entity.top3[1].confidence));
    });

    // =========================================================================
    // TEST INT-DF-003: Modelo desde JSON - Parsing correcto
    // =========================================================================
    test('INT-DF-003: PredictionModel debería parsearse desde JSON', () {
      // Arrange - La estructura real tiene 'prediction' como wrapper
      final json = {
        'prediction': {
          'class': 'Potato_healthy',
          'plant': 'Potato',
          'disease': 'healthy',
          'confidence': 0.97,
          'is_healthy': true,
        },
        'top3': [],
      };

      // Act
      final model = PredictionModel.fromJson(json);

      // Assert
      expect(model.className, equals('Potato_healthy'));
      expect(model.plant, equals('Potato'));
      expect(model.isHealthy, isTrue);
      expect(model.confidence, equals(0.97));
    });

    // =========================================================================
    // TEST INT-DF-004: Modelo a JSON - Serialización correcta
    // =========================================================================
    test('INT-DF-004: PredictionModel debería serializarse a JSON', () {
      // Arrange
      final model = PredictionModel(
        className: 'Apple_Scab',
        plant: 'Apple',
        disease: 'Scab',
        confidence: 0.78,
        isHealthy: false,
        top3: [],
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json['prediction']['class'], equals('Apple_Scab'));
      expect(json['prediction']['plant'], equals('Apple'));
      expect(json['prediction']['confidence'], equals(0.78));
    });

    // =========================================================================
    // TEST INT-DF-005: Ciclo completo JSON -> Model -> Entity -> JSON
    // =========================================================================
    test('INT-DF-005: ciclo completo de datos debería preservar información', () {
      // Arrange
      final originalJson = {
        'prediction': {
          'class': 'Corn_Common_rust',
          'plant': 'Corn',
          'disease': 'Common rust',
          'confidence': 0.89,
          'is_healthy': false,
        },
        'top3': [],
      };

      // Act
      final model = PredictionModel.fromJson(originalJson);
      final entity = model.toEntity();
      final finalJson = PredictionModel(
        className: entity.className,
        plant: entity.plant,
        disease: entity.disease,
        confidence: entity.confidence,
        isHealthy: entity.isHealthy,
        top3: [],
      ).toJson();

      // Assert
      final finalPrediction = finalJson['prediction'] as Map<String, dynamic>;
      final originalPrediction = originalJson['prediction'] as Map<String, dynamic>;
      expect(finalPrediction['class'], equals(originalPrediction['class']));
      expect(finalPrediction['plant'], equals(originalPrediction['plant']));
      expect(finalPrediction['confidence'], equals(originalPrediction['confidence']));
    });
  });

  group('Integration: Flujo de Datos Treatment', () {
    // =========================================================================
    // TEST INT-DF-006: TreatmentModel estructura correcta
    // =========================================================================
    test('INT-DF-006: TreatmentModel debería tener estructura correcta', () {
      // Arrange
      final treatment = TreatmentModel(
        diseaseName: 'Late blight',
        plantName: 'Tomato',
        symptoms: ['Manchas oscuras', 'Hojas amarillentas'],
        treatments: [
          TreatmentOption(
            name: 'Fungicida de cobre',
            type: TreatmentType.organic,
            description: 'Aplicar cada 7 días',
          ),
        ],
        preventionTips: ['Rotación de cultivos'],
        additionalInfo: 'Consultar con agrónomo',
      );

      // Assert
      expect(treatment.treatments.length, equals(1));
      expect(treatment.treatments.first.name, equals('Fungicida de cobre'));
      expect(treatment.preventionTips.length, equals(1));
      expect(treatment.symptoms.length, equals(2));
    });

    // =========================================================================
    // TEST INT-DF-007: TreatmentOption campos completos
    // =========================================================================
    test('INT-DF-007: TreatmentOption debería tener campos completos', () {
      // Arrange
      final option = TreatmentOption(
        name: 'Neem Oil',
        type: TreatmentType.organic,
        description: 'Aceite de neem orgánico',
      );

      // Assert
      expect(option.name, isNotEmpty);
      expect(option.description, isNotEmpty);
      expect(option.type, equals(TreatmentType.organic));
      expect(option.typeLabel, contains('Orgánico'));
    });
  });

  group('Integration: Flujo de Datos Chat', () {
    // =========================================================================
    // TEST INT-DF-008: ChatMessage flujo de conversación
    // =========================================================================
    test('INT-DF-008: ChatMessage debería mantener flujo de conversación', () {
      // Arrange
      final messages = <ChatMessage>[];

      // Act - Simular conversación
      messages.add(ChatMessage.user('¿Cómo trato Late blight?'));
      messages.add(ChatMessage.assistant('Para tratar Late blight...'));
      messages.add(ChatMessage.user('¿Es orgánico?'));
      messages.add(ChatMessage.assistant('Sí, puedes usar...'));

      // Assert
      expect(messages.length, equals(4));
      expect(messages[0].isUser, isTrue);
      expect(messages[1].isAssistant, isTrue);
      expect(messages[2].isUser, isTrue);
      expect(messages[3].isAssistant, isTrue);
    });

    // =========================================================================
    // TEST INT-DF-009: MessageRole alternancia correcta
    // =========================================================================
    test('INT-DF-009: roles de mensaje deberían alternar correctamente', () {
      // Arrange
      final userMsg = ChatMessage.user('Pregunta');
      final assistantMsg = ChatMessage.assistant('Respuesta');

      // Assert
      expect(userMsg.role, equals(MessageRole.user));
      expect(assistantMsg.role, equals(MessageRole.assistant));
      expect(userMsg.isUser, isTrue);
      expect(assistantMsg.isAssistant, isTrue);
    });

    // =========================================================================
    // TEST INT-DF-010: Timestamps ordenados cronológicamente
    // =========================================================================
    test('INT-DF-010: timestamps deberían estar ordenados', () async {
      // Arrange
      final msg1 = ChatMessage.user('Mensaje 1');
      await Future.delayed(const Duration(milliseconds: 10));
      final msg2 = ChatMessage.user('Mensaje 2');

      // Assert
      expect(msg2.timestamp.isAfter(msg1.timestamp), isTrue);
    });
  });
}
