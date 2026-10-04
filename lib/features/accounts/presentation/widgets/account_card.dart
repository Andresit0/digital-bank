import 'package:flutter/material.dart';

import '../../domain/entities/account.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({super.key, required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key('account_card_${account.id}'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              account.displayName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(account.maskedNumber),
            const SizedBox(height: 12),
            Text(
              _formatBalance(account.availableBalance),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}

String _formatBalance(double value) {
  final fixed = value.toStringAsFixed(2);
  final parts = fixed.split('.');
  final integerPart = parts[0];
  final decimals = parts[1];

  final buffer = StringBuffer();
  final digits = integerPart.replaceFirst('-', '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[i]);
  }

  final sign = integerPart.startsWith('-') ? '-' : '';
  return '$sign\$$buffer.$decimals';
}
