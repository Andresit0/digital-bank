import 'package:flutter/material.dart';

import '../../../../shared/presentation/theme/app_colors.dart';
import '../../../../shared/presentation/widgets/bank_app_bar.dart';
import '../../domain/entities/movement.dart';
import '../widgets/movement_tile.dart';

class MovementDetailScreen extends StatelessWidget {
  const MovementDetailScreen({super.key, required this.movement});

  final Movement? movement;

  @override
  Widget build(BuildContext context) {
    final movement = this.movement;

    if (movement == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: const BankAppBar(title: 'Movement'),
        body: const Center(
          key: Key('movement_detail_unavailable'),
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DetailStateIcon(),
                SizedBox(height: 18),
                Text(
                  'Movement unavailable',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.darkText,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'This movement is no longer available.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isCredit = movement.type == MovementType.credit;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const BankAppBar(title: 'Movement'),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                children: [
                  Semantics(
                    container: true,
                    label:
                        '${isCredit ? 'Credit' : 'Debit'} movement. '
                        '${movement.description}. '
                        '${movementAmountLabel(movement)}.',
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isCredit
                            ? Colors.green.withValues(alpha: 0.08)
                            : AppColors.orange.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: isCredit
                                  ? Colors.green.withValues(alpha: 0.12)
                                  : AppColors.orange.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isCredit
                                  ? Icons.arrow_downward_rounded
                                  : Icons.arrow_upward_rounded,
                              color: isCredit
                                  ? Colors.green.shade700
                                  : AppColors.orange,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            movement.description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.darkText,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            movementAmountLabel(movement),
                            style: TextStyle(
                              color: isCredit
                                  ? Colors.green.shade700
                                  : AppColors.darkText,
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.7,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isCredit ? 'Credit' : 'Debit',
                              style: TextStyle(
                                color: isCredit
                                    ? Colors.green.shade700
                                    : AppColors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Movement details',
                          style: TextStyle(
                            color: AppColors.darkText,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _DetailRow(
                          icon: Icons.swap_horiz_outlined,
                          label: 'Type',
                          value: isCredit ? 'Credit' : 'Debit',
                        ),
                        _DetailRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Date',
                          value: formatMovementDate(movement.occurredAt),
                        ),
                        _DetailRow(
                          icon: Icons.payments_outlined,
                          label: 'Currency',
                          value: movement.currency,
                        ),
                        _DetailRow(
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'Account ID',
                          value: movement.accountId,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Movement details are provided by your account activity.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppColors.borderColor)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.orange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.orange, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.darkText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailStateIcon extends StatelessWidget {
  const _DetailStateIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.orange.withValues(alpha: 0.10),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.receipt_long_outlined,
        color: AppColors.orange,
        size: 32,
      ),
    );
  }
}
