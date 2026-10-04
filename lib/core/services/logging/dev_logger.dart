import 'dart:developer';

import '../../../shared/interfaces/i_logger.dart';

class DevLogger implements ILogger {
  const DevLogger();

  @override
  void info(String message, {String? technicalMessage}) {
    log(message, name: 'INFO', error: technicalMessage);
  }

  @override
  void error(
    String message, {
    Object? technicalMessage,
    StackTrace? stackTrace,
  }) {
    log(
      message,
      name: 'ERROR',
      error: technicalMessage,
      stackTrace: stackTrace,
    );
  }
}
