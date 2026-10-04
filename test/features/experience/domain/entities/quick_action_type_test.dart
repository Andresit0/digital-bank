import 'package:digital_bank/features/experience/domain/entities/quick_action_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuickActionType', () {
    test('exposes the supported intents', () {
      expect(QuickActionType.values, [
        QuickActionType.viewMovements,
        QuickActionType.viewAccounts,
      ]);
    });
  });
}
