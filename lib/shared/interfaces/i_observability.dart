import '../observability/observability_event.dart';

abstract interface class IObservability {
  void report(ObservabilityEvent event);
}
