import '../models/beer_data.dart';
import '../models/app_state.dart';
import '../services/api_service.dart';

class AiRepository {
  static final AiRepository _instance = AiRepository._internal();
  factory AiRepository() => _instance;
  AiRepository._internal();

  final ApiService _apiService = ApiService();

  Future<AsyncResult<BeerData>> generateBeerData(String beerName) async {
    if (beerName.trim().isEmpty) {
      return AsyncResult.error(
        AppException(AppError.parsing, 'ビール名を入力してください'),
      );
    }

    try {
      final beerData = await _apiService.generateBeerDescription(beerName.trim());
      return AsyncResult.success(beerData);
    } on AppException catch (e) {
      return AsyncResult.error(e);
    } catch (e) {
      return AsyncResult.error(
        AppException(AppError.unknown, 'うんちくの生成に失敗しました: $e'),
      );
    }
  }
}