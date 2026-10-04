import 'package:digital_bank/shared/observability/observability_event.dart';
import 'package:flutter_test/flutter_test.dart';

const Set<String> allowedMetadataKeys = <String>{
  'errorType',
  'statusCode',
  'endpoint',
  'feature',
  'attempt',
};

const Set<String> prohibitedMetadataKeys = <String>{
  'password',
  'accessToken',
  'refreshToken',
  'accountNumber',
  'maskedNumber',
  'balance',
  'availableBalance',
  'email',
  'payload',
};

const List<String> prohibitedValues = <String>[
  'super-secret-password',
  'secret-token',
  '1234567890',
  '****1234',
  '1500.50',
  'customer@example.com',
];

void expectEventsRespectSensitiveDataPolicy(List<ObservabilityEvent> events) {
  for (final event in events) {
    for (final key in event.metadata.keys) {
      if (prohibitedMetadataKeys.contains(key)) {
        fail('event "${event.name}" reports prohibited metadata key "$key"');
      }
    }

    final reported = <String>[
      event.name,
      ...event.metadata.values.map((value) => value.toString()),
    ].join(' ');

    for (final value in prohibitedValues) {
      if (reported.contains(value)) {
        fail('event "${event.name}" contains prohibited value "$value"');
      }
    }
  }
}
