import 'package:digital_bank/features/movements/di/movements_providers.dart';
import 'package:digital_bank/features/movements/domain/entities/movement.dart';
import 'package:digital_bank/features/movements/domain/repositories/movements_repository.dart';
import 'package:digital_bank/features/movements/presentation/screens/movements_screen.dart';
import 'package:digital_bank/shared/error/app_error.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:digital_bank/shared/read.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeMovementsRepository implements MovementsRepository {
  _FakeMovementsRepository({this.result, this.delay});

  final Result<Read<List<Movement>>>? result;
  final Duration? delay;

  @override
  Future<Result<Read<List<Movement>>>> fetchMovements({
    required String accountId,
  }) async {
    if (delay != null) {
      await Future<void>.delayed(delay!);
    }
    return result ??
        const Success<Read<List<Movement>>>(
          Read<List<Movement>>([], source: ReadSource.remote),
        );
  }
}

Movement _movement(String id, MovementType type, double amount) {
  return Movement(
    id: id,
    accountId: 'acc-1',
    type: type,
    amount: amount,
    currency: 'USD',
    description: 'Movement $id',
    occurredAt: DateTime.utc(2026, 10, 1),
  );
}

Widget _wrap(MovementsRepository repository, {String? accountId = 'acc-1'}) {
  return ProviderScope(
    overrides: [movementsRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(home: MovementsScreen(accountId: accountId)),
  );
}

void main() {
  group('MovementsScreen', () {
    testWidgets('WID-MOV-001 shows the loading state', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _FakeMovementsRepository(
            result: const Success<Read<List<Movement>>>(
              Read<List<Movement>>([], source: ReadSource.remote),
            ),
            delay: const Duration(seconds: 1),
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('movements_loading')), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('WID-MOV-002 renders the movement list', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _FakeMovementsRepository(
            result: Success<Read<List<Movement>>>(
              Read<List<Movement>>(
                [
                  _movement('mov-1', MovementType.credit, 500.0),
                  _movement('mov-2', MovementType.debit, 125.5),
                ],
                source: ReadSource.remote,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('movement_tile_mov-1')), findsOneWidget);
      expect(find.byKey(const Key('movement_tile_mov-2')), findsOneWidget);
      expect(find.text('+ USD 500.00'), findsOneWidget);
      expect(find.text('- USD 125.50'), findsOneWidget);
    });

    testWidgets('WID-MOV-003 shows the empty state', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _FakeMovementsRepository(
            result: const Success<Read<List<Movement>>>(
              Read<List<Movement>>([], source: ReadSource.remote),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('movements_empty')), findsOneWidget);
    });

    testWidgets('WID-MOV-004 stale state renders the cached movements', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          _FakeMovementsRepository(
            result: Success<Read<List<Movement>>>(
              Read<List<Movement>>(
                [_movement('mov-1', MovementType.credit, 500.0)],
                source: ReadSource.cache,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('movement_tile_mov-1')), findsOneWidget);
      expect(find.text('+ USD 500.00'), findsOneWidget);
    });

    testWidgets('WID-MOV-005 stale state exposes a retry action', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          _FakeMovementsRepository(
            result: Success<Read<List<Movement>>>(
              Read<List<Movement>>(
                [_movement('mov-1', MovementType.credit, 500.0)],
                source: ReadSource.cache,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('movements_retry')), findsOneWidget);
    });

    testWidgets('WID-MOV-006 shows the error state', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _FakeMovementsRepository(
            result: const Failure<Read<List<Movement>>>(
              ApiError(statusCode: 500),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('movements_error')), findsOneWidget);
    });

    testWidgets('shows an invalid context state when accountId is missing', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(_FakeMovementsRepository(), accountId: null),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('movements_invalid_context')),
        findsOneWidget,
      );
    });
  });
}
