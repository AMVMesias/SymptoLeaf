import '../../domain/entities/prediction_entity.dart';

abstract class BaseRepository {
  Future<PredictionEntity> predictDisease(String imagePath);
}
