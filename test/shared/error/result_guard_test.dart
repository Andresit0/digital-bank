import 'dart:async';

import 'package:digital_bank/shared/error/app_error.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:digital_bank/shared/error/result_guard.dart';
import 'package:digital_bank/shared/exceptions/network_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('guard', () {
    test('returns Success on normal execution', () async {
      final result = await guard(() async => 42);

      expect(result, isA<Success<int>>());
      expect((result as Success<int>).data, 42);
    });

    test('NetworkException without status maps to NetworkError', () async {
      final result = await guard<int>(
        () async => throw const NetworkException(message: 'timeout'),
      );

      expect(result, isA<Failure<int>>());
      expect((result as Failure<int>).error, isA<NetworkError>());
    });

    test('NetworkException with 401 maps to ApiError(401)', () async {
      final result = await guard<int>(
        () async => throw const NetworkException(
          message: 'unauthorized',
          statusCode: 401,
        ),
      );

      expect(result, isA<Failure<int>>());
      final error = (result as Failure<int>).error;
      expect(error, isA<ApiError>());
      expect((error as ApiError).statusCode, 401);
    });

    test('NetworkException with 500 maps to ApiError(500)', () async {
      final result = await guard<int>(
        () async => throw const NetworkException(
          message: 'server error',
          statusCode: 500,
        ),
      );

      expect(result, isA<Failure<int>>());
      final error = (result as Failure<int>).error;
      expect(error, isA<ApiError>());
      expect((error as ApiError).statusCode, 500);
    });

    test('TimeoutException maps to TimeoutError', () async {
      final result = await guard<int>(
        () async => throw TimeoutException('timed out'),
      );

      expect(result, isA<Failure<int>>());
      expect((result as Failure<int>).error, isA<TimeoutError>());
    });

    test('generic Exception maps to UnexpectedError', () async {
      final result = await guard<int>(
        () async => throw Exception('generic error'),
      );

      expect(result, isA<Failure<int>>());
      expect((result as Failure<int>).error, isA<UnexpectedError>());
    });

    test('rethrows Error instead of wrapping', () async {
      await expectLater(
        guard<int>(() async => throw ArgumentError('bad arg')),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
