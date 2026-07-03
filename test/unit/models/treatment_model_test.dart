// =============================================================================
// TEST UNITARIO: TreatmentModel
// =============================================================================
// Pruebas unitarias para el modelo de tratamientos de Gemini.
//
// Fecha: 2026-02-04
// Fase: 2 - Pruebas Unitarias
// Autor: QA Team - SymptoLeaf
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:symptoleaf/data/models/treatment_model.dart';

void main() {
  group('TreatmentModel - Construcción', () {
    // =========================================================================
    // TEST UT-TM-001: Crear modelo de tratamiento básico
    // =========================================================================
    test('UT-TM-001: debería crear modelo con campos requeridos', () {
      // Arrange & Act
      final model = TreatmentModel(
        diseaseName: 'Tizón tardío',
        plantName: 'Papa',
        symptoms: ['Manchas oscuras', 'Hojas marchitas'],
        treatments: [],
        preventionTips: ['Rotación de cultivos'],
        additionalInfo: 'Información adicional de Gemini',
      );

      // Assert
      expect(model.diseaseName, equals('Tizón tardío'));
      expect(model.plantName, equals('Papa'));
      expect(model.symptoms.length, equals(2));
      expect(model.preventionTips.isNotEmpty, isTrue);
      expect(model.additionalInfo.isNotEmpty, isTrue);
    });

    // =========================================================================
    // TEST UT-TM-002: Modelo con síntomas vacíos
    // =========================================================================
    test('UT-TM-002: debería permitir lista de síntomas vacía', () {
      // Arrange & Act
      final model = TreatmentModel(
        diseaseName: 'Saludable',
        plantName: 'Tomate',
        symptoms: [],
        treatments: [],
        preventionTips: [],
      );

      // Assert
      expect(model.symptoms, isEmpty);
      expect(model.treatments, isEmpty);
      expect(model.preventionTips, isEmpty);
    });

    // =========================================================================
    // TEST UT-TM-003: Modelo con tratamientos orgánicos
    // =========================================================================
    test('UT-TM-003: debería crear modelo con tratamientos orgánicos', () {
      // Arrange
      final treatments = [
        TreatmentOption(
          name: 'Fungicida de cobre',
          type: TreatmentType.organic,
          description: 'Aplicar cada 7 días',
        ),
        TreatmentOption(
          name: 'Aceite de neem',
          type: TreatmentType.organic,
          description: 'Aplicar en horas de la tarde',
        ),
      ];

      // Act
      final model = TreatmentModel(
        diseaseName: 'Roya común',
        plantName: 'Maíz',
        symptoms: ['Pústulas naranjas'],
        treatments: treatments,
        preventionTips: ['Eliminar residuos de cosecha'],
      );

      // Assert
      expect(model.treatments.length, equals(2));
      expect(model.treatments[0].type, equals(TreatmentType.organic));
      expect(model.treatments[1].type, equals(TreatmentType.organic));
    });

    // =========================================================================
    // TEST UT-TM-004: Modelo con tratamientos químicos
    // =========================================================================
    test('UT-TM-004: debería crear modelo con tratamientos químicos', () {
      // Arrange
      final chemicalTreatment = TreatmentOption(
        name: 'Mancozeb',
        type: TreatmentType.chemical,
        description: 'Fungicida de contacto',
      );

      // Act
      final model = TreatmentModel(
        diseaseName: 'Mancha bacteriana',
        plantName: 'Tomate',
        symptoms: ['Manchas en hojas'],
        treatments: [chemicalTreatment],
        preventionTips: [],
      );

      // Assert
      expect(model.treatments.first.type, equals(TreatmentType.chemical));
    });
  });

  group('TreatmentType Enum', () {
    // =========================================================================
    // TEST UT-TM-005: Verificar tipos de tratamiento
    // =========================================================================
    test('UT-TM-005: debería tener 3 tipos de tratamiento', () {
      // Assert
      expect(TreatmentType.values.length, equals(3));
      expect(TreatmentType.values.contains(TreatmentType.organic), isTrue);
      expect(TreatmentType.values.contains(TreatmentType.chemical), isTrue);
      expect(TreatmentType.values.contains(TreatmentType.cultural), isTrue);
    });
  });

  group('TreatmentOption', () {
    // =========================================================================
    // TEST UT-TM-006: Crear opción de tratamiento
    // =========================================================================
    test('UT-TM-006: debería crear opción de tratamiento correctamente', () {
      // Arrange & Act
      final option = TreatmentOption(
        name: 'Poda de partes afectadas',
        type: TreatmentType.cultural,
        description: 'Eliminar hojas y ramas enfermas',
      );

      // Assert
      expect(option.name, equals('Poda de partes afectadas'));
      expect(option.type, equals(TreatmentType.cultural));
      expect(option.description, isNotEmpty);
    });

    // =========================================================================
    // TEST UT-TM-007: Verificar typeLabel para orgánico
    // =========================================================================
    test('UT-TM-007: typeLabel debería mostrar emoji para orgánico', () {
      // Arrange
      final organic = TreatmentOption(
        name: 'Test',
        type: TreatmentType.organic,
        description: '',
      );

      // Assert
      expect(organic.typeLabel, contains('🌿'));
      expect(organic.typeLabel, contains('Orgánico'));
    });

    // =========================================================================
    // TEST UT-TM-008: Verificar typeLabel para químico
    // =========================================================================
    test('UT-TM-008: typeLabel debería mostrar emoji para químico', () {
      // Arrange
      final chemical = TreatmentOption(
        name: 'Test',
        type: TreatmentType.chemical,
        description: '',
      );

      // Assert
      expect(chemical.typeLabel, contains('🧪'));
      expect(chemical.typeLabel, contains('Químico'));
    });

    // =========================================================================
    // TEST UT-TM-009: Verificar typeLabel para cultural
    // =========================================================================
    test('UT-TM-009: typeLabel debería mostrar emoji para cultural', () {
      // Arrange
      final cultural = TreatmentOption(
        name: 'Test',
        type: TreatmentType.cultural,
        description: '',
      );

      // Assert
      expect(cultural.typeLabel, contains('🌱'));
      expect(cultural.typeLabel, contains('Cultural'));
    });
  });

  group('TreatmentModel - fromGeminiResponse', () {
    // =========================================================================
    // TEST UT-TM-010: Parsear respuesta de Gemini
    // =========================================================================
    test('UT-TM-010: debería parsear respuesta básica de Gemini', () {
      // Arrange
      const geminiResponse = '''
      El tomate presenta mancha bacteriana.
      
      Síntomas:
      - Manchas oscuras en las hojas
      - Decoloración del fruto
      
      Tratamientos:
      🌿 Aplicar fungicida de cobre
      🧪 Usar bactericida comercial
      
      Prevención:
      - Rotación de cultivos
      - Eliminar plantas infectadas
      ''';

      // Act
      final model = TreatmentModel.fromGeminiResponse(
        geminiResponse,
        'Tomate',
        'Mancha bacteriana',
      );

      // Assert
      expect(model.plantName, equals('Tomate'));
      expect(model.diseaseName, equals('Mancha bacteriana'));
      expect(model.additionalInfo, equals(geminiResponse));
    });
  });
}
