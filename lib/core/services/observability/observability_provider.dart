import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/interfaces/i_observability.dart';
import 'noop_observability.dart';

final observabilityProvider = Provider<IObservability>(
  (ref) => const NoopObservability(),
);
