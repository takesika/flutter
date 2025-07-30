import 'package:flutter/foundation.dart';
import '../models/beer_data.dart';
import '../models/app_state.dart';
import '../repositories/ai_repository.dart';

class GenerateViewModel extends ChangeNotifier {
  final AiRepository _aiRepository = AiRepository();
  
  String _inputText = '';
  AsyncResult<BeerData> _generateResult = AsyncResult.idle();
  
  String get inputText => _inputText;
  AsyncResult<BeerData> get generateResult => _generateResult;
  
  bool get isLoading => _generateResult.isLoading;
  bool get hasResult => _generateResult.isSuccess && _generateResult.hasData;
  bool get hasError => _generateResult.isError;
  
  BeerData? get generatedBeer => _generateResult.data;
  String get errorMessage => _generateResult.error?.message ?? '';

  void updateInputText(String text) {
    _inputText = text.trim();
    notifyListeners();
  }

  bool get canGenerate => _inputText.isNotEmpty && !isLoading;

  Future<void> generateBeerData() async {
    if (!canGenerate) return;

    _generateResult = AsyncResult.loading();
    notifyListeners();

    try {
      final result = await _aiRepository.generateBeerData(_inputText);
      _generateResult = result;
    } catch (e) {
      _generateResult = AsyncResult.error(
        AppException(AppError.unknown, 'エラーが発生しました: $e'),
      );
    }
    
    notifyListeners();
  }

  void clearResult() {
    _generateResult = AsyncResult.idle();
    notifyListeners();
  }

  void clearInput() {
    _inputText = '';
    notifyListeners();
  }

  void reset() {
    _inputText = '';
    _generateResult = AsyncResult.idle();
    notifyListeners();
  }
}