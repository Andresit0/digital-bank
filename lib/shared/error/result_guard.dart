import 'dart:async' show TimeoutException;

import '../exceptions/network_exception.dart';
import 'app_error.dart';
import 'result.dart';

Future<Result<T>> guard<T>(Future<T> Function() fn) async {
  try {
    return Success(await fn());
  } on NetworkException catch (error, stackTrace) {
    return Failure(_mapNetwork(error, stackTrace));
  } on TimeoutException catch (error, stackTrace) {
    return Failure(
      TimeoutError(technicalMessage: error.message, stackTrace: stackTrace),
    );
  } on Exception catch (error, stackTrace) {
    return Failure(
      UnexpectedError(technicalMessage: '$error', stackTrace: stackTrace),
    );
  }
}

AppError _mapNetwork(NetworkException error, StackTrace stackTrace) {
  final statusCode = error.statusCode;
  if (statusCode == null) {
    return NetworkError(
      technicalMessage: error.message,
      stackTrace: stackTrace,
    );
  }
  return ApiError(
    statusCode: statusCode,
    technicalMessage: error.message,
    stackTrace: stackTrace,
  );
}
