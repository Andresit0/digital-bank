import 'package:digital_bank/features/movements/domain/entities/movement.dart';
import 'package:digital_bank/features/movements/presentation/screens/movement_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Movement _movement() {
  return Movement(
    id: 'mov-1',
    accountId: 'acc-1',
    type: MovementType.debit,
    amount: 125.5,
    currency: 'USD',
    description: 'Card purchase',
    occurredAt: DateTime.utc(2026, 10, 2),
  );
}

void main() {
  group('MovementDetailScreen', () {
    testWidgets('WID-MOV-005 renders the loaded movement without a request', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: MovementDetailScreen(movement: _movement())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Card purchase'), findsOneWidget);
      expect(find.text('- USD 125.50'), findsOneWidget);
      expect(find.text('Movement details'), findsOneWidget);
    });

    testWidgets('shows an unavailable state when no movement is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: MovementDetailScreen(movement: null)),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('movement_detail_unavailable')),
        findsOneWidget,
      );
    });
  });
}
