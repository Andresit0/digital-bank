import 'package:digital_bank/shared/interfaces/i_observability.dart';
import 'package:digital_bank/shared/observability/observability_event.dart';

class FakeObservability implements IObservability {
  final List<ObservabilityEvent> events = [];

  @override
  void report(ObservabilityEvent event) {
    events.add(event);
  }
}
