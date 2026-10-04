import '../../../shared/interfaces/i_observability.dart';
import '../../../shared/observability/observability_event.dart';

class NoopObservability implements IObservability {
  const NoopObservability();

  @override
  void report(ObservabilityEvent event) {}
}
