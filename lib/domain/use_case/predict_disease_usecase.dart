import '../entities/prediction_entity.dart';
import '../../data/repositories/base_repository.dart';

class PredictDiseaseUseCase {
  final BaseRepository repository;

  PredictDiseaseUseCase(this.repository);

  Future<PredictionEntity> execute(String imagePath) async {
    if (imagePath.isEmpty) {
      throw Exception('La ruta de la imagen no puede estar vacía');
    }
    
    return await repository.predictDisease(imagePath);
  }
}
