import 'observability_severity.dart';

class ObservabilityEvent {
  const ObservabilityEvent({
    required this.name,
    required this.severity,
    this.metadata = const <String, Object?>{},
    this.timestamp,
  });

  final String name;
  final ObservabilitySeverity severity;
  final Map<String, Object?> metadata;
  final DateTime? timestamp;
}
