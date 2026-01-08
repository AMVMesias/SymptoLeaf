import '../../domain/entities/prediction_entity.dart';

class PredictionModel {
  final String className;
  final String plant;
  final String disease;
  final double confidence;
  final bool isHealthy;
  final List<PredictionTop3Model> top3;

  PredictionModel({
    required this.className,
    required this.plant,
    required this.disease,
    required this.confidence,
    required this.isHealthy,
    required this.top3,
  });

  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    // Parse top3 predictions
    List<PredictionTop3Model> top3List = [];
    if (json['top3'] != null) {
      top3List = (json['top3'] as List)
          .map((item) => PredictionTop3Model(
                className: item['class'] ?? '',
                plant: item['plant'] ?? '',
                disease: item['disease'] ?? '',
                confidence: (item['confidence'] ?? 0.0).toDouble(),
                isHealthy: item['is_healthy'] ?? false,
              ))
          .toList();
    }

    return PredictionModel(
      className: json['prediction']['class'] ?? '',
      plant: json['prediction']['plant'] ?? '',
      disease: json['prediction']['disease'] ?? '',
      confidence: (json['prediction']['confidence'] ?? 0.0).toDouble(),
      isHealthy: json['prediction']['is_healthy'] ?? false,
      top3: top3List,
    );
  }

  // Convert to entity
  PredictionEntity toEntity() {
    return PredictionEntity(
      className: className,
      plant: plant,
      disease: disease,
      confidence: confidence,
      isHealthy: isHealthy,
      top3: top3.map((item) => item.toEntity()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prediction': {
        'class': className,
        'plant': plant,
        'disease': disease,
        'confidence': confidence,
        'is_healthy': isHealthy,
      },
      'top3': top3.map((item) => {
        'class': item.className,
        'plant': item.plant,
        'disease': item.disease,
        'confidence': item.confidence,
        'is_healthy': item.isHealthy,
      }).toList(),
    };
  }
}

class PredictionTop3Model {
  final String className;
  final String plant;
  final String disease;
  final double confidence;
  final bool isHealthy;

  PredictionTop3Model({
    required this.className,
    required this.plant,
    required this.disease,
    required this.confidence,
    required this.isHealthy,
  });

  PredictionTop3 toEntity() {
    return PredictionTop3(
      className: className,
      plant: plant,
      disease: disease,
      confidence: confidence,
      isHealthy: isHealthy,
    );
  }
}
