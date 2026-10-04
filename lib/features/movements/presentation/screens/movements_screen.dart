import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/presentation/theme/app_colors.dart';
import '../../../../shared/presentation/widgets/bank_app_bar.dart';
import '../movements_state.dart';
import '../notifiers/movements_notifier.dart';
import '../widgets/movement_tile.dart';

class MovementsScreen extends ConsumerStatefulWidget {
  const MovementsScreen({super.key, required this.accountId});

  final String? accountId;

  @override
  ConsumerState<MovementsScreen> createState() => _MovementsScreenState();
}

class _MovementsScreenState extends ConsumerState<MovementsScreen> {
  @override
  void initState() {
    super.initState();

    final accountId = widget.accountId;

    if (accountId != null) {
      Future.microtask(
        () => ref.read(movementsProvider.notifier).load(accountId: accountId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountId = widget.accountId;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const BankAppBar(title: 'Movements'),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: accountId == null
                  ? const _MovementsInvalidContext()
                  : switch (ref.watch(movementsProvider)) {
                      MovementsInitial() || MovementsLoading() => const Center(
                        key: Key('movements_loading'),
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.orange,
                          ),
                        ),
                      ),
                      MovementsEmpty() => const _MovementsEmptyState(),
                      MovementsFailure() => const _MovementsErrorState(),
                      MovementsLoaded(:final movements) => ListView(
                        children: [
                          const _MovementsHeader(),
                          const SizedBox(height: 24),
                          Semantics(
                            headingLevel: 2,
                            child: const Text(
                              'Account activity',
                              style: TextStyle(
                                color: AppColors.darkText,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          for (final movement in movements) ...[
                            MovementTile(
                              movement: movement,
                              onTap: () => context.push(
                                '/movements/${movement.id}',
                                extra: movement,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    },
            ),
          ),
        ),
      ),
    );
  }
}

class _MovementsHeader extends StatelessWidget {
  const _MovementsHeader();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.orange,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Financial activity',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Keep track of your movements',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 48,
              height: 48,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  color: AppColors.orange,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MovementsErrorState extends StatelessWidget {
  const _MovementsErrorState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      key: Key('movements_error'),
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StateIcon(icon: Icons.error_outline, isError: true),
            SizedBox(height: 18),
            Text(
              'We couldn’t load your movements',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.darkText,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Something went wrong. Please try again later.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _StateIcon extends StatelessWidget {
  const _StateIcon({required this.icon, this.isError = false});

  final IconData icon;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? Colors.redAccent : AppColors.orange;

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 32),
    );
  }
}

class _MovementsInvalidContext extends StatelessWidget {
  const _MovementsInvalidContext();

  @override
  Widget build(BuildContext context) {
    return const Center(
      key: Key('movements_invalid_context'),
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StateIcon(icon: Icons.account_balance_wallet_outlined),
            SizedBox(height: 18),
            Text(
              'No account selected',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.darkText,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Select an account to view its movements.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _MovementsEmptyState extends StatelessWidget {
  const _MovementsEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      key: Key('movements_empty'),
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StateIcon(icon: Icons.receipt_long_outlined),
            SizedBox(height: 18),
            Text(
              'No movements yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.darkText,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your account activity will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
