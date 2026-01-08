//Entidad del dominio para predicción
class PredictionEntity {
  final String className;
  final String plant;
  final String disease;
  final double confidence;
  final bool isHealthy;
  final List<PredictionTop3> top3;

  PredictionEntity({
    required this.className,
    required this.plant,
    required this.disease,
    required this.confidence,
    required this.isHealthy,
    required this.top3,
  });
}

class PredictionTop3 {
  final String className;
  final String plant;
  final String disease;
  final double confidence;
  final bool isHealthy;

  PredictionTop3({
    required this.className,
    required this.plant,
    required this.disease,
    required this.confidence,
    required this.isHealthy,
  });
}
