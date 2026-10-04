import 'package:digital_bank/shared/error/app_error.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppError semantics', () {
    test('NetworkError is network-related and transient', () {
      const error = NetworkError();

      expect(error.isNetworkRelated, isTrue);
      expect(error.isTransient, isTrue);
    });

    test('TimeoutError is transient and not network-related', () {
      const error = TimeoutError();

      expect(error.isTransient, isTrue);
      expect(error.isNetworkRelated, isFalse);
    });

    test('ApiError is not network-related and not transient', () {
      const error = ApiError();

      expect(error.isNetworkRelated, isFalse);
      expect(error.isTransient, isFalse);
    });

    test('ApiError exposes statusCode', () {
      const error = ApiError(statusCode: 500);

      expect(error.statusCode, 500);
    });

    test('UnexpectedError is not network-related and not transient', () {
      const error = UnexpectedError();

      expect(error.isNetworkRelated, isFalse);
      expect(error.isTransient, isFalse);
    });

    test('toString includes runtimeType and technicalMessage', () {
      const error = NetworkError(technicalMessage: 'boom');
      final text = error.toString();

      expect(text, contains('NetworkError'));
      expect(text, contains('boom'));
    });
  });
}
