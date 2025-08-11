import 'dart:convert';

class InputValidator {
  static const int maxLength = 30;
  static const int minLength = 1;
  
  // 禁止文字のパターン（セキュリティ対策）
  static final RegExp _dangerousChars = RegExp(r'[<>"&/\\]');
  static final RegExp _sqlKeywords = RegExp(
    r'\b(?:SELECT|INSERT|UPDATE|DELETE|DROP|UNION|EXEC|SCRIPT)\b',
    caseSensitive: false,
  );
  
  // バリデーション結果
  static ValidationResult validate(String input) {
    // null・空文字チェック
    if (input.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'お酒の名前を入力してください',
      );
    }
    
    // 文字数チェック
    final trimmedInput = input.trim();
    if (trimmedInput.length < minLength) {
      return ValidationResult(
        isValid: false,
        errorMessage: '${minLength}文字以上入力してください',
      );
    }
    
    if (trimmedInput.length > maxLength) {
      return ValidationResult(
        isValid: false,
        errorMessage: '${maxLength}文字以内で入力してください',
      );
    }
    
    // 危険な文字チェック（XSS対策）
    if (_dangerousChars.hasMatch(trimmedInput)) {
      return ValidationResult(
        isValid: false,
        errorMessage: '使用できない文字が含まれています',
      );
    }
    
    // SQLインジェクション対策
    if (_sqlKeywords.hasMatch(trimmedInput)) {
      return ValidationResult(
        isValid: false,
        errorMessage: '使用できない文字列が含まれています',
      );
    }
    
    // 連続する特殊文字チェック
    if (RegExp(r'[^\w\s\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]{3,}').hasMatch(trimmedInput)) {
      return ValidationResult(
        isValid: false,
        errorMessage: '特殊文字の使用を制限しています',
      );
    }
    
    return ValidationResult(
      isValid: true,
      sanitizedInput: _sanitizeInput(trimmedInput),
    );
  }
  
  // 入力サニタイズ
  static String _sanitizeInput(String input) {
    // HTMLエンコード
    String sanitized = const HtmlEscape().convert(input);
    
    // 余分な空白・改行を正規化
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');
    
    // 前後の空白除去
    return sanitized.trim();
  }
  
  // リアルタイムバリデーション用（軽量版）
  static bool isValidLength(String input) {
    final length = input.trim().length;
    return length >= minLength && length <= maxLength;
  }
  
  // 文字数カウント
  static int getCharacterCount(String input) {
    return input.trim().length;
  }
}

class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? sanitizedInput;
  
  ValidationResult({
    required this.isValid,
    this.errorMessage,
    this.sanitizedInput,
  });
}