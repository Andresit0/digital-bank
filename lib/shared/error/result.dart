import 'app_error.dart';

sealed class Result<T> {
  const Result();

  bool get isSuccess;

  R when<R>({
    required R Function(T data) success,
    required R Function(AppError error) failure,
  });

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(AppError error) onFailure,
  });
}

final class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;

  @override
  bool get isSuccess => true;

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(AppError error) failure,
  }) => success(data);

  @override
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(AppError error) onFailure,
  }) => onSuccess(data);
}

final class Failure<T> extends Result<T> {
  const Failure(this.error);

  final AppError error;

  @override
  bool get isSuccess => false;

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(AppError error) failure,
  }) => failure(error);

  @override
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(AppError error) onFailure,
  }) => onFailure(error);
}
