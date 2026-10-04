import 'package:digital_bank/core/services/logging/dev_logger.dart';
import 'package:digital_bank/core/services/logging/logging_providers.dart';
import 'package:digital_bank/shared/interfaces/i_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DevLogger.info does not throw', () {
    const logger = DevLogger();

    logger.info('hello');
  });

  test(
    'DevLogger.error does not throw with technicalMessage and stackTrace',
    () {
      const logger = DevLogger();

      logger.error(
        'boom',
        technicalMessage: 'details',
        stackTrace: StackTrace.current,
      );
    },
  );

  test('loggerProvider resolves an instance compatible with ILogger', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final logger = container.read(loggerProvider);

    expect(logger, isA<ILogger>());
  });
}
