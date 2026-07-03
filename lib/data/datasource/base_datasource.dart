import '../models/prediction_model.dart';

abstract class BaseDataSource {
  Future<PredictionModel> predictDisease(String imagePath);
}
