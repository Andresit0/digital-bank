abstract interface class ILogger {
  void info(String message, {String? technicalMessage});

  void error(
    String message, {
    Object? technicalMessage,
    StackTrace? stackTrace,
  });
}
