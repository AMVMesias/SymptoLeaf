import '../../domain/entities/prediction_entity.dart';
import '../datasource/base_datasource.dart';
import 'base_repository.dart';

class PredictionRepositoryImpl extends BaseRepository {
  final BaseDataSource dataSource;

  PredictionRepositoryImpl(this.dataSource);

  @override
  Future<PredictionEntity> predictDisease(String imagePath) async {
    final model = await dataSource.predictDisease(imagePath);
    return model.toEntity();
  }
}
