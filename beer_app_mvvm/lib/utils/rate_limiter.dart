import 'usage_tracker.dart';

class RateLimiter {
  static final RateLimiter _instance = RateLimiter._internal();
  factory RateLimiter() => _instance;
  RateLimiter._internal();
  
  final Map<String, DateTime> _lastRequestTime = {};
  final UsageTracker _usageTracker = UsageTracker();
  
  // レート制限設定
  static const Duration cooldownDuration = Duration(seconds: 5);  // 5秒間隔
  static const Duration sessionCooldown = Duration(seconds: 5);   // セッション内5秒間隔
  
  // リクエスト許可チェック
  Future<bool> canMakeRequest(String identifier) async {
    final now = DateTime.now();
    final lastRequest = _lastRequestTime[identifier];
    
    // 使用制限チェック（日次・月次）
    final canUseDaily = await _usageTracker.canUseToday();
    final canUseMonthly = await _usageTracker.canUseThisMonth();
    
    if (!canUseDaily || !canUseMonthly) {
      return false;
    }
    
    // セッション内クールダウンチェック
    if (lastRequest != null) {
      final timeSinceLastRequest = now.difference(lastRequest);
      if (timeSinceLastRequest < sessionCooldown) {
        return false;
      }
    }
    
    return true;
  }
  
  // 次のリクエスト可能時間を取得
  Duration? getTimeUntilNextRequest(String identifier) {
    final lastRequest = _lastRequestTime[identifier];
    if (lastRequest == null) return null;
    
    final now = DateTime.now();
    final timeSinceLastRequest = now.difference(lastRequest);
    
    if (timeSinceLastRequest < sessionCooldown) {
      return sessionCooldown - timeSinceLastRequest;
    }
    
    return null;
  }
  
  // 使用記録
  Future<void> recordUsage(String identifier) async {
    _lastRequestTime[identifier] = DateTime.now();
    await _usageTracker.recordUsage();
  }
  
  // 残りリクエスト数を取得（日次）
  Future<int> getRemainingRequests(String identifier) async {
    return await _usageTracker.getRemainingDailyUsage();
  }
  
  // 使用統計を取得
  Future<Map<String, dynamic>> getUsageStats() async {
    return await _usageTracker.getUsageStats();
  }
  
  // エラーメッセージを取得
  Future<String> getErrorMessage(String identifier) async {
    final timeUntil = getTimeUntilNextRequest(identifier);
    
    if (timeUntil != null) {
      final seconds = timeUntil.inSeconds;
      return '${seconds}秒後に再実行できます';
    }
    
    // 使用制限メッセージを取得
    return await _usageTracker.getUsageLimitMessage();
  }
}