sealed class AppError {
  const AppError({this.technicalMessage, this.stackTrace});

  final String? technicalMessage;
  final StackTrace? stackTrace;

  bool get isNetworkRelated => false;
  bool get isTransient => false;

  @override
  String toString() => '$runtimeType(technicalMessage: $technicalMessage)';
}

final class NetworkError extends AppError {
  const NetworkError({super.technicalMessage, super.stackTrace});

  @override
  bool get isNetworkRelated => true;

  @override
  bool get isTransient => true;
}

final class TimeoutError extends AppError {
  const TimeoutError({super.technicalMessage, super.stackTrace});

  @override
  bool get isTransient => true;
}

final class ApiError extends AppError {
  const ApiError({this.statusCode, super.technicalMessage, super.stackTrace});

  final int? statusCode;
}

final class UnexpectedError extends AppError {
  const UnexpectedError({super.technicalMessage, super.stackTrace});
}
