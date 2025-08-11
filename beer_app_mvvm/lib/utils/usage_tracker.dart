import 'package:shared_preferences/shared_preferences.dart';

class UsageTracker {
  static final UsageTracker _instance = UsageTracker._internal();
  factory UsageTracker() => _instance;
  UsageTracker._internal();
  
  static const String _dailyUsageKey = 'daily_usage_count';
  static const String _lastUsageDateKey = 'last_usage_date';
  static const String _totalUsageKey = 'total_usage_count';
  static const String _monthlyUsageKey = 'monthly_usage_count';
  static const String _lastMonthKey = 'last_month';
  
  // 制限設定
  static const int maxDailyUsage = 20;          // 1日最大20回
  static const int maxMonthlyUsage = 600;       // 1ヶ月最大600回（20回×30日）
  static const Duration dailyCooldown = Duration(seconds: 5); // 5秒間隔
  
  SharedPreferences? _prefs;
  
  // 初期化
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
  
  // 日次使用回数をチェック
  Future<bool> canUseToday() async {
    await initialize();
    
    final today = DateTime.now();
    final todayString = _formatDate(today);
    final lastUsageDate = _prefs!.getString(_lastUsageDateKey);
    
    // 新しい日の場合、カウントをリセット
    if (lastUsageDate != todayString) {
      await _resetDailyCount();
      return true;
    }
    
    final dailyCount = _prefs!.getInt(_dailyUsageKey) ?? 0;
    return dailyCount < maxDailyUsage;
  }
  
  // 月次使用回数をチェック
  Future<bool> canUseThisMonth() async {
    await initialize();
    
    final now = DateTime.now();
    final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final lastMonth = _prefs!.getString(_lastMonthKey);
    
    // 新しい月の場合、カウントをリセット
    if (lastMonth != currentMonth) {
      await _resetMonthlyCount();
      return true;
    }
    
    final monthlyCount = _prefs!.getInt(_monthlyUsageKey) ?? 0;
    return monthlyCount < maxMonthlyUsage;
  }
  
  // 使用記録
  Future<void> recordUsage() async {
    await initialize();
    
    final now = DateTime.now();
    final todayString = _formatDate(now);
    final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    
    // 日次カウント更新
    final dailyCount = _prefs!.getInt(_dailyUsageKey) ?? 0;
    await _prefs!.setInt(_dailyUsageKey, dailyCount + 1);
    await _prefs!.setString(_lastUsageDateKey, todayString);
    
    // 月次カウント更新
    final monthlyCount = _prefs!.getInt(_monthlyUsageKey) ?? 0;
    await _prefs!.setInt(_monthlyUsageKey, monthlyCount + 1);
    await _prefs!.setString(_lastMonthKey, currentMonth);
    
    // 総使用回数更新
    final totalCount = _prefs!.getInt(_totalUsageKey) ?? 0;
    await _prefs!.setInt(_totalUsageKey, totalCount + 1);
  }
  
  // 残り使用回数（日次）
  Future<int> getRemainingDailyUsage() async {
    await initialize();
    
    if (!(await canUseToday())) {
      final dailyCount = _prefs!.getInt(_dailyUsageKey) ?? 0;
      return (maxDailyUsage - dailyCount).clamp(0, maxDailyUsage);
    }
    
    final dailyCount = _prefs!.getInt(_dailyUsageKey) ?? 0;
    return (maxDailyUsage - dailyCount).clamp(0, maxDailyUsage);
  }
  
  // 残り使用回数（月次）
  Future<int> getRemainingMonthlyUsage() async {
    await initialize();
    
    if (!(await canUseThisMonth())) {
      final monthlyCount = _prefs!.getInt(_monthlyUsageKey) ?? 0;
      return (maxMonthlyUsage - monthlyCount).clamp(0, maxMonthlyUsage);
    }
    
    final monthlyCount = _prefs!.getInt(_monthlyUsageKey) ?? 0;
    return (maxMonthlyUsage - monthlyCount).clamp(0, maxMonthlyUsage);
  }
  
  // 今日の使用回数
  Future<int> getTodayUsage() async {
    await initialize();
    
    final today = _formatDate(DateTime.now());
    final lastUsageDate = _prefs!.getString(_lastUsageDateKey);
    
    if (lastUsageDate != today) {
      return 0;
    }
    
    return _prefs!.getInt(_dailyUsageKey) ?? 0;
  }
  
  // 今月の使用回数
  Future<int> getMonthlyUsage() async {
    await initialize();
    
    final now = DateTime.now();
    final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final lastMonth = _prefs!.getString(_lastMonthKey);
    
    if (lastMonth != currentMonth) {
      return 0;
    }
    
    return _prefs!.getInt(_monthlyUsageKey) ?? 0;
  }
  
  // 総使用回数
  Future<int> getTotalUsage() async {
    await initialize();
    return _prefs!.getInt(_totalUsageKey) ?? 0;
  }
  
  // エラーメッセージ取得
  Future<String> getUsageLimitMessage() async {
    final canDaily = await canUseToday();
    final canMonthly = await canUseThisMonth();
    
    if (!canDaily) {
      final remaining = await getRemainingDailyUsage();
      return '本日の利用回数上限（${maxDailyUsage}回）に達しました。明日またお試しください。';
    }
    
    if (!canMonthly) {
      final remaining = await getRemainingMonthlyUsage();
      return '今月の利用回数上限（${maxMonthlyUsage}回）に達しました。来月またお試しください。';
    }
    
    return '';
  }
  
  // 使用統計情報
  Future<Map<String, dynamic>> getUsageStats() async {
    return {
      'dailyUsage': await getTodayUsage(),
      'maxDailyUsage': maxDailyUsage,
      'remainingDaily': await getRemainingDailyUsage(),
      'monthlyUsage': await getMonthlyUsage(),
      'maxMonthlyUsage': maxMonthlyUsage,
      'remainingMonthly': await getRemainingMonthlyUsage(),
      'totalUsage': await getTotalUsage(),
    };
  }
  
  // 日次カウントリセット
  Future<void> _resetDailyCount() async {
    await _prefs!.setInt(_dailyUsageKey, 0);
    await _prefs!.setString(_lastUsageDateKey, _formatDate(DateTime.now()));
  }
  
  // 月次カウントリセット  
  Future<void> _resetMonthlyCount() async {
    final now = DateTime.now();
    final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    
    await _prefs!.setInt(_monthlyUsageKey, 0);
    await _prefs!.setString(_lastMonthKey, currentMonth);
  }
  
  // 日付フォーマット
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  // デバッグ用：使用状況をリセット
  Future<void> resetAllUsage() async {
    await initialize();
    await _prefs!.clear();
  }
}