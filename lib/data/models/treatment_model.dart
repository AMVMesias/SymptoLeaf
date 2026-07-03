/// Modelo para las recomendaciones de tratamiento
class TreatmentModel {
  final String diseaseName;
  final String plantName;
  final List<String> symptoms;
  final List<TreatmentOption> treatments;
  final List<String> preventionTips;
  final String additionalInfo;

  TreatmentModel({
    required this.diseaseName,
    required this.plantName,
    required this.symptoms,
    required this.treatments,
    required this.preventionTips,
    this.additionalInfo = '',
  });

  factory TreatmentModel.fromGeminiResponse(String response, String plant, String disease) {
    // Parse la respuesta de texto de Gemini
    return TreatmentModel(
      diseaseName: disease,
      plantName: plant,
      symptoms: _extractSection(response, 'síntomas'),
      treatments: _extractTreatments(response),
      preventionTips: _extractSection(response, 'prevención'),
      additionalInfo: response,
    );
  }

  static List<String> _extractSection(String text, String section) {
    // Simplificado: retornamos el texto completo parseado por líneas relevantes
    final lines = text.split('\n');
    final List<String> items = [];
    bool inSection = false;
    
    for (final line in lines) {
      final lowerLine = line.toLowerCase();
      if (lowerLine.contains(section)) {
        inSection = true;
        continue;
      }
      if (inSection && line.trim().startsWith('-')) {
        items.add(line.trim().substring(1).trim());
      }
      if (inSection && line.trim().isEmpty && items.isNotEmpty) {
        break;
      }
    }
    return items;
  }

  static List<TreatmentOption> _extractTreatments(String text) {
    final treatments = <TreatmentOption>[];
    final lines = text.split('\n');
    
    for (final line in lines) {
      if (line.contains('🌿') || line.toLowerCase().contains('orgánico')) {
        treatments.add(TreatmentOption(
          name: line.replaceAll(RegExp(r'[🌿-]'), '').trim(),
          type: TreatmentType.organic,
          description: '',
        ));
      } else if (line.contains('🧪') || line.toLowerCase().contains('químico')) {
        treatments.add(TreatmentOption(
          name: line.replaceAll(RegExp(r'[🧪-]'), '').trim(),
          type: TreatmentType.chemical,
          description: '',
        ));
      }
    }
    
    return treatments;
  }
}

enum TreatmentType { organic, chemical, cultural }

class TreatmentOption {
  final String name;
  final TreatmentType type;
  final String description;

  TreatmentOption({
    required this.name,
    required this.type,
    required this.description,
  });

  String get typeLabel {
    switch (type) {
      case TreatmentType.organic:
        return '🌿 Orgánico';
      case TreatmentType.chemical:
        return '🧪 Químico';
      case TreatmentType.cultural:
        return '🌱 Cultural';
    }
  }
}
