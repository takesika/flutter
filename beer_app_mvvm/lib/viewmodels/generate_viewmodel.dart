import 'package:flutter/foundation.dart';
import '../models/beer_data.dart';
import '../models/app_state.dart';
import '../repositories/ai_repository.dart';
import '../utils/input_validator.dart';
import '../utils/rate_limiter.dart';

class GenerateViewModel extends ChangeNotifier {
  final AiRepository _aiRepository = AiRepository();
  final RateLimiter _rateLimiter = RateLimiter();
  
  String _inputText = '';
  AsyncResult<BeerData> _generateResult = AsyncResult.idle();
  String? _validationError;
  bool _isValidInput = false;
  Map<String, dynamic> _usageStats = {};
  
  String get inputText => _inputText;
  AsyncResult<BeerData> get generateResult => _generateResult;
  String? get validationError => _validationError;
  bool get isValidInput => _isValidInput;
  Map<String, dynamic> get usageStats => _usageStats;
  
  bool get isLoading => _generateResult.isLoading;
  bool get hasResult => _generateResult.isSuccess && _generateResult.hasData;
  bool get hasError => _generateResult.isError;
  
  BeerData? get generatedBeer => _generateResult.data;
  String get errorMessage => _generateResult.error?.message ?? '';
  
  // 文字数カウント
  int get characterCount => InputValidator.getCharacterCount(_inputText);
  int get maxCharacterCount => InputValidator.maxLength;
  
  // 使用統計情報
  int get dailyUsage => _usageStats['dailyUsage'] ?? 0;
  int get maxDailyUsage => _usageStats['maxDailyUsage'] ?? 5;
  int get remainingDaily => _usageStats['remainingDaily'] ?? 5;
  int get monthlyUsage => _usageStats['monthlyUsage'] ?? 0;
  int get maxMonthlyUsage => _usageStats['maxMonthlyUsage'] ?? 100;
  int get remainingMonthly => _usageStats['remainingMonthly'] ?? 100;
  int get totalUsage => _usageStats['totalUsage'] ?? 0;

  void updateInputText(String text) {
    _inputText = text;
    _validateInput();
    notifyListeners();
  }
  
  void _validateInput() {
    final validation = InputValidator.validate(_inputText);
    _isValidInput = validation.isValid;
    _validationError = validation.errorMessage;
    
    if (validation.isValid && validation.sanitizedInput != null) {
      _inputText = validation.sanitizedInput!;
    }
  }

  bool get canGenerate => _isValidInput && !isLoading;

  Future<void> generateBeerData() async {
    // バリデーションチェック
    if (!_isValidInput) {
      return;
    }
    
    // レート制限チェック
    if (!(await _rateLimiter.canMakeRequest('generate'))) {
      final errorMessage = await _rateLimiter.getErrorMessage('generate');
      _generateResult = AsyncResult.error(
        AppException(AppError.unknown, errorMessage),
      );
      notifyListeners();
      return;
    }

    _generateResult = AsyncResult.loading();
    notifyListeners();

    try {
      // サニタイズされた入力を使用
      final validation = InputValidator.validate(_inputText);
      if (!validation.isValid) {
        _generateResult = AsyncResult.error(
          AppException(AppError.parsing, validation.errorMessage!),
        );
        notifyListeners();
        return;
      }
      
      final result = await _aiRepository.generateBeerData(validation.sanitizedInput!);
      
      // 成功時に使用記録
      if (result.isSuccess) {
        await _rateLimiter.recordUsage('generate');
        await _updateUsageStats();
      }
      
      _generateResult = result;
    } on AppException catch (e) {
      _generateResult = AsyncResult.error(e);
    } catch (e) {
      _generateResult = AsyncResult.error(
        AppException(AppError.unknown, 'うんちくの生成に失敗しました。しばらく時間をおいて再度お試しください。'),
      );
    }
    
    notifyListeners();
  }
  
  // 使用統計更新
  Future<void> _updateUsageStats() async {
    _usageStats = await _rateLimiter.getUsageStats();
  }
  
  // 初期化時に使用統計を読み込み
  Future<void> initialize() async {
    await _updateUsageStats();
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
    _validationError = null;
    _isValidInput = false;
    notifyListeners();
  }
  
  // 次のリクエスト可能時間を取得
  Duration? getTimeUntilNextRequest() {
    return _rateLimiter.getTimeUntilNextRequest('generate');
  }
  
  // レート制限チェック
  Future<bool> checkCanGenerate() async {
    return _isValidInput && !isLoading && await _rateLimiter.canMakeRequest('generate');
  }
  
  // 入力フォーカス時のバリデーション
  void validateOnFocus() {
    _validateInput();
    notifyListeners();
  }
}