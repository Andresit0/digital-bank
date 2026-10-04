import 'package:digital_bank/shared/error/app_error.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    test('Success exposes data and isSuccess true', () {
      const result = Success<int>(42);

      expect(result.data, 42);
      expect(result.isSuccess, isTrue);
    });

    test('Failure exposes error and isSuccess false', () {
      const error = UnexpectedError();
      const result = Failure<int>(error);

      expect(result.error, same(error));
      expect(result.isSuccess, isFalse);
    });

    test('when executes success branch', () {
      const result = Success<int>(42);

      final value = result.when(
        success: (data) => 'success:$data',
        failure: (_) => 'failure',
      );

      expect(value, 'success:42');
    });

    test('when executes failure branch', () {
      const result = Failure<int>(UnexpectedError());

      final value = result.when(
        success: (_) => 'success',
        failure: (error) => 'failure:${error.runtimeType}',
      );

      expect(value, 'failure:UnexpectedError');
    });

    test('fold executes onSuccess', () {
      const result = Success<int>(42);

      final value = result.fold(
        onSuccess: (data) => data + 1,
        onFailure: (_) => 0,
      );

      expect(value, 43);
    });

    test('fold executes onFailure', () {
      const result = Failure<int>(UnexpectedError());

      final value = result.fold(
        onSuccess: (_) => 'success',
        onFailure: (error) => error.runtimeType.toString(),
      );

      expect(value, 'UnexpectedError');
    });
  });
}
