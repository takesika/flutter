enum AppError {
  network,
  apiKey,
  parsing,
  unknown,
}

class AppException implements Exception {
  final AppError error;
  final String message;

  AppException(this.error, this.message);

  @override
  String toString() => 'AppException: $message';
}

enum LoadingState {
  idle,
  loading,
  success,
  error,
}

class AsyncResult<T> {
  final LoadingState state;
  final T? data;
  final AppException? error;

  AsyncResult._({
    required this.state,
    this.data,
    this.error,
  });

  factory AsyncResult.idle() => AsyncResult._(state: LoadingState.idle);
  
  factory AsyncResult.loading() => AsyncResult._(state: LoadingState.loading);
  
  factory AsyncResult.success(T data) => AsyncResult._(
    state: LoadingState.success,
    data: data,
  );
  
  factory AsyncResult.error(AppException error) => AsyncResult._(
    state: LoadingState.error,
    error: error,
  );

  bool get isLoading => state == LoadingState.loading;
  bool get isSuccess => state == LoadingState.success;
  bool get isError => state == LoadingState.error;
  bool get hasData => data != null;
}